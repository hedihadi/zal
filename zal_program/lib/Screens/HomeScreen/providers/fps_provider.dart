import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_stream_provider.dart';

final autoDetectGameProcessProvider = StateProvider<bool>((ref) => true);

class FpsDataNotifier extends AsyncNotifier<List<FpsData>> {
  FpsDataNotifier();
  List<ProcessData> processes = [];
  FpsDetails? fpsDetails;
  @override
  Future<List<FpsData>> build() async {
    final socket = ref.watch(_fpsDataProvider);

    final streamData = socket.value;
    //return old data if streamData is null or not fps data.
    if (streamData == null || streamData.type != StreamDataType.FPS) {
      return state.value ?? [];
    }

    final fpsData = FpsData.fromMap(streamData.data);
    //add this new process to the list if it doesn't exist
    if (processes.where((element) => element.name == fpsData.processName).isEmpty) {
      processes.add(ProcessData(id: fpsData.processId, name: fpsData.processName));
    }
    final chosenProcess = ref.read(fpsChosenProcessProvider).value;
    if (chosenProcess == null) {
      return state.value ?? [];
    }
    //if (processes.where((element) => element.name == chosenProcess.name).isEmpty) {
    //  ref.read(fpsChosenProcessProvider.notifier).state = const AsyncValue.data(null);
    //}
    if (chosenProcess.name == fpsData.processName) {
      print(chosenProcess.name);
      List<FpsData> result = [];
      result.addAll(state.value ?? []);
      result.add(fpsData);
      if (result.length >= 200) {
        result.removeAt(0);
      }
      if (result.length > 5) {
        calculateFpsDetails();
      }

      return result;
    }
    return state.value ?? [];
  }

  void calculateFpsDetails() {
    if (state.value != null) {
      List<int> fpsData = state.value!.map((e) => e.fps).toList()..sort((a, b) => a.compareTo(b));
      //now calcualte %1 and %0.1 and average
      double fps1Percent = calculatePercentile(fpsData, 0.01);
      double fps01Percent = calculatePercentile(fpsData, 0.001);

      //double fps01Percent = calculatePercentile(fpsList, 0.1);
      int totalFPS = fpsData.reduce((a, b) => a + b);
      double averageFps = totalFPS / fpsData.length;
      fpsDetails = FpsDetails(averageFps: averageFps, fps01Low: fps1Percent, fps001Low: fps01Percent);
    }
  }

  double calculatePercentile(List<int> data, double percentile) {
    double realIndex = (percentile) * (data.length - 1);
    int index = realIndex.toInt();
    double frac = realIndex - index;
    try {
      if (index + 1 < data.length) {
        return data[index] * (1 - frac) + data[index + 1] * frac;
      } else {
        return data[index].toDouble();
      }
    } catch (c) {
      return 0;
    }
  }

  reset() {
    processes.clear();
    fpsDetails = null;
    state = const AsyncValue.data([]);
  }
}

final fpsDataProvider = AsyncNotifierProvider<FpsDataNotifier, List<FpsData>>(() {
  return FpsDataNotifier();
});

class FpsChosenProcessNotifier extends AsyncNotifier<ProcessData?> {
  FpsChosenProcessNotifier();
  @override
  Future<ProcessData?> build() async {
    final data = ref.watch(localSocketProvider).value;
    if (data == null) return state.value;
    final oldChosenProcess = state.value;
    final autoDetect = ref.read(autoDetectGameProcessProvider);
    if (autoDetect == true && data.processesGpuUsage != null) {
      final processesWithGpuUsage = data.processesGpuUsage!.entries.toList();
      //sort the processes by highest gpu usage
      processesWithGpuUsage.sort((b, a) => a.value.compareTo(b.value));

      ///now choose the highest gpu usage process that exists inside the [processes] list
      final processes = ref.read(fpsDataProvider.notifier).processes;
      for (final processWithGpuUsage in processesWithGpuUsage) {
        final foundProcesses = processes.where((element) => element.id == processWithGpuUsage.key).toList();
        if (foundProcesses.isNotEmpty) {
          if (foundProcesses.first.id == oldChosenProcess?.id) break;
          ref.read(fpsDataProvider.notifier).reset();
          return foundProcesses.first;
        }
      }
    }
    return oldChosenProcess;
  }

  void chooseProcess(String processName) {
    final foundProcess = ref.read(fpsDataProvider.notifier).processes.where((element) => element.name == processName).firstOrNull;
    state = AsyncValue.data(foundProcess);
  }
}

final fpsChosenProcessProvider = AsyncNotifierProvider<FpsChosenProcessNotifier, ProcessData?>(() {
  return FpsChosenProcessNotifier();
});

///this provider only updates if the data type is [StreamDataType.FPS]
final _fpsDataProvider = FutureProvider<StreamData>((ref) {
  final sub = ref.listen(localSocketStreamProvider, (prev, cur) {
    if (cur.value?.type == StreamDataType.FPS) {
      ref.state = cur;
    } else {
      print("different");
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
