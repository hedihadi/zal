import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';

class TaskmanagerNotifier extends Notifier<List<TaskmanagerProcess>> {
  List<String> sentProcessNames = [];
  @override
  List<TaskmanagerProcess> build() {
    final computerData = ref.watch(localSocketProvider).valueOrNull;
    if (computerData == null) return [];
    final taskmanagerData = computerData.taskmanagerData ?? {};
    List<TaskmanagerProcess> processes = [];
    for (final taskmanagerRaw in Map<String, dynamic>.from(taskmanagerData).entries.toList()) {
      final String processName = taskmanagerRaw.key;
      final shouldAddIcon = sentProcessNames.contains(processName) == false;
      processes.add(TaskmanagerProcess.fromMap(processName, taskmanagerRaw.value, addIcon: shouldAddIcon));
      if (shouldAddIcon) {
        sentProcessNames.add(processName);
      }
    }
    return processes;
  }

  reset() {
    sentProcessNames.clear();
  }

  List<Map<String, dynamic>> getParsedProcesses() {
    final processes = state;
    List<Map<String, dynamic>> parsedData = [];
    for (final process in processes) {
      parsedData.add(process.toMap());
    }
    return parsedData;
  }
}

///this provider keeps track of what process's icons we've sent to the mobile.
///as the icons are large in size, we want to only send it once.
///when the mobile app disconnects, this provider will reset, so when the app re-launches, we send the icons once again.
final taskmanagerProvider = NotifierProvider<TaskmanagerNotifier, List<TaskmanagerProcess>>(() {
  return TaskmanagerNotifier();
});
