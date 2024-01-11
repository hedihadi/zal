import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

final serverSocketStreamProvider = StreamProvider<ServerStreamData>((ref) async* {
  StreamController stream = StreamController();

  final socket = ref.watch(serverSocketObjectProvider).value;
  if (socket == null) return;
  socket.socket.on('room_clients', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.roomClients, data: data));
  });
  socket.socket.on('new_notification', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.newNotification, data: data));
  });
  socket.socket.on('edit_notification', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.editNotification, data: data));
  });
  socket.socket.on('change_primary_network', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.changePrimaryNetwork, data: data));
  });
  socket.socket.on('kill_process', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.killProcess, data: data));
  });
  socket.socket.on('restart_admin', (data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.restartAdmin, data: data));
  });
  socket.socket.onConnect((data) {
    stream.add(ServerStreamData(type: ServerStreamDataType.connected, data: data));
  });

  socket.socket.onDisconnect((data) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
    stream.add(ServerStreamData(type: ServerStreamDataType.disconnected, data: data));
  });
  socket.socket.onReconnectFailed((data) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
  });
  socket.socket.onReconnectError((data) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
  });
  await for (final value in stream.stream) {
    if (value != null) {
      yield value as ServerStreamData;
    }
  }
});

final serverSocketObjectProvider = FutureProvider<ServerSocketio?>((ref) async {
  final uid = ref.watch(userProvider).value?.id;
  final idToken = ((await HiveStore.create())..read()).idToken;
  if ([uid, idToken].contains(null)) return null;
  return ServerSocketio(uid!, idToken!);
});
