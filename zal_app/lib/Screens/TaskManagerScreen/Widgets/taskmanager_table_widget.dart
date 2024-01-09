import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';

//this provider holds the data
final _processIconProvider = StateProvider<Map<String, Uint8List>>((ref) => {});

//this provider subscribes to new data
final processIconProvider = StateProvider<Map<String, Uint8List>>((ref) {
  final socket = ref.watch(socketProvider);
  final oldData = ref.read(_processIconProvider);

  if (socket.hasValue == false) return oldData;
  final processes = socket.value?.taskmanagerProcesses;

  if (processes != null) {
    for (final process in processes) {
      if (process.icon != null) {
        oldData[process.name] = process.icon!;
      }
    }
  }
  ref.read(_processIconProvider.notifier).state = oldData;
  return oldData;
});

class TaskmanagerTableWidget extends ConsumerWidget {
  const TaskmanagerTableWidget({super.key, required this.processes, this.shouldRoundCorners = true});
  final List<TaskmanagerProcess> processes;
  final bool shouldRoundCorners;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Table(
      //border: TableBorder.all(width: 1),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: shouldRoundCorners
                  ? const BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                    )
                  : null,
            ),
            children: [
              Container(),
              Text(
                "Process",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
              ),
              Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: Text(
                  "CPU %",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              Text(
                "Memory",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
              ),
              Container(),
            ]),
        ...processes
            .map(
              (process) => TableRow(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: ref.read(processIconProvider)[process.name] != null
                        ? Image.memory(
                            ref.read(processIconProvider)[process.name]!,
                            gaplessPlayback: true,
                            scale: 0.5,
                          )
                        : const Icon(FontAwesomeIcons.question),
                  ),
                  Text(process.name, style: Theme.of(context).textTheme.titleSmall),
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: Text("${process.cpuPercent.toStringAsFixed(1)}%",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 17, color: getTemperatureColor(process.cpuPercent))),
                  ),
                  Text((process.memoryUsage * 1024 * 1024).toSize(decimals: 1),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 17, color: getRamAmountColor(process.memoryUsage))),
                  IconButton(
                      onPressed: () async {
                        bool response =
                            await showConfirmDialog('are you sure?', '${process.name} will be killed, destroyed, absolutely annihilated.', context);
                        if (response == false) return;
                        ref.read(socketObjectProvider.notifier).state!.sendData('kill_process', jsonEncode(process.pids));
                      },
                      icon: Icon(
                        FontAwesomeIcons.xmark,
                        color: Theme.of(context).colorScheme.error,
                      ))
                ],
              ),
            )
            .toList()
      ],
    );
  }
}
