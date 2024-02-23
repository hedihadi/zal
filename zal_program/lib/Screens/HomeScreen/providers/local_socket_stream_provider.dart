import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';
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
    socket.socket.on('directory', (data) {
      ref.read(webrtcProvider.notifier).sendMessage('directory', data);
    });
    socket.socket.on('file', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('file', data);
    });
    socket.socket.on('file_complete', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('file_complete', data);
    });
    socket.socket.on('information_text', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('information_text', data);
    });
    socket.socket.on('gpu_processes', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('gpu_processes', data);
    });
    socket.socket.on('fps_data', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('fps_data', data);
    });
    socket.socket.on('program_times', (data) async {
      AnalyticsManager.sendDataToDatabase('program-times', data: {'programs': data});
    });
    socket.socket.on('process_icon', (data) async {
      await ref.read(webrtcProvider.notifier).sendMessage('process_icon', data);
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
