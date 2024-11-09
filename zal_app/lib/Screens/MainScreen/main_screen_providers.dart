import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/InitialConnectionScreen/initial_connection_screen_providers.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import '../../Functions/analytics_manager.dart';

class IsUserPremiumNotifier extends StateNotifier<bool> {
  bool didSendUserData = false;
  IsUserPremiumNotifier() : super(true) {
    checkUserForSubscriptions();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      checkUserForSubscriptions();
    });
  }
  checkUserForSubscriptions() {
    Purchases.getCustomerInfo().then((value) async {
      if (value.activeSubscriptions.isNotEmpty) {
        state = true;
      } else {
        state = false;
      }
      if (didSendUserData == false) {
        try {
          await AnalyticsManager.sendUserDataToDatabase(state);
          didSendUserData = true;
        } catch (c) {
          Logger().i("failed sending data to database");
        }
      }
    });
  }
}

final isUserPremiumProvider = StateNotifierProvider<IsUserPremiumNotifier, bool>((ref) {
  return IsUserPremiumNotifier();
});

final contextProvider = StateProvider<BuildContext?>((ref) => null);

class SocketObjectNotifier extends AsyncNotifier<SocketObject?> {
  ComputerAddress? currentAddress;
  String mobileName = 'Default Mobile Name';

  Future<void> setMobileName() async {
    if (Platform.isAndroid) {
      final info = (await DeviceInfoPlugin().androidInfo);
      mobileName = info.model;
    }
    if (Platform.isIOS) {
      final info = (await DeviceInfoPlugin().iosInfo);
      mobileName = info.model;
    }
  }

  @override
  Future<SocketObject?> build() async {
    await setMobileName();
    return null;
  }

  connect(ComputerAddress? address, {String? manualAddress, bool forceConnect = false}) {
    if (!forceConnect) {
      if (currentAddress == address) return;
    }
    if (state.valueOrNull != null) {
      state.valueOrNull!.socket.disconnect();
      state.valueOrNull!.socket.dispose();
    }
    currentAddress = address;
    if (address != null) {
      ref.read(settingsProvider.notifier).updateSettings('address', address.toJson());
    }
    state = AsyncData(SocketObject(address?.ip ?? "http://$manualAddress/", extraQueries: {'name': mobileName, 'type': 'mobile'}));
  }

  sendMessage(String key, dynamic value) {
    state.valueOrNull?.socket.emit(key, value);
  }

  disconnect() {
    currentAddress = null;
    state.valueOrNull?.socket.disconnect();
    state.valueOrNull?.socket.dispose();
    ref.invalidateSelf();
  }
}

final socketProvider = AsyncNotifierProvider<SocketObjectNotifier, SocketObject?>(() {
  return SocketObjectNotifier();
});

final socketStreamProvider = StreamProvider<SocketData>((ref) async* {
  StreamController stream = StreamController();
  showSnackbarLocal(String text) {
    final context = ref.read(contextProvider);
    if (context != null) showSnackbar(text, context);
  }

  final socket = ref.watch(socketProvider).valueOrNull;
  if (socket != null) {
    socket.socket.onConnect((data) {
      ref.read(isConnectedToServerProvider.notifier).state = true;
      showSnackbarLocal("Server Connected");
    });
    socket.socket.onConnectError((a) {
      showSnackbarLocal("Connection error:${a.toString()}");
    });
    socket.socket.onDisconnect((data) {
      ref.read(isConnectedToServerProvider.notifier).state = false;
      //ref.read(socketProvider).valueOrNull?.socket.connect();
      showSnackbarLocal("Server Disconnected");
    });
    socket.socket.on("message", (data) {
      // ref.read(webrtcProvider.notifier).messageReceived(RTCDataChannelMessage(data));
    });
    socket.socket.on("room_clients", (data) {
      for (Map<String, dynamic> client in data) {
        if (client['type'] == 'computer') {
          showSnackbarLocal("Connected to ${client['name']}!");

          ref.read(isConnectedToServerProvider.notifier).state = true;
          return;
        }
      }
      showSnackbarLocal("Connected to Server, but no PC is online!");
// stream.add(SocketData(type: SocketDataType.roomClients, data: data != 0 ? [0, 1] : [1]));
    });
    socket.socket.on('pc_data', (data) {
      stream.add(SocketData(type: SocketDataType.pcData, data: data));
    });
    socket.socket.on('gpu_processes', (data) {
      stream.add(SocketData(type: SocketDataType.gpuProcesses, data: data));
    });
    socket.socket.on('fps_data', (data) {
      stream.add(SocketData(type: SocketDataType.fpsData, data: data));
    });
    socket.socket.on('process_icon', (data) {
      stream.add(SocketData(type: SocketDataType.processIcon, data: data));
    });
    socket.socket.on('information_text', (data) {
      stream.add(SocketData(type: SocketDataType.informationText, data: data));
    });
    await for (final value in stream.stream) {
      if (value != null) {
        yield value as SocketData;
      }
    }
  }
});
