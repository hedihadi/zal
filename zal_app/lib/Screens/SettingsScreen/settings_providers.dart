import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zal/Functions/models.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  Future<Map<String, dynamic>> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("settings")) {
      return jsonDecode(prefs.getString("settings")!);
    } else {
      return {};
    }
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("settings", jsonEncode(state.value!));
    ref.invalidate(settingsProvider);
  }

  Future<void> updateSettings(String key, dynamic value) async {
    final newValue = state.value!;
    newValue[key] = value;
    state = AsyncData(newValue);
  }
  @override
  Future<Map<String, dynamic>> build() async {
    return _fetchData();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
  return SettingsNotifier();
});
