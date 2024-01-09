import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class FirstRowWidget extends ConsumerWidget {
  const FirstRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSocket = ref.watch(localSocketProvider);
    return localSocket.when(
      skipLoadingOnReload: true,
      data: (data) {
        final primaryGpu = ref.read(localSocketProvider.notifier).getPrimaryGpu();
        if (primaryGpu == null || data == null) return Container();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Card(
                elevation: 1,
                child: SizedBox(
                  height: 205,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.h),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "GPU",
                                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 40),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 13.h,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: SfRadialGauge(
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                  canScaleToFit: false,
                                                  startAngle: 0,
                                                  endAngle: 360,
                                                  showTicks: false,
                                                  showLabels: false,
                                                  axisLineStyle: const AxisLineStyle(thickness: 10),
                                                  pointers: <GaugePointer>[
                                                    RangePointer(
                                                      value: primaryGpu.corePercentage,
                                                      width: 10,
                                                      color: Theme.of(context).primaryColor,
                                                      enableAnimation: false,
                                                    )
                                                  ],
                                                  annotations: <GaugeAnnotation>[
                                                    GaugeAnnotation(
                                                        widget: Text(
                                                          "${primaryGpu.corePercentage.round()}%",
                                                          style:
                                                              Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                                                        ),
                                                        angle: 270,
                                                        positionFactor: 0.1),
                                                  ])
                                            ],
                                          ),
                                        ),
                                      ),
                                      Table(
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        columnWidths: const {
                                          0: IntrinsicColumnWidth(flex: 2),
                                          1: IntrinsicColumnWidth(flex: 2),
                                        },
                                        children: <TableRow>[
                                          //librehardware sends a wrong dedicated memory value, will hide this until it's fixed.
                                          //tableRow(
                                          //  context,
                                          //  "Dedicated Memory",
                                          //  FontAwesomeIcons.memory,
                                          //  ((primaryGpu.dedicatedMemoryUsed * 1000 * 1000).toSize()).toString(),
                                          //  addSpacing: true,
                                          //),

                                          tableRow(
                                            context,
                                            "Core Clock",
                                            Icons.power,
                                            "${primaryGpu.coreSpeed.round()}Mhz",
                                          ),
                                          tableRow(
                                            context,
                                            "Fan Speed",
                                            FontAwesomeIcons.fan,
                                            "${primaryGpu.fanSpeedPercentage.round()}%",
                                          ),
                                          tableRow(
                                            context,
                                            "Memory",
                                            Icons.power,
                                            "${primaryGpu.memorySpeed.round()}Mhz",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  //SizedBox(
                                  //    height: 10.h,
                                  //    child: SfSparkAreaChart(
                                  //      axisLineWidth: 0,
                                  //      borderWidth: 2,
                                  //      trackball: const SparkChartTrackball(shouldAlwaysShow: true),
                                  //      color: Theme.of(context).primaryColor,
                                  //      data: data.chartData['gpu.corePercentage'] ?? [],
                                  //    )),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            getTemperatureText(primaryGpu.temperature, ref),
                            style:
                                Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(primaryGpu.temperature), fontSize: 12.sp),
                          ),
                        ],
                      )),
                ),
              ),
            ),
            Expanded(
              child: Card(
                elevation: 1,
                child: SizedBox(
                  height: 205,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.h),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CPU",
                                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 40),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 13.h,
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
                                                      value: data.cpu.load,
                                                      width: 10,
                                                      color: Theme.of(context).primaryColor,
                                                      enableAnimation: false,
                                                    )
                                                  ],
                                                  annotations: <GaugeAnnotation>[
                                                    GaugeAnnotation(
                                                        widget: Text(
                                                          "${data.cpu.load.round()}%",
                                                          style:
                                                              Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                                                        ),
                                                        angle: 270,
                                                        positionFactor: 0.1),
                                                  ])
                                            ],
                                          ),
                                        ),
                                      ),
                                      Table(
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        columnWidths: const {
                                          0: IntrinsicColumnWidth(flex: 2),
                                          1: IntrinsicColumnWidth(flex: 2),
                                        },
                                        children: <TableRow>[
                                          tableRow(
                                            context,
                                            "Clock",
                                            Icons.power,
                                            "${(data.cpu.getAverageClock() / 1000).toStringAsPrecision(3)}Ghz",
                                            addSpacing: true,
                                          ),
                                          tableRow(
                                            context,
                                            "Power",
                                            Icons.power,
                                            "${data.cpu.power.round()}W",
                                          ),
                                          tableRow(
                                            context,
                                            "Voltage",
                                            Icons.power,
                                            "${data.cpu.voltages.entries.firstOrNull?.value.toStringAsPrecision(3)}v",
                                            addSpacing: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  //SizedBox(
                                  //    height: 10.h,
                                  //    child: SfSparkAreaChart(
                                  //      axisLineWidth: 0,
                                  //      borderWidth: 2,
                                  //      trackball: const SparkChartTrackball(shouldAlwaysShow: true),
                                  //      color: Theme.of(context).primaryColor,
                                  //      data: data.chartData['gpu.corePercentage'] ?? [],
                                  //    )),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            getTemperatureText(data.cpu.temperature, ref),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: getTemperatureColor(data.cpu.temperature ?? 0), fontSize: 12.sp),
                          ),
                        ],
                      )),
                ),
              ),
            ),
            Card(
              elevation: 1,
              child: SizedBox(
                height: 205,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RAM",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 40),
                        ),
                        Row(
                          children: [
                            SizedBox(
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
                                            value: data.ram.memoryUsedPercentage.toDouble(),
                                            width: 10,
                                            color: Theme.of(context).primaryColor,
                                            enableAnimation: false,
                                          )
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              widget: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${data.ram.memoryUsedPercentage}%",
                                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                                                  ),
                                                  Table(
                                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                    columnWidths: const {
                                                      0: IntrinsicColumnWidth(),
                                                      1: IntrinsicColumnWidth(),
                                                    },
                                                    children: <TableRow>[
                                                      tableRow(
                                                        context,
                                                        "Used:",
                                                        Icons.power,
                                                        "${data.ram.memoryUsed.toStringAsFixed(1)}GB",
                                                        addSpacing: false,
                                                        showIcon: false,
                                                      ),
                                                      tableRow(
                                                        context,
                                                        "Free:",
                                                        Icons.power,
                                                        "${data.ram.memoryAvailable.toStringAsFixed(1)}GB",
                                                        addSpacing: false,
                                                        showIcon: false,
                                                      ),
                                                    ],
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
                    )),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text("error");
      },
      loading: () {
        return Container();
      },
    );
  }
}
