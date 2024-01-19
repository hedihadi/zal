import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FpsScreen/Widgets/chart.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_help_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_records_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/save_fps_widget.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/inline_ad.dart';

import '../../Functions/analytics_manager.dart';

class FpsScreen extends ConsumerWidget {
  const FpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsData = ref.watch(fpsDataProvider);
    ref.read(screenViewProvider("fps"));
    return WillPopScope(
      onWillPop: () async {
        ref.read(socketObjectProvider.notifier).state!.sendData('stop_fps', '');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("FPS Counter"),
          actions: const [FpsHelpWidget()],
        ),
        body: fpsData.when(
          skipLoadingOnReload: true,
          data: (data) {
            return ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: 2.h),
                data.processName == null
                    ? Container()
                    : Text(
                        "${data.processName}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const ElpasedTimeWidget(),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "1% fps",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      "${data.fps01Low.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "FPS",
                                      style: Theme.of(context).textTheme.titleLarge!,
                                    ),
                                    Text(
                                      "${data.fps.round()}",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "0.1% fps",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      "${data.fps001Low.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            LineZoneChartWidget(fpsData: data),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SaveFpsWidget(),
                                const PauseFpsButton(),
                                IconButton(
                                  onPressed: () {
                                    ref.read(fpsDataProvider.notifier).reset();
                                  },
                                  icon: const Icon(FontAwesomeIcons.arrowsRotate),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Text(
                    "Records:-",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const FpsPresetsWidget(),
                InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
              ],
            );
          },
          error: (error, stackTrace) {
            print(error);
            print(stackTrace);
            return Text("$error");
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
