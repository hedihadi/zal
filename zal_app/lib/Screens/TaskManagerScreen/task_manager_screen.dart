import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/TaskManagerScreen/Widgets/taskmanager_table_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';

final selectedSortByProvider = StateProvider<SortBy>((ref) => SortBy.Memory);

class TaskManagerScreen extends ConsumerWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskProcesses = ref.watch(socketProvider).value?.taskmanagerProcesses ?? [];
    final sortBy = ref.watch(selectedSortByProvider);
    final sortedTaskProcesses = getSortedTaskProcesses(taskProcesses, sortBy);
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),
      body: ListView(
        children: [
          SizedBox(height: 2.h),
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
          TaskmanagerTableWidget(processes: sortedTaskProcesses),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
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
      case SortBy.Cpu:
        taskProcesses.sort((b, a) => a.cpuPercent.compareTo(b.cpuPercent));
        break;
    }
    return taskProcesses;
  }
}
