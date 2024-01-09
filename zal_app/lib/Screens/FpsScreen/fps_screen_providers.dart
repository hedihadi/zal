import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import '../../Functions/models.dart';

class FpsDataNotifier extends AutoDisposeAsyncNotifier<FpsData> {
  Future<FpsData> _fetchData(FpsData fpsData, String data) async {
    final uncompressedString = decompressGzip(data);
    final parsedData = jsonDecode(uncompressedString);
    String? processName;
    for (final string in parsedData) {
      final parsedString = Map<String, dynamic>.from(jsonDecode(string)).entries.first;
      processName = parsedString.key;
      if (state.value?.processName != processName) {
        //this is a new process, let's reset
        reset();
      }
      final msBetweenDisplayChange = double.parse(parsedString.value);
      fpsData.fpsList.add((1000 / msBetweenDisplayChange).toPrecision(2));
    }
    fpsData.fpsList.sort((a, b) => a.compareTo(b));
    double fps1Percent = calculatePercentile(fpsData.fpsList, 0.01);
    double fps01Percent = calculatePercentile(fpsData.fpsList, 0.001);

    //double fps01Percent = calculatePercentile(fpsList, 0.1);
    double totalFPS = fpsData.fpsList.reduce((a, b) => a + b);
    double averageFPS = totalFPS / fpsData.fpsList.length;

    return fpsData.copyWith(
        processName: processName, fps: averageFPS.toPrecision(2), fps01Low: fps1Percent.toPrecision(2), fps001Low: fps01Percent.toPrecision(2));
  }

  void reset() {
    ref.read(fpsTimeElapsedProvider.notifier).stopwatch = Stopwatch()..start();
    state = AsyncData(state.value!.copyWith(fpsList: [], fps: 0, fps001Low: 0, fps01Low: 0));
  }

  double calculatePercentile(List<double> data, double percentile) {
    double realIndex = (percentile) * (data.length - 1);
    int index = realIndex.toInt();
    double frac = realIndex - index;
    if (index + 1 < data.length) {
      return data[index] * (1 - frac) + data[index + 1] * frac;
    } else {
      return data[index];
    }
  }

  @override
  Future<FpsData> build() async {
    final socket = ref.watch(computerSocketStreamProvider);
    final streamData = socket.value;
    final isFpsPaused = ref.watch(isFpsPausedProvider);
    final FpsData fpsData = state.value ??
        FpsData(
          processName: null,
          fpsList: [],
          fps: 0,
          fps01Low: 0,
          fps001Low: 0,
        );

    if (isFpsPaused == false && streamData?.type == StreamDataType.FPS) {
      return _fetchData(fpsData, streamData!.data);
    }
    return state.value ?? fpsData;
  }
}

final fpsDataProvider = AsyncNotifierProvider.autoDispose<FpsDataNotifier, FpsData>(() {
  return FpsDataNotifier();
});

class FpsRecordsNotifier extends StateNotifier<List<FpsRecord>> {
  dynamic ref;
  FpsRecordsNotifier({required this.ref}) : super([]);
  void addPreset(FpsData fpsData, String presetName, String? note) {
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
