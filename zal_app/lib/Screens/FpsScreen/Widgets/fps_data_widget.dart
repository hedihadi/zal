import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FpsScreen/Widgets/chart.dart';
import 'package:zal/Screens/FpsScreen/Widgets/save_fps_widget.dart';
import 'package:zal/Screens/FpsScreen/fps_screen.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/chart_widget.dart';

class FpsDataWidget extends ConsumerWidget {
  const FpsDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsData = ref.watch(fpsDataProvider);
    final settings = ref.watch(settingsProvider).value!;

    return fpsData.when(
      skipLoadingOnReload: true,
      data: (data) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.currentFps.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            "fps",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! + 2, color: Colors.blueGrey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const ElpasedTimeWidget(),
              SizedBox(height: 10.h, child: LineZoneChartWidget(fpsData: data)),
              if ((settings['showFpsChart'] ?? true) == true)
                Card(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                  child: SizedBox(height: 9.h, child: const Linechart()),
                )),
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
        );
      },
      error: (error, stackTrace) {
        print(stackTrace);
        print(error);
        return const Text("error");
      },
      loading: () {
        return const Center(
          child: Text("waiting for data..."),
        );
      },
    );
  }
}

class Linechart extends ConsumerWidget {
  const Linechart({super.key});

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth, FpsData? fpsData) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      //  color: Colors.yellow,
      //fontWeight: FontWeight.bold,
    );

    if ((value == (meta.min)) || value == (meta.max) || value.round() == fpsData?.averageFps.round()) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 5,
        child: Text(meta.formattedValue, style: style),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsList = ref.watch(fpsChartProvider);
    final lowest = fpsList.isEmpty ? 0.0 : fpsList.reduce(min);
    final highest = fpsList.isEmpty ? 0.0 : fpsList.reduce(max);
    final fpsData = ref.read(fpsDataProvider).valueOrNull;
    return LayoutBuilder(
      builder: (context, constraints) {
        return LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                maxContentWidth: 100,
                tooltipBgColor: Colors.black,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final textStyle = TextStyle(
                      color: touchedSpot.bar.gradient?.colors[0] ?? touchedSpot.bar.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                    return LineTooltipItem(
                      touchedSpot.y.toStringAsFixed(2),
                      textStyle,
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
              getTouchLineStart: (data, index) => 0,
            ),
            lineBarsData: [
              LineChartBarData(
                color: Theme.of(context).primaryColor,
                spots: fpsList.mapIndexed<FlSpot>((index, element) => FlSpot(index.toDouble(), element)).toList(),
                isCurved: false,
                isStrokeCapRound: true,
                barWidth: 1,
                belowBarData: BarAreaData(
                  show: false,
                ),
                dotData: const FlDotData(show: false),
              ),
            ],
            minY: lowest,
            maxY: highest,
            titlesData: FlTitlesData(
              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, constraints.maxWidth, fpsData),
                  reservedSize: 15.w,
                  interval: 1,
                ),
                drawBelowEverything: true,
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: false,
              drawVerticalLine: false,
              horizontalInterval: 0.01,
              verticalInterval: 2,
              checkToShowHorizontalLine: (value) {
                return false;
              },
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.yellow.withOpacity(0.5),
                dashArray: [8, 2],
                strokeWidth: 0.8,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
          duration: Duration.zero,
        );
      },
    );
  }
}
