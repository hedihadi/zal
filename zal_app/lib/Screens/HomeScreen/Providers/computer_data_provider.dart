import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:color_print/color_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';

class ComputerDataNotifier extends AsyncNotifier<ComputerData> {
  bool isProgramRunningAsAdminstrator = true;
  bool isConnectedToServer = false;
  bool isComputerConnected = false;
  int elpasedTime = 0;
  Future<ComputerData> _fetchData(String data) async {
    List<int> utf8Bytes = utf8.encode(data);
    // Get the length of the byte array
    int sizeInBytes = utf8Bytes.length;
    //print("payload 1size: ${sizeInBytes.toSize()}");
    print(data);
    final decompressed = decompressGzip(data);
    final computerData = ComputerData.construct(decompressed);
    return computerData;
  }

  @override
  Future<ComputerData> build() async {
    final webrtcProviderModel = await ref.watch(_computerDataProvider.future);
    late ComputerData data;
    try {
      data = await _fetchData(webrtcProviderModel.data?.data ?? '');
    } catch (c) {
      print(c);
      throw ErrorParsingComputerData(webrtcProviderModel.data?.data ?? '', c);
    }
    if (data.isRunningAsAdminstrator) {
      Future.delayed(const Duration(milliseconds: 100), () {
        ref.read(computerSpecsProvider.notifier).saveSettings(data);
      });
    }
    return data;
  }

  showSnackbarLocal(String text) {
    final context = ref.read(contextProvider);
    if (context != null) showSnackbar(text, context);
  }

  ComputerData attemptToReturnOldData(Exception ifNull) {
    if (state.value != null) {
      return state.value!;
    }
    throw ifNull;
  }
}

final computerDataProvider = AsyncNotifierProvider<ComputerDataNotifier, ComputerData>(() {
  return ComputerDataNotifier();
});

final _computerDataProvider = FutureProvider<WebrtcProviderModel>((ref) {
  final sub = ref.listen(webrtcProvider, (prev, cur) {
    if (cur.data?.type == WebrtcDataType.pcData) ref.state = AsyncData(cur);
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
