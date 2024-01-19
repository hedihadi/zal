import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Functions/analytics_manager.dart';

class CpuScreen extends ConsumerWidget {
  const CpuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    ref.read(screenViewProvider("cpu"));
    final cpu = computerData.cpu;
    return Scaffold(
      appBar: AppBar(title: const Text("CPU")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text(cpu.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 15.h,
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
                                        value: cpu.load,
                                        width: 10,
                                        color: Theme.of(context).primaryColor,
                                        enableAnimation: true,
                                        cornerStyle: CornerStyle.bothCurve,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                            "${cpu.load.round()}%",
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                          ),
                                          angle: 270,
                                          positionFactor: 0.1),
                                    ])
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: <TableRow>[
                              tableRow(
                                context,
                                "Power",
                                FontAwesomeIcons.plug,
                                "${cpu.power.round()}W",
                              ),
                              tableRow(
                                context,
                                "Temperature",
                                FontAwesomeIcons.temperatureFull,
                                getTemperatureText(cpu.temperature, ref),
                              ),
                              tableRow(
                                context,
                                "Load",
                                Icons.scale,
                                "${cpu.load.round()}%",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StaggeredGridview(
            children: List.generate(
              cpu.clocks.length,
              (index) {
                final coreInfo = cpu.getCpuCoreinfo(index);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Card(
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
          const Divider(),
          ChartWidget(data: computerData.charts['cpuLoad'] ?? [], title: "Load", maxYAxisNumber: 100, yAxisLabel: '%'),
          ChartWidget(
            data: computerData.charts['cpuTemperature'] ?? [],
            title: "Temperature",
            maxYAxisNumber: 100,
            minYAxisNumber: 0,
            yAxisLabel: (ref.read(settingsProvider).valueOrNull?.useCelcius ?? false) ? 'c' : 'f',
          ),

          //const HeavyProcessesWidget(title:"these processes have the heavest load",sortBy: SortBy.Cpu),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
