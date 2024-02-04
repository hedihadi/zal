import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

class DirectoryProvider extends AsyncNotifier<List<FileData>> {
  bool didRequestInitialData = false;

  ///this contains a list of the folders that user is inside.
  List<FileData> folders = [];
  SortFilesBy sortFilesBy = SortFilesBy.sizeDescending;
  String? filterText;

  ///this contains the list of files of the current folder,
  ///we need to keep them inside this variable because we have a filter text
  List<FileData> currentFolderFiles = [];

  ///when user taps a folder, we keep track of that folder to this variable,
  ///so that if the folder fails to open, we dont add it to [folders],
  ///if it succeeds, we add this variable to the [folders].
  FileData? pendingDirectoryToOpen;
  List<FileData> fetchData(String data) {
    final parsedData = jsonDecode(data);
    List<FileData> result = [];
    for (final drive in parsedData) {
      result.add(FileData.fromMap(drive));
    }
    filterText = null;
    return _sortFiles(result);
  }

  @override
  Future<List<FileData>> build() async {
    if (didRequestInitialData == false) {
      didRequestInitialData = true;
      refresh();
    }
    final model = await ref.watch(_directoryProvider.future);
    final files = fetchData(model.data!.data);
    files.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    currentFolderFiles = files;
    if (pendingDirectoryToOpen != null) {
      folders.add(pendingDirectoryToOpen!);
      pendingDirectoryToOpen = null;
    }
    return files;
  }

  List<FileData> _sortFiles(List<FileData> files) {
    final result = files;
    switch (sortFilesBy) {
      case SortFilesBy.nameAscending:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortFilesBy.nameDescending:
        result.sort((b, a) => a.name.compareTo(b.name));
        break;
      case SortFilesBy.sizeAscending:
        result.sort((a, b) => a.size.compareTo(b.size));
        break;
      case SortFilesBy.sizeDescending:
        result.sort((b, a) => a.size.compareTo(b.size));
        break;
      case SortFilesBy.dateModifiedAscending:
        result.sort((a, b) => a.dateModified.compareTo(b.dateModified));
        break;
      case SortFilesBy.dateModifiedDescending:
        result.sort((b, a) => a.dateModified.compareTo(b.dateModified));
        break;
      case SortFilesBy.dateCreatedAscending:
        result.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      case SortFilesBy.dateCreatedDescending:
        result.sort((b, a) => a.dateCreated.compareTo(b.dateCreated));
        break;
    }
    return result;
  }

  goBackToFolder(FileData folder) {
    final folderIndex = folders.indexOf(folder);
    folders = folders.getRange(0, folderIndex).toList();
    refresh();
  }

  searchFile(String? text) {
    if (text == null || text == "") {
      state = AsyncData(currentFolderFiles);
    } else {
      state = AsyncData(currentFolderFiles.where((e) => e.name.toLowerCase().contains(text.toLowerCase())).toList());
    }
  }

  changeSortBy(SortFilesBy sortFilesByLocal) {
    sortFilesBy = sortFilesByLocal;
    if (state.value != null) {
      state = AsyncData(_sortFiles(state.valueOrNull!));
    }
  }

  refresh({FileData? folderToAdd}) {
    final folderPath = getCurrentFolderPath(folderToAdd: folderToAdd);
    ref.read(webrtcProvider.notifier).sendMessage('get_directory', folderPath);
  }

  String getCurrentFolderPath({FileData? folderToAdd}) {
    String folderPath = '';
    for (final folder in folders) {
      folderPath = "$folderPath${folder.name}/";
    }
    if (folderToAdd != null) {
      folderPath = "$folderPath${folderToAdd.name}/";
    }
    return folderPath;
  }

  openFolder(FileData folder) {
    if (folders.isEmpty) {
      folders.add(folder);
      refresh();
    } else {
      pendingDirectoryToOpen = folder;
      refresh(folderToAdd: folder);
    }
  }

  goBack() {
    folders.removeLast();
    refresh();
  }
}

final directoryProvider = AsyncNotifierProvider<DirectoryProvider, List<FileData>>(() {
  return DirectoryProvider();
});

final _directoryProvider = FutureProvider<WebrtcProviderModel>((ref) {
  final sub = ref.listen(webrtcProvider, (prev, cur) {
    if (cur.data?.type == WebrtcDataType.directory) ref.state = AsyncData(cur);
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
