import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'dart:async';

class ChartsNotifier extends AsyncNotifier<Map<String, List<num>>> {
  ChartsNotifier();
  @override
  Future<Map<String, List<num>>> build() async {
    final computerData = ref.watch(localSocketProvider).valueOrNull;
    final primaryGpu = ref.watch(localSocketProvider.notifier).getPrimaryGpu();
    final Map<String, List<num>> data = state.valueOrNull ?? {};
    if (computerData == null) return data;

    data['gpuLoad'] = addEelementToList(data['gpuLoad'], primaryGpu?.corePercentage ?? 0);
    data['gpuTemperature'] = addEelementToList(data['gpuTemperature'], primaryGpu?.temperature ?? 0);
    data['gpuPower'] = addEelementToList(data['gpuPower'], primaryGpu?.power ?? 0);

    data['cpuLoad'] = addEelementToList(data['cpuLoad'], computerData.cpu.load);
    data['cpuTemperature'] = addEelementToList(data['cpuTemperature'], computerData.cpu.temperature ?? 0);

    data['ramPercentage'] = addEelementToList(data['ramPercentage'], computerData.ram.memoryUsedPercentage);
    data['networkDownload'] = addEelementToList(data['networkDownload'], ((computerData.networkSpeed?.download ?? 0) / 1024 / 1024));
    data['networkUpload'] = addEelementToList(data['networkUpload'], ((computerData.networkSpeed?.upload ?? 0) / 1024 / 1024));

    return data;
  }

  List<num> addEelementToList(List<num>? oldList, num element) {
    const maxElements = 60;
    final newList = List<num>.from(oldList ?? []);
    newList.add(element);
    if (newList.length > maxElements) {
      newList.removeAt(0);
    }
    return newList;
  }
}

final chartsProvider = AsyncNotifierProvider<ChartsNotifier, Map<String, List<num>>>(() {
  return ChartsNotifier();
});
