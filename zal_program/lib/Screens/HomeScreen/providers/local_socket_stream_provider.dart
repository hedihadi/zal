import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

final localSocketStreamProvider = StreamProvider<StreamData>((ref) async* {
  StreamController stream = StreamController();
  final socket = ref.watch(localSocketObjectProvider);
  if (socket != null) {
    socket.socket.on('computer_data', (data) {
      stream.add(StreamData(type: StreamDataType.DATA, data: data));
    });
    socket.socket.on('fps_data', (data) {
      stream.add(StreamData(type: StreamDataType.FPS, data: data));
    });
  }

  await for (final value in stream.stream) {
    if (value != null) {
      yield value as StreamData;
    }
  }
});

final requestDataProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(milliseconds: 1000), (count) {
    ref.read(localSocketObjectProvider.notifier).state?.socket.emit("get_data");
    return stopwatch.elapsed.inSeconds;
  });
});
