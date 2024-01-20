import 'dart:convert';

import 'package:collection/collection.dart';
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
    print("payload size: ${sizeInBytes.toSize()}");
    final computerData = ComputerData.construct(decompressGzip(data));
    return computerData;
  }

  @override
  Future<ComputerData> build() async {    final webrtcProviderModel = await ref.watch(_computerDataProvider.future);
    final data = await _fetchData(webrtcProviderModel.data?.data ?? '');
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
