import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_screen.dart';

class ProgramTimesNotifier extends AsyncNotifier<List<ProgramTime>?> {
  List<ProgramTime> _parseData(String data) {
    final List<ProgramTime> result = [];
    final parsedData = jsonDecode(data);
    for (final programTime in parsedData) {
      result.add(ProgramTime.fromMap(programTime));
    }
    return result;
  }

  @override
  FutureOr<List<ProgramTime>?> build() async {
    ref.watch(programtimeFrameProvider);
    //final programTimes = await LocalDatabaseManager.loadProgramTimes();
    // getNewDataFromNetwork();
    //if (programTimes != null) {
    //  programTimes.sort((b, a) => a.minutes.compareTo(b.minutes));
    //  return programTimes;
    //}
    final programTimesFromNetwork = await getProgramTimesFromNetwork();
    programTimesFromNetwork?.sort((b, a) => a.minutes.compareTo(b.minutes));
        return programTimesFromNetwork;
  }

  Future<void> getNewDataFromNetwork() async {
    final data = await getProgramTimesFromNetwork();
    if (data != null) {
      //await LocalDatabaseManager.saveProgramTimes(data);
      data.sort((b, a) => a.minutes.compareTo(b.minutes));

      state = AsyncData(data);
    }
  }

  int totalMinutesSpentToday() {
    int result = 0;
    for (final ProgramTime programTime in (state.valueOrNull ?? [])) {
      result = result + programTime.minutes;
    }
    return result;
  }

  Future<List<ProgramTime>?> getProgramTimesFromNetwork() async {
    final response = await AnalyticsManager.getDataFromDatabase("program-times", queries: {'date_range': ref.read(programtimeFrameProvider).name});
    if (response.statusCode != 200) return null;
    final data = _parseData(response.body);
    return data;
  }
}

final programTimesProvider = AsyncNotifierProvider<ProgramTimesNotifier, List<ProgramTime>?>(() => ProgramTimesNotifier());

class ProgramIconsNotifier extends AsyncNotifier<Map<String, String>?> {
  @override
  FutureOr<Map<String, String>?> build() async {
    int delay = 0;
    final programTimes = await ref.watch(programTimesProvider.future);
    final processIcon = ref.watch(_programIconsProvider);
    if (programTimes == null) {
      return state.value;
    }
    final Map<String, String> result = state.valueOrNull ?? {};
    if (processIcon.value != null) {
      final parsedData = jsonDecode(processIcon.value!.data!.data);
      result[parsedData['name']] = parsedData['icon'];
      LocalDatabaseManager.saveProgramIcon(parsedData['name'], parsedData['icon']);
    }
    for (final programTime in programTimes) {
      if (result.containsKey(programTime.name) == false) {
        //try to get the program icon from local storage
        final iconFromLocal = await LocalDatabaseManager.getProgramIcon(programTime.name);
        if (iconFromLocal != null) {
          result[programTime.name] = iconFromLocal;
        } else {
          delay = delay + 100;
          Future.delayed(Duration(milliseconds: delay), () async {
            ref.read(webrtcProvider.notifier).sendMessage('get_process_icon', programTime.name);
          });
        }
      }
    }
    return result;
  }

  String? getProgramIcon(String name) {
    if (state.value?.containsKey(name) ?? false) {
      return state.value![name];
    }
    return null;
  }
}

final programIconsProvider = AsyncNotifierProvider<ProgramIconsNotifier, Map<String, String>?>(() => ProgramIconsNotifier());

final _programIconsProvider = FutureProvider<WebrtcProviderModel>((ref) {
  final sub = ref.listen(webrtcProvider, (prev, cur) {
    if (cur.data?.type == WebrtcDataType.processIcon) {
      ref.state = AsyncData(cur);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});

final programTimeProvider = FutureProvider.family<ProgramTimeScreenData, String>((ref, name) async {
  final response = await AnalyticsManager.getDataFromDatabase("program-times/show", queries: {'program_name': name});
  return ProgramTimeScreenData.fromJson(response.body);
});
