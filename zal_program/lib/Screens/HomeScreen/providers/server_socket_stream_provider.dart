import 'package:firedart/auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Screens/HomeScreen/providers/log_list_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_provider.dart';

final serverSocketStreamProvider = StreamProvider<void>((ref) async* {
  final socket = ref.watch(serverSocketObjectProvider).value;
  if (socket == null) return;
  socket.socket.on('room_clients', (data) {
    ref.read(logListProvider.notifier).addElement('received room_clients from server: ${data.toString()}');
  });
  socket.socket.on('offer_sdp', (data) {
    ref.read(webrtcProvider.notifier).answerConnection(data);
  });

  socket.socket.onConnect((data) {
    ref.read(logListProvider.notifier).addElement('connected to server');
  });

  socket.socket.onDisconnect((data) {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.invalidate(serverSocketObjectProvider);
        //   ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
    ref.read(logListProvider.notifier).addElement('disconnected from server');
  });
  socket.socket.onReconnectFailed((data) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.invalidate(serverSocketObjectProvider);
        //ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
  });
  socket.socket.onReconnectError((data) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (ref.read(serverSocketObjectProvider).value?.socket.disconnected ?? false) {
        ref.invalidate(serverSocketObjectProvider);
        //ref.read(serverSocketObjectProvider).value?.socket.connect();
      }
    });
  });
  //await for (final value in stream.stream) {
  //  if (value != null) {
  //    yield value as ServerStreamData;
  //  }
  //}
});

final serverSocketObjectProvider = FutureProvider<ServerSocketio?>((ref) async {
  final uid = ref.watch(userProvider).value?.id;
  final idToken = await FirebaseAuth.instance.tokenProvider.idToken;
  final computerName = ref.read(settingsProvider).valueOrNull?.computerName ?? 'Personal Computer';
  if ([uid, idToken].contains(null)) return null;
  return ServerSocketio(uid!, idToken, computerName);
});
