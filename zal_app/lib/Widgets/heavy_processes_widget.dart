import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/TaskManagerScreen/Widgets/taskmanager_table_widget.dart';

class HeavyProcessesWidget extends ConsumerWidget {
  const HeavyProcessesWidget({super.key, required this.title, required this.sortBy});
  final String title;
  final SortBy sortBy;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskProcesses = ref.watch(socketProvider).value?.taskmanagerProcesses ?? [];
    final sortedProcesses = getSortedTaskProcesses(taskProcesses, sortBy, 5);
    if (sortedProcesses.isEmpty) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        TaskmanagerTableWidget(processes: sortedProcesses, shouldRoundCorners: false),
      ],
    );
  }

  List<TaskmanagerProcess> getSortedTaskProcesses(List<TaskmanagerProcess> taskProcesses, SortBy sortBy, int amount) {
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

    return taskProcesses.take(amount).toList();
  }
}
