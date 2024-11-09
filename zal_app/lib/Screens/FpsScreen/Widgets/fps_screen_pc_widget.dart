import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/ConnectedScreen/connected_screen_providers.dart';
import 'package:zal/Screens/CpuScreen/Widgets/cpu_data_list_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_data_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_help_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_records_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/select_gpu_process_widget.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/GpuScreen/Widgets/gpu_data_list_widget.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

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

class FpsScreenPcWidget extends ConsumerWidget {
  const FpsScreenPcWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fpsComputerDataProvider);
    final settings = ref.watch(settingsProvider).value;
    final gpu = ref.watch(computerDataProvider).value?.gpu;

    if (gpu == null) return Container();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if ((settings?['showGauges'] ?? true) == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                value: data.computerData.cpu.load,
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
                                        getTemperatureText(data.computerData.cpu.temperature, ref),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(color: getTemperatureColor(data.computerData.cpu.temperature ?? 0)),
                                      ),
                                      Image.asset(
                                        "assets/images/icons/cpu.png",
                                        height: 25,
                                      ),
                                      Text(
                                        "${data.computerData.cpu.load.round()}%",
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
                                value: data.computerData.ram.memoryUsedPercentage.toDouble(),
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
                                        "${data.computerData.ram.memoryUsedPercentage.round()}%",
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
                                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(gpu.temperature ?? 0)),
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
          Card(
            child: Column(
              children: [
                Text(gpu.name, style: Theme.of(context).textTheme.titleLarge!.copyWith()),
                GridView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.5),
                  children: [
                    FpsPcStatWidget(
                        text: "core speed",
                        value: "${gpu.coreSpeed.round()}Mhz",
                        icon: FontAwesomeIcons.gauge,
                        maxValue: "${data.highestValues['gpu.coreSpeed']?.round()}Mhz"),
                    FpsPcStatWidget(
                        text: "mem speed",
                        value: "${gpu.memorySpeed.round()}Mhz",
                        icon: Icons.memory,
                        maxValue: "${data.highestValues['gpu.memorySpeed']?.round()}Mhz"),
                    FpsPcStatWidget(
                        text: "mem usage",
                        value: (gpu.dedicatedMemoryUsed * 1000 * 1000).toSize(),
                        icon: Icons.memory,
                        maxValue: ((data.highestValues['gpu.dedicatedMemoryUsed'] ?? 0) * 1000 * 1000).toSize()),
                    FpsPcStatWidget(
                      text: "power",
                      value: "${gpu.power.round()}W",
                      icon: Icons.memory,
                      maxValue: "${data.highestValues['gpu.power']?.round()}W",
                    ),
                    FpsPcStatWidget(
                        text: "voltage",
                        value: "${gpu.voltage.round()}V",
                        icon: Icons.memory,
                        maxValue: "${data.highestValues['gpu.voltage']?.round()}V"),
                    FpsPcStatWidget(
                        text: "fan Speed",
                        value: "${gpu.fanSpeedPercentage.round()}%",
                        icon: Icons.memory,
                        maxValue: "${data.highestValues['gpu.fanSpeedPercentage']?.round()}%"),
                    FpsPcStatWidget(
                        text: "temperature",
                        value: getTemperatureText(gpu.temperature, ref),
                        icon: Icons.memory,
                        maxValue: getTemperatureText((data.highestValues['gpu.temperature'] ?? 0).toDouble(), ref)),
                    FpsPcStatWidget(
                        text: "load",
                        value: "${gpu.corePercentage.round()}%",
                        icon: Icons.memory,
                        maxValue: "${data.highestValues['gpu.corePercentage']?.round()}%"),
                  ],
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Text(data.computerData.cpu.name, style: Theme.of(context).textTheme.titleLarge!.copyWith()),
                GridView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.5),
                  children: [
                    FpsPcStatWidget(
                        text: "load",
                        value: "${data.computerData.cpu.load.round()}%",
                        icon: FontAwesomeIcons.gauge,
                        maxValue: "${data.highestValues['cpu.load']?.round()}%"),
                    FpsPcStatWidget(
                        text: "power",
                        value: "${data.computerData.cpu.power.round()}W",
                        icon: FontAwesomeIcons.gauge,
                        maxValue: "${data.highestValues['cpu.power']?.round()}W"),
                    FpsPcStatWidget(
                        text: "temperature",
                        value: getTemperatureText(data.computerData.cpu.temperature, ref),
                        icon: FontAwesomeIcons.gauge,
                        maxValue: getTemperatureText((data.highestValues['cpu.temperature'] ?? 0).toDouble(), ref)),
                  ],
                ),
                InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/5701849781" : "ca-app-pub-5545344389727160/3665863326"),
                Visibility(
                  visible: ((settings?['showCpuCores'] ?? true) == true),
                  child: StaggeredGridview(
                    children: List.generate(
                      data.computerData.cpu.clocks.length,
                      (index) {
                        final coreInfo = data.computerData.cpu.getCpuCoreinfo(index);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            elevation: 0,
                            color: Theme.of(context).appBarTheme.backgroundColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'core #${index + 1}',
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${coreInfo.clock?.round()}MHZ',
                                          style: Theme.of(context).textTheme.labelMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        '${coreInfo.load?.round()}%',
                                        style: Theme.of(context).textTheme.labelMedium,
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  LinearProgressIndicator(value: (coreInfo.load ?? 0) / 100, minHeight: 1.h),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      coreInfo.voltage == null
                                          ? Container()
                                          : Text(
                                              '${coreInfo.voltage?.toStringAsFixed(2)}v',
                                              style: Theme.of(context).textTheme.labelMedium,
                                              textAlign: TextAlign.start,
                                            ),
                                      Expanded(
                                        child: coreInfo.power == null
                                            ? Container()
                                            : Text(
                                                '${coreInfo.power?.toStringAsFixed(2)}W',
                                                textAlign: TextAlign.end,
                                                style: Theme.of(context).textTheme.labelMedium,
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FpsPcStatWidget extends ConsumerWidget {
  const FpsPcStatWidget({super.key, required this.text, required this.value, required this.icon, this.maxValue});
  final String text;
  final String value;
  final dynamic maxValue;
  final IconData icon;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      elevation: 0,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                //Padding(
                //  padding: EdgeInsets.only(right: 1.w),
                //  child: Icon(
                //    icon,
                //    size: 2.h,
                //    color: Theme.of(context).primaryColor,
                //  ),
                //),
                Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
            if (maxValue != null)
              Text(
                "${maxValue!}",
                style: TextStyle(
                  fontSize: 11,
                  color: HexColor("#ef6f6c"),
                ),
              ),

            //Padding(
            //  padding: EdgeInsets.only(left: (2.h) + (1.w)),
            //  child: Text(
            //    value,
            //    style: const TextStyle(
            //      fontSize: 11,
            //    ),
            //  ),
            //),
          ],
        ),
      ),
    );
  }
}
