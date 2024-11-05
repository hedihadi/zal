import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/CpuScreen/Widgets/cpu_data_list_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_data_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_help_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_records_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_screen_pc_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/select_gpu_process_widget.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/GpuScreen/Widgets/gpu_data_list_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

import '../../Functions/analytics_manager.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FilesScreen/Providers/information_text_provider.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/cpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/fps_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/gpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/is_program_adminstrator_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/ram_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../MainScreen/SettingsScreen/settings_providers.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class FpsScreen extends ConsumerWidget {
  const FpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("fps"));
    return WillPopScope(
      onWillPop: () async {
        ref.read(socketProvider.notifier).sendMessage('stop_fps', '');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FpsTitle(),
          actions: [
            //   const FpsHelpWidget(),
            PopupMenuButton<SampleItem>(
              icon: const Card(
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("More"),
                        Icon(FontAwesomeIcons.ellipsisVertical),
                      ],
                    ),
                  )),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                PopupMenuItem(
                  child: const Text("choose game"),
                  onTap: () {
                    ref.read(fpsDataProvider.notifier).showChooseGameDialog();
                  },
                ),
                const PopupMenuItem<SampleItem>(
                  child: FpsCheckboxSetting(
                    settingsKey: 'showFpsChart',
                    text: "show chart",
                  ),
                ),
                const PopupMenuItem<SampleItem>(
                  child: FpsCheckboxSetting(
                    settingsKey: 'showGauges',
                    text: "show gauges",
                  ),
                ),
                const PopupMenuItem<SampleItem>(
                  child: FpsCheckboxSetting(
                    settingsKey: 'showCpuCores',
                    text: "cpu cores",
                  ),
                ),
              ],
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 2.h),
            ),
            const SliverToBoxAdapter(
              child: FpsDataWidget(),
            ),
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            const SliverToBoxAdapter(
              child: FpsScreenPcWidget(),
            ),
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  "Records",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const FpsRecordsWidget(),
          ],
        ),
      ),
    );
  }
}

class PauseFpsButton extends ConsumerWidget {
  const PauseFpsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = ref.watch(isFpsPausedProvider);
    return IconButton(
      onPressed: () {
        ref.read(isFpsPausedProvider.notifier).state = !isPaused;
      },
      icon: Icon(isPaused ? FontAwesomeIcons.play : FontAwesomeIcons.pause),
    );
  }
}

class ElpasedTimeWidget extends ConsumerWidget {
  const ElpasedTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopwatch = ref.watch(fpsTimeElapsedProvider);
    return Text(
      formatTime(stopwatch.value ?? 0),
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class FpsTitle extends ConsumerWidget {
  const FpsTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGpuProcess = ref.watch(selectedGpuProcessProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ([null, ""].contains(selectedGpuProcess?.icon) == false)
          Image.memory(
            base64Decode(selectedGpuProcess!.icon!),
            gaplessPlayback: true,
            scale: 1,
          ),
        Text(
          selectedGpuProcess?.name ?? '',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}

class FpsCheckboxSetting extends ConsumerWidget {
  const FpsCheckboxSetting({super.key, required this.settingsKey, required this.text});
  final String settingsKey;
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final val = ref.watch(settingsProvider).value?[settingsKey] ?? true;
    return CheckboxListTile(
      value: val,
      onChanged: (value) => ref.read(settingsProvider.notifier).updateSettings(settingsKey, value),
      title: Text(text),
    );
  }
}
