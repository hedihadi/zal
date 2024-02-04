import 'dart:io' as iooa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/FilesScreen/Providers/information_text_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/cpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/gpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/ram_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/storage_widget.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

import '../../../Widgets/inline_ad.dart';
import 'is_program_adminstrator_widget.dart';

class HomeScreenConnectedWidget extends ConsumerWidget {
  const HomeScreenConnectedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(shouldShowUpdateDialogProvider);
    ref.read(informationTextProvider);
    final computerData = ref.watch(computerDataProvider);

    return computerData.when(
      skipLoadingOnReload: true,
      data: (data) {
        return ListView(
          children: [
            const IsProgramAdminstratorWidget(),
            StaggeredGridview(
              children: [
                CpuWidget(computerData: data),
                GpuWidget(computerData: data),
                RamWidget(computerData: data),
                if (data.battery.hasBattery) BatteryWidget(computerData: data),
                //FpsWidget(),
                NetworkWidget(computerData: data),
              ],
            ),
            StorageWidget(computerData: data),
            InlineAd(adUnit: iooa.Platform.isAndroid ? "ca-app-pub-5545344389727160/4695435315" : "ca-app-pub-5545344389727160/5860639295"),
          ],
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return Center(child: ReportErrorWidget(error: error as ErrorParsingComputerData));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
