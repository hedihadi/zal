import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zal/Functions/models.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  Future<Map<String, dynamic>> _fetchData() async {
    var box = await Hive.openBox('settings');
    final data = box.get('settings', defaultValue: '{}');
    return jsonDecode(data);
  }

  Future<void> saveSettings() async {
    var box = await Hive.openBox('settings');
    await box.put('settings', jsonEncode(state.value!));

    ref.invalidate(settingsProvider);
  }

  Future<void> updateSettings(String key, dynamic value, {updateState = true}) async {
    final newValue = state.value!;
    newValue[key] = value;
    if (updateState) {
      state = AsyncData(newValue);
    }
    saveSettings();
  }

  @override
  Future<Map<String, dynamic>> build() async {
    return _fetchData();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});
