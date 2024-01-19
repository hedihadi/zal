import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:zal/Widgets/title_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Functions/analytics_manager.dart';

class RamScreen extends ConsumerWidget {
  const RamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    ref.read(screenViewProvider("ram"));
    final ram = computerData.ram;
    return Scaffold(
      appBar: AppBar(title: const Text("RAM")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text(ram.ramPieces.first.partNumber,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
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
                                        value: ram.memoryUsedPercentage.toDouble(),
                                        width: 10,
                                        color: Theme.of(context).primaryColor,
                                        enableAnimation: true,
                                        cornerStyle: CornerStyle.bothCurve,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                            "${ram.memoryUsedPercentage.round()}%",
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
                                "Total",
                                FontAwesomeIcons.box,
                                "${(ram.memoryAvailable + ram.memoryUsed).round()} GB",
                              ),
                              tableRow(
                                context,
                                "used",
                                FontAwesomeIcons.memory,
                                "${ram.memoryUsed.toStringAsFixed(2)} GB",
                              ),
                              tableRow(
                                context,
                                "free",
                                FontAwesomeIcons.memory,
                                "${ram.memoryAvailable.toStringAsFixed(2)} GB",
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
          const TitleWidget('Sticks'),
          StaggeredGridview(
            children: List.generate(
              ram.ramPieces.length,
              (index) {
                final ramPiece = ram.ramPieces[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                      child: Table(
                        //columnWidths: {
                        //  0: IntrinsicColumnWidth(),
                        //  1: FlexColumnWidth(),
                        //},
                        children: <TableRow>[
                          tableRow(
                            context,
                            "Size",
                            FontAwesomeIcons.borderAll,
                            ramPiece.capacity.toSize(decimals: 0),
                            showIcon: false,
                          ),
                          tableRow(
                            context,
                            "Speed",
                            FontAwesomeIcons.borderAll,
                            "${ramPiece.clockSpeed}Mhz",
                            showIcon: false,
                          ),
                          tableRow(
                            context,
                            "Manufacturer",
                            FontAwesomeIcons.borderAll,
                            ramPiece.manufacturer,
                            showIcon: false,
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
          ChartWidget(
            data: computerData.charts['ramPercentage'] ?? [],
            title: "Percentage",
            maxYAxisNumber: 100,
            minYAxisNumber: 0,
            yAxisLabel: '%',
          ),
          //const HeavyProcessesWidget(title: "these processes take the most ram", sortBy: SortBy.Memory),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
