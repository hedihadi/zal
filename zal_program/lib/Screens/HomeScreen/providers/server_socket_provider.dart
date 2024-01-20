import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/charts_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'dart:async';
import 'package:zal/Screens/HomeScreen/providers/task_manager_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';

final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(milliseconds: 1000), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});

final sendDataToMobileProvider = FutureProvider(
  (ref) {
    ref.watch(timerProvider);
    final charts = ref.read(chartsProvider).value;
    final computerData = ref.read(localSocketProvider).value;

    if (computerData == null) return;
    ref.read(webrtcProvider.notifier).sendMessage(
          'pc_data',
          compressGzip(
            jsonEncode(
              {
                'computerData': computerData.parsedData,
                'charts': charts,
                'taskmanagerData': ref.read(taskmanagerProvider.notifier).getParsedProcesses()
              },
            ),
          ),
        );
  },
);
