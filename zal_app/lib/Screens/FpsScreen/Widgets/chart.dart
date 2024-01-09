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
    chartData = [ChartSampleData(firstSeriesYValue: fpsData.fps, secondSeriesYValue: fpsData.fps01Low, thirdSeriesYValue: fpsData.fps001Low)];
  }
  final FpsData fpsData;

  late List<ChartSampleData> chartData;
  @override
  Widget build(BuildContext context) {
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
}
