import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';

class SocketNotifier extends AsyncNotifier<ComputerData> {
  bool isProgramRunningAsAdminstrator = true;
  bool isConnected = false;
  bool isComputerConnected = false;
  int elpasedTime = 0;
  Future<ComputerData> _fetchData(String data) async {
    List<int> utf8Bytes = utf8.encode(data);
    // Get the length of the byte array
    int sizeInBytes = utf8Bytes.length;
    print("payload size: ${sizeInBytes.toSize()}");

    final computerData = ComputerData.construct(decompressGzip(data));
    return computerData;
  }

  @override
  Future<ComputerData> build() async {
    final socket = ref.watch(computerSocketStreamProvider);
    isConnected = ref.watch(isConnectedProvider);
    if (elpasedTime <= 3) {
      elpasedTime = ref.watch(timerProvider).value ?? 0;
    }
    final streamData = socket.value;
    if (isConnected == false) {
      return attemptToReturnOldData(NotConnectedToSocketException());
    }
    if (streamData != null) {
      if (streamData.type == StreamDataType.RoomClients) {
        if (List<int>.from(streamData.data).contains(0) == false) {
          isComputerConnected = false;
          showSnackbarLocal("Computer Disconnected");

          return attemptToReturnOldData(ComputerOfflineException());
        }
        isComputerConnected = true;
        showSnackbarLocal("Computer Connected");
      }

      if (streamData.type == StreamDataType.DATA) {
        try {
          final data = await _fetchData(streamData.data);
          if (data.cpu.clocks.containsValue(null) && data.cpu.temperature == null) {
            isProgramRunningAsAdminstrator = false;
          } else {
            isProgramRunningAsAdminstrator = true;
            //if program is running as adminstrator, that means we have all the data available, let's save it.
            ref.read(computerSpecsProvider.notifier).saveSettings(data);
          }
          isComputerConnected = true;

          return data;
        } on Exception {
          throw ErrorParsingComputerData(streamData.data);
        }
      }
    }
    if (isComputerConnected == false) {
      return attemptToReturnOldData(ComputerOfflineException());
    }
    return attemptToReturnOldData(DataIsNullException());
  }

  showSnackbarLocal(String text) {
    final context = ref.read(contextProvider);
    if (context != null) showSnackbar(text, context);
  }

  ComputerData attemptToReturnOldData(Exception ifNull) {
    if (state.value != null) {
      return state.value!;
    }
    //dont show any error until at least 3 seconds has passed since launch of the app.
    if ((ref.read(timerProvider).value ?? 0) <= 3) {
      throw TooEarlyToReturnError();
    }
    throw ifNull;
  }

  stressTest(String stressTestType, int seconds, {Map<String, dynamic> extraQuery = const {}}) {
    final Map<String, dynamic> data = {
      'type': stressTestType,
      'seconds': seconds,
    };
    data.addAll(extraQuery);
    ref.read(socketObjectProvider.notifier).state!.sendData("stress_test", jsonEncode(data));
  }

  ///TODO: calling this function within widgets causes a flash of error to occur because-
  ///we're causing the provider to update itself, so we need to make a variable for primaryGpu
  ///instead of calling a function to get it.
  Gpu? getPrimaryGpu() {
    try {
      final settings = ref.read(settingsProvider).value;
      final gpus = state.value?.gpus;
      if ([settings, gpus].contains(null) || gpus!.isEmpty) return null;
      String? primaryGpuName = settings!.primaryGpuName;
      if (primaryGpuName == null) {
        //assign the first gpu as primary
        ref.read(settingsProvider.notifier).updatePrimaryGpuName(gpus.first.name);
        primaryGpuName = gpus.first.name;
      }
      //try to find the primary gpu. if we fail, we'll assign the first gpu as primary
      final primaryGpu = gpus.firstWhereOrNull((element) => element.name == primaryGpuName);
      if (primaryGpu == null) {
        ref.read(settingsProvider.notifier).updatePrimaryGpuName(gpus.first.name);
        return gpus.first;
      } else {
        return primaryGpu;
      }
    } catch (c) {}
    return null;
  }
}

///we use this provider to see how much time has passed since the launch of the app,
///if the app is just recently launched, we will not show "not connected to server" errors
///until a few seconds has passed.
final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(seconds: 1), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});
final socketProvider = AsyncNotifierProvider<SocketNotifier, ComputerData>(() {
  return SocketNotifier();
});

final isConnectedProvider = StateProvider<bool>((ref) => false);

final computerSocketStreamProvider = StreamProvider<StreamData>((ref) async* {
  StreamController stream = StreamController();
  showSnackbarLocal(String text) {
    final context = ref.read(contextProvider);
    if (context != null) showSnackbar(text, context);
  }

  final socket = ref.watch(socketObjectProvider);
  if (socket != null) {
    socket.socket.on('pc_data', (data) {
      stream.add(StreamData(type: StreamDataType.DATA, data: data));
    });
    socket.socket.on('notifications', (data) {
      stream.add(StreamData(type: StreamDataType.Notifications, data: data));
    });
    socket.socket.onConnect((data) {
      ref.read(isConnectedProvider.notifier).state = true;
      print("connected");
      showSnackbarLocal("Server Connected");
    });
    socket.socket.onDisconnect((data) {
      ref.read(isConnectedProvider.notifier).state = false;
      print("disconnected");
      showSnackbarLocal("Server Disconnected");
    });

    socket.socket.on('fps_data', (data) {
      stream.add(StreamData(type: StreamDataType.FPS, data: data));
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
