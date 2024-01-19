import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/cpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/gpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/is_program_adminstrator_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/ram_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/storage_widget.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

class HomeScreenConnectedWidget extends ConsumerWidget {
  const HomeScreenConnectedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(shouldShowUpdateDialogProvider);
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    return ListView(
      children: [
        const IsProgramAdminstratorWidget(),
        StaggeredGridview(
          children: [
            CpuWidget(computerData: computerData),
            GpuWidget(computerData: computerData),
            RamWidget(computerData: computerData),
            if (computerData.battery.hasBattery) BatteryWidget(computerData: computerData),
            //FpsWidget(),
            NetworkWidget(computerData: computerData),
          ],
        ),
        StorageWidget(computerData: computerData),
        InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/4695435315" : "ca-app-pub-5545344389727160/5860639295"),
      ],
    );
  }
}
