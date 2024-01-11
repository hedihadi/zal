import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/charts_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'dart:async';
import 'package:zal/Screens/HomeScreen/providers/server_socket_stream_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/task_manager_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';

class ServerSocketNotifier extends AsyncNotifier<ServerSocketData> {
  ServerSocketNotifier();
  bool isMobileConnected = false;
  bool isConnected = false;
  @override
  Future<ServerSocketData> build() async {
    final socket = ref.watch(serverSocketStreamProvider);
    final streamData = socket.value;
    if (streamData != null) {
      if (streamData.type == ServerStreamDataType.connected) {
        isConnected = true;
      } else if (streamData.type == ServerStreamDataType.disconnected) {
        isConnected = false;
       
      } else if (streamData.type == ServerStreamDataType.roomClients) {
        isMobileConnected = (streamData.data as List).contains(1);
        if (isMobileConnected) {
          //send notifications to mobile
          ref.read(notificationsProvider.notifier).broadcastNotificationsToMobile();
        } else {
          ref.read(taskmanagerProvider.notifier).reset();
        }
      } else if (streamData.type == ServerStreamDataType.restartAdmin) {
        final socket = ref.read(localSocketObjectProvider)?.socket;
        socket?.emit("restart_admin");
      } else if (streamData.type == ServerStreamDataType.changePrimaryNetwork) {
        final socket = ref.read(localSocketObjectProvider)?.socket;
        socket?.emit("change_primary_network", streamData.data.toString());
      } else if (streamData.type == ServerStreamDataType.newNotification) {
        Future.delayed(const Duration(milliseconds: 1), () {
          ref.read(notificationsProvider.notifier).addNewRawNotification(streamData.data);
        });
      } else if (streamData.type == ServerStreamDataType.editNotification) {
        Future.delayed(const Duration(milliseconds: 1), () {
          ref.read(notificationsProvider.notifier).editNotification(streamData.data);
        });
      } else if (streamData.type == ServerStreamDataType.killProcess) {
        List<int> processes = List<int>.from(jsonDecode(streamData.data));
        for (final processId in processes) {
          await Process.run('taskkill', ['/F', '/PID', processId.toString()]);
        }
      }
    }
    return ServerSocketData(isConnected: isConnected, isMobileConnected: isMobileConnected);
  }
}

final serverSocketProvider = AsyncNotifierProvider<ServerSocketNotifier, ServerSocketData>(() {
  return ServerSocketNotifier();
});

final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(milliseconds: 1000), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});

final sendDataToMobileProvider = FutureProvider(
  (ref) {
    ref.watch(timerProvider);
    final charts = ref.read(chartsProvider).value;
    final isMobileConnected = ref.read(serverSocketProvider.select((value) => value.valueOrNull?.isMobileConnected ?? false));
    final computerData = ref.read(localSocketProvider).value;

    if (computerData == null || isMobileConnected == false) return;

    ref.read(serverSocketObjectProvider).value!.socket.emit("pc_data", {
      'data': compressGzip(jsonEncode({
        'computerData': computerData.parsedData,
        'charts': charts,
        'taskmanagerData': ref.read(taskmanagerProvider.notifier).getParsedProcesses()
      }))
    });
  },
);
