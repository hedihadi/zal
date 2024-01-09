import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends ConsumerWidget {
  const ChartWidget({super.key, required this.title, required this.data, this.maxYAxisNumber, this.minYAxisNumber, this.yAxisLabel});
  final String title;
  final List<dynamic> data;
  final double? maxYAxisNumber;
  final double? minYAxisNumber;

  final String? yAxisLabel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = getChartData();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(
              height: 15.h,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryYAxis: NumericAxis(
                    visibleMaximum: maxYAxisNumber,
                    labelFormat: '{value}${yAxisLabel ?? ""}',
                    interval: getYAxisInterval(),
                    visibleMinimum: minYAxisNumber,
                    majorGridLines: const MajorGridLines(width: 0)),
                primaryXAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries>[
                  // Renders line chart
                  LineSeries<ChartData, int>(
                    color: Theme.of(context).primaryColor,
                    animationDelay: 0,
                    animationDuration: 0,
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.index,
                    yValueMapper: (ChartData data, _) => data.data,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? getYAxisInterval() {
    if (maxYAxisNumber == null) return null;
    return maxYAxisNumber! / 5;
  }

  List<ChartData> getChartData() {
    List<ChartData> result = data.mapIndexed((index, element) => ChartData(index, element)).toList();
    return result;
  }
}

class ChartData {
  ChartData(this.index, this.data);
  final int index;
  final num data;
}
