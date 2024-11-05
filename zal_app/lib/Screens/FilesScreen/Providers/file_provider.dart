import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zal/Functions/models.dart';
import 'package:open_file/open_file.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

class FileNotifier extends AsyncNotifier<FileProviderModel> {
  FileData? currentFile;
  Set<int> chunks = {};
  int lastBiggestByte = 0;
  List<int> computerChunks = [];
  @override
  Future<FileProviderModel> build() async {
    final model = await ref.watch(_fileProvider.future);
    final data = jsonDecode(model.data!.data);
    List<int>? missingChunks;
    bool isRebuilding = false;
    if (model.data!.type == SocketDataType.file) {
      final byteOffset = data['ByteOffset'];
      if (byteOffset > lastBiggestByte) lastBiggestByte = byteOffset;
      await _saveChunkToFile(data['ByteOffset'], data['ChunkData']);
    } else if (model.data!.type == SocketDataType.fileComplete) {
      //get the chunks that aren't here
      computerChunks.addAll(List<int>.from(data['sentChunks']));
      missingChunks = computerChunks.where((e) => !chunks.contains(e)).toList();
      if (missingChunks.isNotEmpty) {
        ref
            .read(socketProvider.notifier)
            .sendMessage('get_file_missing_chunks', jsonEncode({'path': '${currentFile!.directory}/${currentFile!.name}', 'chunks': missingChunks}));
      } else {
        rebuildFile();
        isRebuilding = true;
      }
    }
    return FileProviderModel(
      file: currentFile,
      lastBiggestByte: lastBiggestByte,
      fileProviderState: isRebuilding ? FileProviderState.rebuilding : FileProviderState.downloading,
    );
  }

  Future<void> _saveChunkToFile(int byteOffset, String chunkData) async {
    List<int> decodedBytes = base64Decode(chunkData);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    // Save the chunk to a separate file
    chunks.add(byteOffset);
    String chunkFilePath = '$tempPath/chunk_$byteOffset.txt';
    File(chunkFilePath).writeAsBytesSync(decodedBytes);
  }

  cancelTransfer() {
    ref.read(socketProvider.notifier).sendMessage('cancel_file', '');
    currentFile = null;
  }

  openTransferredFile() async {
    final filePath = await getCurrentFilePath();
    OpenFile.open(filePath);
  }

  Future<void> rebuildFile() async {
    final filePath = await getCurrentFilePath();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File rebuiltFile = File(filePath);
    try {
      await rebuiltFile.delete();
    } catch (c) {}
    chunks.sorted((a, b) => a.compareTo(b));
    for (final chunk in chunks) {
      String chunkFilePath = '$tempPath/chunk_$chunk.txt';
      File chunkFile = File(chunkFilePath);
      rebuiltFile.writeAsBytesSync(chunkFile.readAsBytesSync(), mode: FileMode.append);
      chunkFile.deleteSync(); // Delete the individual chunk file after use
    }
    state = AsyncData(state.value!.copyWith(fileProviderState: FileProviderState.complete));
    openTransferredFile();
  }

  Future<void> viewFile(FileData file) async {
    lastBiggestByte = 0;
    chunks.clear();
    computerChunks.clear();
    ref.invalidateSelf();
    currentFile = file;
    // fileObject = File(await getCurrentFilePath());
    ref.read(socketProvider.notifier).sendMessage('get_file', "${file.directory}/${file.name}");
  }

  Future<File> writeToFile(Uint8List chunk) async {
    final filePath = await getCurrentFilePath();
    final buffer = chunk.buffer;
    return File(filePath).writeAsBytes(chunk);
  }

  Future<String> getCurrentFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filePath = '$tempPath/${currentFile!.name}';
    return filePath;
  }
}

final fileProvider = AsyncNotifierProvider<FileNotifier, FileProviderModel>(() {
  return FileNotifier();
});

final _fileProvider = FutureProvider<SocketData>((ref) {
  final sub = ref.listen(socketStreamProvider, (prev, cur) {
    if ([SocketDataType.file, SocketDataType.fileComplete].contains(cur.valueOrNull?.type)) {
      ref.state = AsyncData(cur.valueOrNull!);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
