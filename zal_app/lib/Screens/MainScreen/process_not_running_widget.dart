import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

class ProcessNotRunningWidget extends ConsumerStatefulWidget {
  const ProcessNotRunningWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProcessNotRunningWidgetState();
}

class _ProcessNotRunningWidgetState extends ConsumerState<ProcessNotRunningWidget> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(areProcessesRunningProvider);
    return data.when(
      data: (data) {
        if (data.values.contains(false) == false) Navigator.of(context).pop();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...data.entries.map<Widget>(
              (e) {
                if (e.value == true) return Container();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "(${e.key}) is not running on your PC, Zal will not work properly without this process. please run the process to solve this issue."),
                    ElevatedButton(
                        onPressed: () {
                          ref.read(webrtcProvider.notifier).sendMessage("run_process", e.key);
                        },
                        child: Text("run ${e.key}")),
                  ],
                );
              },
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        return Text(error.toString());
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
