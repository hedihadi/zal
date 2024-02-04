import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';

class ReportErrorWidget extends ConsumerWidget {
  const ReportErrorWidget({super.key, required this.error});
  final ErrorParsingComputerData error;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            final backendData = error.data;
            String logData = error.error.toString();

            showSnackbar('sending...', context);
            final response = await AnalyticsManager.sendDataToDatabase(
              'error',
              data: {
                'data': backendData,
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
  }
}
