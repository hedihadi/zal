import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';

class ReportErrorWidget extends ConsumerWidget {
  const ReportErrorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSocket = ref.watch(localSocketProvider);
    return localSocket.when(
      skipLoadingOnReload: true,
      data: (data) {
        return Container();
      },
      error: (error, stackTrace) {
        return Column(
          children: [
            Text(
              "Error Detected",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              "Would you like to submit a report? \nYour report will be significant help.",
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: () async {
                final backendData = ref.read(localSocketProvider.notifier).rawData;
                Directory tempDir = await getTemporaryDirectory();
                String logData = '';
                try {
                  final File logFile = File("${tempDir.path}/zal_log.txt");
                  logData = await logFile.readAsString();
                } catch (c) {
                  showSnackbar('failed to read log: $c', context);
                }
                showSnackbar('sending...', context);
                final response = await AnalyticsManager.sendDataToDatabase(
                  'error',
                  data: {
                    'data': backendData ?? '',
                    'log': logData,
                  },
                );
                if (response.statusCode == 200) {
                  showSnackbar('sent!', context);
                } else {
                  showSnackbar('error sending data, server returned ${response.statusCode}', context);
                }
              },
              child: const Text("report error"),
            ),
          ],
        );
      },
      loading: () {
        return Container();
      },
    );
  }
}
