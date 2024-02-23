import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/consumer_times_provider.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_screen.dart';

final touchedIndexProvider = StateProvider<int>((ref) => -1);

class WeekChart extends ConsumerWidget {
  const WeekChart({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchedIndex = ref.watch(touchedIndexProvider);
    final weekConsumerTime = ref.watch(weekConsumerTimeProvider);
    if (weekConsumerTime.valueOrNull == null) return Container();

    final largestNumber = weekConsumerTime.value!.values.toList().reduce((value, element) => value > element ? value : element).toDouble();
    List<int> numbersList = [];
    int stepSize = ((largestNumber - 60) / 3).floor();

    for (int i = 0; i < 4; i++) {
      int currentNumber = (largestNumber - (stepSize * i)).toInt();
      numbersList.add(currentNumber);
    }
    return AspectRatio(
      aspectRatio: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(width: 3.w),
              const Text(
                'Usage',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  "${convertMinutesToHoursAndMinutes(weekConsumerTime.value!.entries.last.value)} today",
                  style: const TextStyle(color: Color(0xff77839a), fontSize: 16),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProgramTimesScreen()));
                  },
                  child: const Text("Apps"),
                ),
              ),
            ],
          ),
          //Padding(
          //  padding: EdgeInsets.only(left: 3.w),
          //  child: Text(
          //    "${convertMinutesToHoursAndMinutes(weekConsumerTime.value!.entries.last.value)} today",
          //    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xff77839a)),
          //  ),
          //),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: largestNumber,
                barTouchData: BarTouchData(
                  mouseCursorResolver: (event, response) {
                    return response == null || response.spot == null ? MouseCursor.defer : SystemMouseCursors.click;
                  },
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (response != null && response.spot != null && event is FlTapUpEvent) {
                      final x = response.spot!.touchedBarGroup.x;
                      final isShowing = touchedIndex == x;
                      if (isShowing) {
                        ref.read(touchedIndexProvider.notifier).state = -1;
                      } else {
                        ref.read(touchedIndexProvider.notifier).state = x;
                      }
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Theme.of(context).appBarTheme.backgroundColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String weekDay;
                      switch (group.x) {
                        case 0:
                          weekDay = 'Monday';
                          break;
                        case 1:
                          weekDay = 'Tuesday';
                          break;
                        case 2:
                          weekDay = 'Wednesday';
                          break;
                        case 3:
                          weekDay = 'Thursday';
                          break;
                        case 4:
                          weekDay = 'Friday';
                          break;
                        case 5:
                          weekDay = 'Saturday';
                          break;
                        case 6:
                          weekDay = 'Sunday';
                          break;
                        default:
                          throw Error();
                      }
                      return BarTooltipItem(
                        '$weekDay\n',
                        const TextStyle(),
                        children: <TextSpan>[
                          TextSpan(
                            text: convertMinutesToHoursAndMinutes((rod.toY - 1).toInt()),
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => bottomTitles(value, meta, weekConsumerTime.valueOrNull!),
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 60,
                      interval: 1,
                      getTitlesWidget: (value, meta) => leftTitles(value, meta, numbersList),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: weekConsumerTime.value?.entries.map<BarChartGroupData>((e) {
                  final index = weekConsumerTime.value!.keys.toList().indexOf(e.key);
                  return BarChartGroupData(
                    showingTooltipIndicators: touchedIndex == index ? [0, 1, 2, 3, 4, 5, 6] : [],
                    x: index,
                    barRods: [
                      BarChartRodData(
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          toY: largestNumber,
                        ),
                        toY: e.value.toDouble(),
                        color: Theme.of(context).primaryColor,
                        width: 10,
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget bottomTitles(double value, TitleMeta meta, Map<DateTime, int> weekConsumerTime) {
    final titles = weekConsumerTime.entries.map<String>((e) => getDayName(e.key)).toList();

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  String getDayName(DateTime date) {
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
