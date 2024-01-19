import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/first_row_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_speed_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/storages_widget.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';

final sidebarSelectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 5),
        const ReportErrorWidget(),
        ElevatedButton(
            onPressed: () {
              final data = ref.read(webrtcProvider.notifier).webrtc.sendMessage('hiii');
            },
            child: const Text("send")),
        const FirstRowWidget(),
        SizedBox(height: 2.h),
        const Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: NetworkSpeedWidget(),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 150,
                child: BatteryWidget(),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        const StoragesWidget(),
        //SizedBox(height: 40.h, child: const FpsWidget()),
      ],
    );
  }
}
