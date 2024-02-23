import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zal/Functions/models.dart';

import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/consumer_times_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/ProgramsTimeScreen/Widgets/program_time_screen.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_provider.dart';

final programtimeFrameProvider = StateProvider<ProgramTimesTimeframe>((ref) => ProgramTimesTimeframe.today);

class ProgramTimesScreen extends ConsumerWidget {
  const ProgramTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programTimes = ref.watch(programTimesProvider).value;
    ref.watch(programIconsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apps usage"),
      ),
      body: ListView(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ProgramTimesTimeframe.values.map<Widget>(
              (e) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: RawChip(
                    onPressed: () {
                      ref.read(programtimeFrameProvider.notifier).state = e;
                    },
                    side: BorderSide(color: ref.watch(programtimeFrameProvider) == e ? Theme.of(context).primaryColor : Colors.transparent),
                    //backgroundColor: ref.watch(choiceProvider) == e ? Theme.of(context).primaryColor : null,
                    label: Text(e.name),
                  ),
                );
              },
            ).toList(),
          ),
          SizedBox(height: 2.h),
          SizedBox(height: 5.h),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              [ref.watch(consumerTimeProvider).isLoading, ref.watch(programTimesProvider).isLoading].contains(true)
                  ? const CircularProgressIndicator()
                  : Text(
                      convertMinutesToHoursAndMinutes(ref.watch(consumerTimeProvider).valueOrNull ?? 0).replaceAll(" and ", "\n"),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
              SfCircularChart(
                margin: EdgeInsets.zero,
                series: getSeries(programTimes ?? [], context),
                tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y mins'),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: programTimes?.length ?? 0,
            itemBuilder: (context, index) {
              final programTime = programTimes![index];
              final icon = ref.read(programIconsProvider.notifier).getProgramIcon(programTime.name);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                child: Card(
                  elevation: 1,
                  shadowColor: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (icon != null)
                          Image.memory(
                            base64Decode(icon),
                            gaplessPlayback: true,
                            scale: 1.5,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                programTime.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                convertMinutesToHoursAndMinutes(programTime.minutes),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.yellow),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showSnackbar("launching ${programTime.name}...", context);
                            ref.read(webrtcProvider.notifier).sendMessage('launch_app', programTime.name);
                          },
                          child: const Text("Launch"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProgramTimeScreen(programTime: programTime)));
                          },
                          child: const Text("View"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DoughnutSeries<ChartSampleData, String>> getSeries(List<ProgramTime> programTimes, BuildContext context) {
    return <DoughnutSeries<ChartSampleData, String>>[
      DoughnutSeries<ChartSampleData, String>(
          innerRadius: "70%",
          radius: "80%",
          dataSource: programTimes
              .map<ChartSampleData>(
                (e) => ChartSampleData(
                  x: e.name,
                  y: e.minutes,
                  text: truncateString(e.name, 30),
                ),
              )
              .toList(),
          xValueMapper: (ChartSampleData data, _) => data.x,
          yValueMapper: (ChartSampleData data, _) => data.y,
          dataLabelMapper: (ChartSampleData data, _) => data.text,
          dataLabelSettings: DataLabelSettings(
              labelPosition: ChartDataLabelPosition.outside,
              isVisible: true,
              color: Theme.of(context).cardColor,
              textStyle: const TextStyle(color: Colors.white)))
    ];
  }
}

class ChartSampleData {
  final String x;
  final int y;
  final String text;
  ChartSampleData({
    required this.x,
    required this.y,
    required this.text,
  });
}
