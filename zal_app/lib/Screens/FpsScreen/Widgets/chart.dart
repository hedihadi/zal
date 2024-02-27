import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';

import 'package:zal/Functions/models.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartSampleData {
  double firstSeriesYValue;
  double secondSeriesYValue;
  double thirdSeriesYValue;
  ChartSampleData({
    required this.firstSeriesYValue,
    required this.secondSeriesYValue,
    required this.thirdSeriesYValue,
  });
}

class LineZoneChartWidget extends StatelessWidget {
  LineZoneChartWidget({super.key, required this.fpsData}) {
    chartData = [ChartSampleData(firstSeriesYValue: fpsData.averageFps, secondSeriesYValue: fpsData.fps01Low, thirdSeriesYValue: fpsData.fps001Low)];
  }
  final FpsData fpsData;

  late List<ChartSampleData> chartData;
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: BarChart(
        BarChartData(
          maxY: fpsData.averageFps,
          barTouchData: BarTouchData(
            mouseCursorResolver: (event, response) {
              return response == null || response.spot == null ? MouseCursor.defer : SystemMouseCursors.click;
            },
            enabled: true,
            handleBuiltInTouches: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Theme.of(context).appBarTheme.backgroundColor,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 25.w,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text = "";
                  Color color = Colors.white;
                  double fps = 0.0;
                  switch (value) {
                    case 1:
                      text = "avg Fps";
                      color = Colors.red;
                      fps = fpsData.averageFps;
                      break;
                    case 2:
                      text = "1% Fps";
                      color = Colors.blue;
                      fps = fpsData.fps01Low;
                      break;
                    case 3:
                      text = "0.1% Fps";
                      color = Colors.green;
                      fps = fpsData.fps001Low;
                      break;
                  }
                  return RotatedBox(
                    quarterTurns: -1,
                    child: RichText(
                      text: TextSpan(
                        text: fps.toStringAsFixed(1),
                        style: TextStyle(color: color),
                        children: <TextSpan>[
                          TextSpan(text: ' $text', style: const TextStyle(color: Color(0xff7589a2), fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                  return RotatedBox(quarterTurns: -1, child: Text("${value.round()} $text"));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: (value, meta) {
                  return Text("$value");
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    color: Theme.of(context).cardTheme.color,
                    toY: fpsData.averageFps,
                  ),
                  toY: fpsData.averageFps,
                  color: Colors.red[400],
                  width: 10,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    color: Theme.of(context).cardTheme.color,
                    toY: fpsData.averageFps,
                  ),
                  toY: fpsData.fps01Low,
                  color: Colors.blue,
                  width: 10,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    color: Theme.of(context).cardTheme.color,
                    toY: fpsData.averageFps,
                  ),
                  toY: fpsData.fps001Low,
                  color: Colors.green,
                  width: 10,
                ),
              ],
            )
          ],
          gridData: const FlGridData(show: false),
        ),
      ),
    );
    return SizedBox(
      height: 15.h,
      child: SfCartesianChart(
        isTransposed: false,
        enableAxisAnimation: true,
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        legend: Legend(isVisible: false),
        primaryXAxis: CategoryAxis(isVisible: false),
        primaryYAxis: NumericAxis(isVisible: false),
        series: _getDefaultBarSeries(),
        tooltipBehavior: TooltipBehavior(enable: false),
      ),
    );
  }

  List<BarSeries<ChartSampleData, String>> _getDefaultBarSeries() {
    return <BarSeries<ChartSampleData, String>>[
      BarSeries<ChartSampleData, String>(
          animationDuration: 0,
          dataLabelSettings: const DataLabelSettings(isVisible: true, labelAlignment: ChartDataLabelAlignment.middle),
          color: HexColor("#edbd7b"),
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => '',
          yValueMapper: (ChartSampleData sales, _) => sales.thirdSeriesYValue,
          name: '0.1% low FPS'),
      BarSeries<ChartSampleData, String>(
          animationDuration: 0,
          dataLabelSettings: const DataLabelSettings(isVisible: true, labelAlignment: ChartDataLabelAlignment.middle),
          color: HexColor("#e56d6e"),
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => '',
          yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
          name: '1% low FPS'),
      BarSeries<ChartSampleData, String>(
          animationDuration: 0,
          dataLabelSettings: const DataLabelSettings(isVisible: true, labelAlignment: ChartDataLabelAlignment.middle),
          color: HexColor("#467cd6"),
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => '',
          yValueMapper: (ChartSampleData sales, _) => sales.firstSeriesYValue,
          name: 'FPS'),
    ];
  }

  Widget leftTitles(double value, TitleMeta meta, List<int> numbersList) {
    if (numbersList.contains(value.toInt()) == false) return Container();
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text("${(value / 60).round()}hrs", style: style),
    );
  }
}
