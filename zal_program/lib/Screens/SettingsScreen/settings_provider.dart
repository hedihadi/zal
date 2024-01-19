import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/programs_runner.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:window_manager/window_manager.dart';

class SettingsNotifier extends AsyncNotifier<Settings> {
  bool isStartup = true;
  Future<Settings> _fetchData() async {
    final settings = await LocalDatabaseManager.loadSettings();
    if (isStartup) {
      Future.delayed(const Duration(microseconds: 1), () async {
        try {
          await ProgramsRunner.runZalConsole(settings.runAsAdmin);
        } on PathAccessException {
          showSnackbar("couldn't extract zal-console.zip, it's being used by another process", ref.read(contextProvider)!);
        }
      });
      if (settings.startMinimized && settings.runInBackground) {
        windowManager.hide();
      }
      isStartup = false;
    }

    return settings;
  }

  Future<void> saveSettings() async {
    final box = Hive.box("data");
    box.put("settings", state.value!.toJson());
    ref.invalidate(settingsProvider);
  }

  updatePersonalizedAds(bool value) {
    state = AsyncData(state.value!.copyWith(personalizedAds: value));
    saveSettings();
  }

  updateComputerName(String value) {
    state = AsyncData(state.value!.copyWith(computerName: value));
    saveSettings();
  }

  updatePrimaryGpuName(String value) {
    state = AsyncData(state.value!.copyWith(primaryGpuName: value));
    saveSettings();
  }

  updateSendAnalytics(bool value) {
    state = AsyncData(state.value!.copyWith(sendAnalaytics: value));
    saveSettings();
  }

  updateUseCelcius(bool value) {
    state = AsyncData(state.value!.copyWith(useCelcius: value));
    saveSettings();
  }

  updateRunOnStartup(bool value) {
    state = AsyncData(state.value!.copyWith(runOnStartup: value));
    if (value) {
      launchAtStartup.enable();
    } else {
      launchAtStartup.disable();
    }
    saveSettings();
  }

  updateRunInBackground(bool value) {
    state = AsyncData(state.value!.copyWith(runInBackground: value));
    saveSettings();
  }

  updateStartMinimized(bool value) {
    state = AsyncData(state.value!.copyWith(startMinimized: value));
    saveSettings();
  }

  updateRunAsAdmin(bool value) {
    state = AsyncData(state.value!.copyWith(runAsAdmin: value));
    saveSettings();
  }

  @override
  Future<Settings> build() async {
    return _fetchData();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(() {
  return SettingsNotifier();
});

final settingsTimerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(seconds: 1), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});

final runningProcessesProvider = FutureProvider<Map<String, bool>>((ref) async {
  ref.watch(settingsTimerProvider);
  final String result = (await Process.run('tasklist', [])).stdout;
  return {
    "zal-console.exe": result.contains("zal-console.exe"),
    "zal-server.exe": result.contains("zal-server.exe"),
  };
});
