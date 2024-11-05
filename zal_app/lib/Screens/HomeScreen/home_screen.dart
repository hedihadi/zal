import 'dart:io';

import 'package:color_print/color_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/ConnectedScreen/connected_screen_providers.dart';
import 'package:zal/Screens/FilesScreen/Providers/information_text_provider.dart';
import 'package:zal/Screens/FpsScreen/fps_screen.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
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

final shouldListenToWebrtcDataChangesProvider = StateProvider<bool>((ref) => true);
final shouldShowConnectedWidgetProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(informationTextProvider);
    final computerData = ref.watch(computerDataProvider);
    return computerData.when(
      skipLoadingOnReload: true,
      data: (data) {
        final gpu = data.gpu;
        return ListView(
          children: [
            SizedBox(
              height: 1.h,
            ),
            const IsProgramAdminstratorWidget(),
            const SizedBox(height: 10),
            if (data.battery.hasBattery)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Battery',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "${data.battery.lifeRemaining == -1 ? "forever" : timeago.format(DateTime.now().add(Duration(seconds: data.battery.lifeRemaining)), allowFromNow: true).replaceAll("from now", "")}remaining",
                          style: const TextStyle(color: Color(0xff77839a), fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 25,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 25,
                              child: LinearProgressIndicator(
                                value: data.battery.batteryPercentage / 100,
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/icons/${data.battery.isCharging ? 'lighting' : 'battery'}.png",
                                  height: 20,
                                ),
                                Text(
                                  "${data.battery.batteryPercentage}%",
                                  style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parts',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: SfRadialGauge(
                                animationDuration: 0,
                                axes: <RadialAxis>[
                                  RadialAxis(
                                      canScaleToFit: true,
                                      startAngle: 0,
                                      endAngle: 360,
                                      showTicks: false,
                                      showLabels: false,
                                      axisLineStyle: const AxisLineStyle(thickness: 10),
                                      pointers: <GaugePointer>[
                                        RangePointer(
                                          value: data.cpu.load,
                                          width: 10,
                                          color: Theme.of(context).primaryColor,
                                          enableAnimation: true,
                                          cornerStyle: CornerStyle.bothCurve,
                                        )
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                            widget: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  getTemperatureText(data.cpu.temperature, ref),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(color: getTemperatureColor(data.cpu.temperature ?? 0)),
                                                ),
                                                Image.asset(
                                                  "assets/images/icons/cpu.png",
                                                  height: 25,
                                                ),
                                                Text(
                                                  "${data.cpu.load.round()}%",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                                ),
                                              ],
                                            ),
                                            angle: 270,
                                            positionFactor: 0.1),
                                      ])
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
                            animationDuration: 0,
                            axes: <RadialAxis>[
                              RadialAxis(
                                  canScaleToFit: true,
                                  startAngle: 0,
                                  endAngle: 360,
                                  showTicks: false,
                                  showLabels: false,
                                  axisLineStyle: const AxisLineStyle(thickness: 10),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: data.ram.memoryUsedPercentage.toDouble(),
                                      width: 10,
                                      color: Theme.of(context).primaryColor,
                                      enableAnimation: true,
                                      cornerStyle: CornerStyle.bothCurve,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/icons/ram.png",
                                              height: 25,
                                            ),
                                            Text(
                                              "${data.ram.memoryUsedPercentage.round()}%",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                          ],
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1),
                                  ])
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
                            animationDuration: 0,
                            axes: <RadialAxis>[
                              RadialAxis(
                                  canScaleToFit: true,
                                  startAngle: 0,
                                  endAngle: 360,
                                  showTicks: false,
                                  showLabels: false,
                                  axisLineStyle: const AxisLineStyle(thickness: 10),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: gpu.corePercentage,
                                      width: 10,
                                      color: Theme.of(context).primaryColor,
                                      enableAnimation: true,
                                      cornerStyle: CornerStyle.bothCurve,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              getTemperatureText(gpu.temperature, ref),
                                              style:
                                                  Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(gpu.temperature ?? 0)),
                                            ),
                                            Image.asset(
                                              "assets/images/icons/gpu.png",
                                              height: 25,
                                            ),
                                            Text(
                                              "${gpu.corePercentage.round()}%",
                                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                          ],
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/4695435315" : "ca-app-pub-5545344389727160/5860639295"),
            Divider(color: HexColor("#1c2023"), thickness: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Card(
                elevation: 0,
                color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gaming mode',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      const Text(
                        "check fps, temperatures, hardware stats, etc... while you're gaming!",
                        style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FpsScreen()));
                            ref.read(fpsDataProvider.notifier).showChooseGameDialog(dismissible: false);
                          },
                          child: const Text("Open"))
                    ],
                  ),
                ),
              ),
            ),
            Divider(color: HexColor("#1c2023"), thickness: 5),
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
