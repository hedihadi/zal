import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/ConnectedScreen/connected_screen_providers.dart';
import 'package:zal/Screens/FpsScreen/Widgets/select_gpu_process_widget.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import '../../Functions/models.dart';

class FpsDataNotifier extends AutoDisposeAsyncNotifier<FpsData> {
  Stopwatch stopwatch = Stopwatch()..start();
  Future<FpsData> _fetchData(FpsData fpsData, String data) async {
    final List<double> parsedData = List<double>.from(jsonDecode(data));
    final average = parsedData.reduce((value, element) => element + value);
    final currentFps = average / parsedData.length;
    for (final data in parsedData) {
      //try {
      //  final a = ref.read(aProvider);
      //  ref.read(aProvider.notifier).state = [...ref.read(aProvider), data];
      //  if (a.length > 150) {
      //    ref.read(aProvider.notifier).state.removeAt(0);
      //  }
      //} catch (c) {
      //  print(c);
      //}
      fpsData.addFps(data);
    }
    fpsData.calculateFps();
    fpsData.currentFps = currentFps;
    ref.read(fpsChartProvider.notifier).addList(parsedData, stopwatch.elapsedMilliseconds);
    stopwatch.reset();
    return fpsData;
  }

  void reset() async {
    ref.read(fpsTimeElapsedProvider.notifier).stopwatch = Stopwatch()..start();
    ref.invalidate(fpsComputerDataProvider);
    ref.invalidate(_fpsComputerDataProvider);
    state = AsyncData(FpsData(fpsList: [], currentFps: 0, averageFps: 0, fps001Low: 0, fps01Low: 0));
  }

  Future<void> showChooseGameDialog({bool dismissible = true}) async {
    ref.read(socketProvider.notifier).sendMessage("get_gpu_processes", "");
    // ref.invalidate(gpuProcessesProvider);
    final context = ref.read(contextProvider);
    AlertDialog alert = const AlertDialog(
      content: SelectGpuProcessWidget(),
    );

    await showDialog(
      barrierDismissible: dismissible,
      context: context!,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Future<FpsData> build() async {
    final streamData = await ref.watch(_fpsDataProvider.future);
    final isFpsPaused = ref.watch(isFpsPausedProvider);
    final FpsData fpsData = state.value ??
        FpsData(
          fpsList: [],
          currentFps: 0,
          averageFps: 0,
          fps01Low: 0,
          fps001Low: 0,
        );

    if (isFpsPaused == false) {
      return _fetchData(fpsData, streamData);
    }
    return state.value ?? fpsData;
  }
}

final _fpsDataProvider = FutureProvider<String>((ref) {
  final sub = ref.listen(socketStreamProvider, (prev, cur) {
    if (cur.valueOrNull?.type == SocketDataType.fpsData) {
      ref.state = AsyncData(cur.valueOrNull!.data);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
final fpsDataProvider = AsyncNotifierProvider.autoDispose<FpsDataNotifier, FpsData>(() {
  return FpsDataNotifier();
});

class FpsRecordsNotifier extends StateNotifier<List<FpsRecord>> {
  dynamic ref;
  FpsRecordsNotifier({required this.ref}) : super([]);
  void addPreset(FpsData fpsData, String presetName, String? note) {
    fpsData = FpsData(
        fpsList: [], averageFps: fpsData.averageFps, currentFps: fpsData.currentFps, fps01Low: fpsData.fps01Low, fps001Low: fpsData.fps001Low);
    state = [
      FpsRecord(fpsData: fpsData, presetDuration: formatTime((ref.read(fpsTimeElapsedProvider)).value), presetName: presetName, note: note),
      ...state,
    ];
  }

  void removePreset(FpsRecord fpsRecord) {
    state = state.where((element) => element != fpsRecord).toList();
  }
}

final fpsRecordsProvider = StateNotifierProvider<FpsRecordsNotifier, List<FpsRecord>>((ref) {
  return FpsRecordsNotifier(ref: ref);
});

final isFpsPausedProvider = StateProvider<bool>((ref) => false);

class FpsTimeElapsedNotifier extends AutoDisposeAsyncNotifier<int> {
  Stopwatch stopwatch = Stopwatch()..start();
  @override
  Future<int> build() async {
    //subscribe to this timer to update this provider every 1 second
    ref.watch(timerProvider);
    final isFpsPaused = ref.watch(isFpsPausedProvider);
    if (isFpsPaused) {
      stopwatch.stop();
    } else {
      stopwatch.start();
    }
    return stopwatch.elapsed.inSeconds;
  }
}

final fpsTimeElapsedProvider = AsyncNotifierProvider.autoDispose<FpsTimeElapsedNotifier, int>(() {
  return FpsTimeElapsedNotifier();
});

final gpuProcessesProvider = FutureProvider<List<GpuProcess>>((ref) {
  final sub = ref.listen(socketStreamProvider, (prev, cur) {
    if (cur.valueOrNull?.type == SocketDataType.gpuProcesses) {
      final parsedData = Map<String, dynamic>.from(jsonDecode(cur.valueOrNull!.data));
      List<GpuProcess> processes = [];
      for (final data in parsedData.entries) {
        processes.add(GpuProcess.fromMap(data));
      }
      processes.sort((b, a) => a.usage.compareTo(b.usage));
      ref.state = AsyncData(processes);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});

final selectedGpuProcessProvider = StateProvider.autoDispose<GpuProcess?>((ref) => null);

final _fpsComputerDataProvider = StateProvider<Map<String, num>>((ref) => {});

final fpsComputerDataProvider = StateProvider<FpsComputerData>((ref) {
  final oldData = ref.watch(_fpsComputerDataProvider);
  final computerData = ref.watch(computerDataProvider).value!;
  final gpu = computerData.gpu;
  final cpu = computerData.cpu;
  if (gpu.coreSpeed > (oldData['gpu.coreSpeed'] ?? 0)) {
    oldData['gpu.coreSpeed'] = gpu.coreSpeed;
  }
  if (gpu.memorySpeed > (oldData['gpu.memorySpeed'] ?? 0)) {
    oldData['gpu.memorySpeed'] = gpu.memorySpeed;
  }
  if (gpu.dedicatedMemoryUsed > (oldData['gpu.dedicatedMemoryUsed'] ?? 0)) {
    oldData['gpu.dedicatedMemoryUsed'] = gpu.dedicatedMemoryUsed;
  }
  if (gpu.power > (oldData['gpu.power'] ?? 0)) {
    oldData['gpu.power'] = gpu.power;
  }
  if (gpu.voltage > (oldData['gpu.voltage'] ?? 0)) {
    oldData['gpu.voltage'] = gpu.voltage;
  }
  if (gpu.fanSpeedPercentage > (oldData['gpu.fanSpeedPercentage'] ?? 0)) {
    oldData['gpu.fanSpeedPercentage'] = gpu.fanSpeedPercentage;
  }
  if (gpu.temperature > (oldData['gpu.temperature'] ?? 0)) {
    oldData['gpu.temperature'] = gpu.temperature;
  }
  if (gpu.corePercentage > (oldData['gpu.corePercentage'] ?? 0)) {
    oldData['gpu.corePercentage'] = gpu.corePercentage;
  }
  if (cpu.load > (oldData['cpu.load'] ?? 0)) {
    oldData['cpu.load'] = cpu.load;
  }
  if (cpu.power > (oldData['cpu.power'] ?? 0)) {
    oldData['cpu.power'] = cpu.power;
  }
  if ((cpu.temperature ?? 0) > (oldData['cpu.temperature'] ?? 0)) {
    oldData['cpu.temperature'] = (cpu.temperature ?? 0);
  }
  ref.read(_fpsComputerDataProvider.notifier).state = oldData;
  return FpsComputerData(computerData: computerData, highestValues: oldData);
});

class FpsChartNotifier extends StateNotifier<List<double>> {
  dynamic ref;
  FpsChartNotifier({required this.ref}) : super([]);
  Future<void> addList(List<double> fpsList, int timeFromLastData) async {
    final delay = timeFromLastData / fpsList.length;
    for (final fps in fpsList) {
      state = [...state, fps];
      if (state.length > 150) {
        state.removeAt(0);
      }
      await Future.delayed(Duration(milliseconds: delay.toInt()));
    }
  }
}

final fpsChartProvider = StateNotifierProvider<FpsChartNotifier, List<double>>((ref) {
  return FpsChartNotifier(ref: ref);
});
