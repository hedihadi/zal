import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zal/Functions/models.dart';

class SettingsNotifier extends AsyncNotifier<Settings> {
  Future<Settings> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("settings")) {
      return Settings.fromJson(prefs.getString("settings")!);
    } else {
      return Settings.defaultSettings();
    }
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("settings", state.value!.toJson());
    ref.invalidate(settingsProvider);
  }

  updatePersonalizedAds(bool value) {
    state = AsyncData(state.value!.copyWith(personalizedAds: value));
    saveSettings();
  }

  updatePrimaryGpuName(String value) {
    state = AsyncData(state.value!.copyWith(primaryGpuName: value));
    saveSettings();
  }

  updateSendAnalytics(bool value) {
    state = AsyncData(state.value!.copyWith(sendAnalaytics: value));
    saveSettings();
  }

  updateUseCelcius(bool value) {
    state = AsyncData(state.value!.copyWith(useCelcius: value));
    saveSettings();
  }

  @override
  Future<Settings> build() async {
    return _fetchData();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(() {
  return SettingsNotifier();
});
