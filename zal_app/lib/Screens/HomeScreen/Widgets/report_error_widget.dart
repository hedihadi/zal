import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/models.dart';

final sendReportProvider = FutureProvider((ref) async {
  final data = ref.watch(reportTextProvider);
  if (data == null) return false;
  await AnalyticsManager.logEvent('error-parsing-data', options: {'data': data}, ignoreSettings: true);
});
final reportTextProvider = StateProvider<String?>((ref) => null);

class ReportErrorWidget extends ConsumerWidget {
  const ReportErrorWidget({super.key, required this.error});
  final Object? error;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("error parsing the data from your Computer, would you like to report this? your report will help us improve the App.",
            textAlign: TextAlign.center),
        ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("sending report..."), behavior: SnackBarBehavior.floating));
              ref.read(reportTextProvider.notifier).state = (error as ErrorParsingComputerData).data;
              ref.refresh(sendReportProvider);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("report sent, thank you!"), behavior: SnackBarBehavior.floating));
            },
            child: const Text("Send Report")),
      ],
    );
  }
}
