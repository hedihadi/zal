import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/GpuScreen/Widgets/gpu_data_list_widget.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';

import '../../Functions/analytics_manager.dart';

class GpuScreen extends ConsumerWidget {
  const GpuScreen({super.key, required this.gpuName});
  final String gpuName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    ref.read(screenViewProvider("gpu"));
    final gpu = computerData.gpus.firstWhereOrNull((element) => element.name == gpuName);
    if (gpu == null) return const Text("gpu doesn't exist");
    return Scaffold(
      appBar: AppBar(title: const Text("GPU")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text(gpu.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
                  SizedBox(height: 3.h),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20.h,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
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
                                        widget: Text(
                                          "${gpu.corePercentage.round()}%",
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1),
                                  ])
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: GpuDataListWidget(gpu: gpu),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ChartWidget(
            data: computerData.charts['gpuLoad'] ?? [],
            title: "Load",
            maxYAxisNumber: 100,
            yAxisLabel: '%',
          ),
          ChartWidget(
            data: computerData.charts['gpuTemperature'] ?? [],
            title: "Temperature",
            maxYAxisNumber: 100,
            minYAxisNumber: 0,
            yAxisLabel: (ref.read(settingsProvider).valueOrNull?['useCelcius'] ?? false) ? 'c' : 'f',
          ),
          ChartWidget(
            data: computerData.charts['gpuPower'] ?? [],
            title: "Power",
            maxYAxisNumber: 100,
            yAxisLabel: 'W',
          ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
