import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_stream_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_provider.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_provider.dart';
import 'package:zal/Screens/computer_screen.dart';

class LocalSocketNotifier extends AsyncNotifier<ComputerData?> {
  LocalSocketNotifier();

  @override
  Future<ComputerData?> build() async {
    ref.read(requestDataProvider);
    final socket = ref.watch(_computerDataProvider);
    final streamData = socket.value;
    if (streamData != null) {
      if (streamData.type == StreamDataType.DATA) {
        var computerData = ComputerData.construct(streamData.data,ref);
        ref.read(notificationsProvider.notifier).checkNotifications(computerData);
        if (computerData.isRunningAsAdminstrator) {
          Future.delayed(const Duration(milliseconds: 5), () => ref.read(computerSpecsProvider.notifier).saveSettings(computerData));
        }
        return computerData;
      }
    }
    return state.value;
  }

  ///TODO: calling this function within widgets causes a flash of error to occur because-
  ///we're causing the provider to update itself, so we need to make a variable for primaryGpu
  ///instead of calling a function to get it.
  Gpu? getPrimaryGpu() {
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
    final primaryGpu = gpus.where((element) => element.name == primaryGpuName);
    if (primaryGpu.isEmpty) {
      ref.read(settingsProvider.notifier).updatePrimaryGpuName(gpus.first.name);
      return gpus.first;
    } else {
      return primaryGpu.first;
    }
  }
}

final localSocketProvider = AsyncNotifierProvider<LocalSocketNotifier, ComputerData?>(() {
  return LocalSocketNotifier();
});

final _computerDataProvider = FutureProvider<StreamData>((ref) {
  final sub = ref.listen(localSocketStreamProvider, (prev, cur) {
    if (cur.value?.type == StreamDataType.DATA) ref.state = cur;
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
