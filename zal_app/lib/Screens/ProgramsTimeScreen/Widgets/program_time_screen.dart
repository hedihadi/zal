import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_provider.dart';

final programTimetouchedIndexProvider = StateProvider<int>((ref) => -1);

class ProgramTimeScreen extends ConsumerWidget {
  const ProgramTimeScreen({super.key, required this.programTime});
  final ProgramTime programTime;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programTimes = ref.watch(programTimeProvider(programTime.name));
    final touchedIndex = ref.watch(programTimetouchedIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(programTime.name),
      ),
      body: programTimes.when(
        data: (data) {
          final largestNumber = data.dates.values.toList().reduce((value, element) => value > element ? value : element).toDouble();
          List<int> numbersList = [];
          int stepSize = ((largestNumber - 60) / 7).floor();

          for (int i = 0; i < 8; i++) {
            int currentNumber = (largestNumber - (stepSize * i)).toInt();
            currentNumber = (currentNumber / 10).round() * 10; // Round to the nearest multiple of 10
            numbersList.add(currentNumber);
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
            child: ListView(
              children: [
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    "${(data.totalYear / 60).round()} hours",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 25),
                  ),
                ),
                const Center(
                  child: Text(
                    'this year',
                    style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                  ),
                ),
                SizedBox(height: 5.h),
                const Divider(),
                AspectRatio(
                  aspectRatio: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              programTime.name,
                              style: const TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text(
                            'Last 7 days',
                            style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3.w),
                        child: Text(
                          "${convertMinutesToHoursAndMinutes(data.dates.entries.last.value)} today",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xff77839a)),
                        ),
                      ),
                      SizedBox(height: 3.h),
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
                                    ref.read(programTimetouchedIndexProvider.notifier).state = -1;
                                  } else {
                                    ref.read(programTimetouchedIndexProvider.notifier).state = x;
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
                                        style: const TextStyle(color: Colors.yellow),
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
                                  getTitlesWidget: (value, meta) => bottomTitles(value, meta, data.dates),
                                  reservedSize: 42,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) => leftTitles(value, meta, numbersList),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            barGroups: data.dates.entries.map<BarChartGroupData>((e) {
                              final index = data.dates.keys.toList().indexOf(e.key);
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
                                    color: Colors.yellow,
                                    width: 10,
                                  ),
                                ],
                              );
                            }).toList(),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          print(error);
          print(stackTrace);
          return Text("error getting ${programTime.name} data from API, make sure you have Internet connection.");
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.red,
          width: 100,
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.green,
          width: 100,
        ),
      ],
    );
  }
}
