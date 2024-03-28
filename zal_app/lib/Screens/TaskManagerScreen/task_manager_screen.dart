import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/TaskManagerScreen/Widgets/taskmanager_table_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/title_widget.dart';

final selectedSortByProvider = StateProvider<SortBy>((ref) => SortBy.Memory);

class TaskManagerScreen extends ConsumerWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskProcesses = ref.watch(computerDataProvider).value?.taskmanagerProcesses ?? [];
    final sortBy = ref.watch(selectedSortByProvider);
    final sortedTaskProcesses = getSortedTaskProcesses(taskProcesses, sortBy);
    final ramUsage =
        ((ref.read(computerDataProvider).valueOrNull?.ram.memoryUsed ?? 0) + (ref.read(computerDataProvider).valueOrNull?.ram.memoryAvailable ?? 0)) *
            1024;
    return ListView(
      children: [
        SizedBox(height: 2.h),
        Center(
          child: Text(
            "Task Manager",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Center(
          child: ToggleButtons(
            constraints: const BoxConstraints(
              minHeight: 32.0,
              minWidth: 56.0,
            ),
            isSelected: SortBy.values.map((e) => e == sortBy).toList(),
            onPressed: (index) {
              ref.read(selectedSortByProvider.notifier).state = SortBy.values[index];
            },
            children: SortBy.values
                .map((e) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        e.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedTaskProcesses.length,
          itemBuilder: (context, index) {
            final process = sortedTaskProcesses[index];
            final icon = ref.read(processIconProvider).containsKey(process.name) ? ref.read(processIconProvider)[process.name] : null;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 3),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: icon != null
                                ? Image.memory(
                                    icon,
                                    gaplessPlayback: true,
                                    height: 50,
                                  )
                                : Image.asset("assets/images/icons/app.png", height: 25),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Text(
                                process.name,
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          if (process.cpuPercent != 0)
                            Text("${process.cpuPercent.toStringAsFixed(1)}%",
                                style:
                                    Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 17, color: getTemperatureColor(process.cpuPercent))),
                          InkWell(
                            onTap: () async {
                              bool response = await showConfirmDialog('are you sure?', 'do you want to kill ${process.name} process?', context);
                              if (response == false) return;
                              ref.read(webrtcProvider.notifier).sendMessage('kill_process', jsonEncode(process.pids));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(
                                FontAwesomeIcons.xmark,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Text(
                            (process.memoryUsage * 1024 * 1024).toSize(decimals: 1),
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: getRamAmountColor(process.memoryUsage),
                                ),
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (process.memoryUsage / ramUsage),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            if (index == 5) {
              return InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/3866023931" : "ca-app-pub-5545344389727160/8905268635");
            }
            return Container();
          },
        ),
        //TaskmanagerTableWidget(processes: sortedTaskProcesses),
      ],
    );
  }

  List<TaskmanagerProcess> getSortedTaskProcesses(List<TaskmanagerProcess> taskProcesses, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.Name:
        taskProcesses.sort((b, a) => a.name.compareTo(b.name));
        break;
      case SortBy.Memory:
        taskProcesses.sort((b, a) => a.memoryUsage.compareTo(b.memoryUsage));
        break;
      //case SortBy.Cpu:
      //  taskProcesses.sort((b, a) => a.cpuPercent.compareTo(b.cpuPercent));
      //  break;
    }
    return taskProcesses;
  }
}
