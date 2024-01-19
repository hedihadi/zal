import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

final isConnectedToServerProvider = StateProvider<bool>((ref) => false);

final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(milliseconds: 1000), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});

final computerSocketStreamProvider = StreamProvider<StreamData>((ref) async* {
  StreamController stream = StreamController();
  showSnackbarLocal(String text) {
    final context = ref.read(contextProvider);
    if (context != null) showSnackbar(text, context);
  }

  final socket = ref.watch(socketObjectProvider);
  if (socket != null) {
    socket.socket.onConnect((data) {
      ref.read(isConnectedToServerProvider.notifier).state = true;
      //showSnackbarLocal("Server Connected");
    });
    socket.socket.onDisconnect((data) {
      ref.read(isConnectedToServerProvider.notifier).state = false;
      print("disconnected");
      showSnackbarLocal("Server Disconnected");
    });
    socket.socket.on('accept_answer', (data) {
      ref.read(webrtcProvider.notifier).acceptAnswer(data);
    });
    socket.socket.on('room_clients', (data) {
      stream.add(StreamData(type: StreamDataType.RoomClients, data: data));
    });
  }

  await for (final value in stream.stream) {
    if (value != null) {
      yield value as StreamData;
    }
  }
});

final socketObjectProvider = StateProvider<SocketObject?>((ref) {
  final socket = ref.watch(_socketProvider);

  return socket.value;
});
final _socketProvider = FutureProvider((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.value != null) {
    final idToken = await auth.value!.getIdToken();
    if (idToken != null) {
      return SocketObject(auth.value!.uid, idToken);
    }
  }
  return null;
});
