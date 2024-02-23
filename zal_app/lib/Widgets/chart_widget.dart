import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends ConsumerWidget {
  const ChartWidget({
    super.key,
    required this.data,
    this.title,
    this.maxYAxisNumber,
    this.minYAxisNumber,
    this.yAxisLabel,
    this.compact = false,
    this.wrapInCard = true,
    this.removePadding = false,
  });
  final String? title;
  final List<dynamic> data;
  final double? maxYAxisNumber;
  final double? minYAxisNumber;
  final bool compact;
  final bool wrapInCard;
  final bool removePadding;
  final String? yAxisLabel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = getChartData();
    return !wrapInCard ? child(context, chartData) : Card(child: child(context, chartData));
  }

  Widget child(BuildContext context, List<ChartData> chartData) {
    return Padding(
      padding: removePadding ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          if (title != null && compact == false) Text(title!, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(
            height: compact ? 7.h : 15.h,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryYAxis: NumericAxis(
                  isVisible: !compact,
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
