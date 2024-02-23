import 'dart:async';
import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_screen.dart';
import 'package:http/http.dart' as http;
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';

class GeminiNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, String>?> build() async {
    return null;
  }

  proceed() async {
    final specs = ref.read(computerSpecsProvider).value!;
    final game = ref.read(searchGameProvider);
    final prompt = '''
* **Game Name:** $game.
* **Device GPU:** ${ref.read(settingsProvider).value!['primaryGpuName']}.
* **Device CPU:** ${specs.cpuName}.
* **Device RAM:** ${specs.ramSize}.

Based on this info, fill out the blanks in the JSON below for recommended upgrades and performance details.  for each gpu recommendation, recommend a nivida and amd gpu. if no gpu upgrade is recommended, leave "gpu_upgrade_for_100fps" as null. if no cpu upgrade is required, leave "cpu_upgrade_for_100fps" as null. and retrieve the minimum & recommended specs from reliable sources. for the hardware prices, add a \$ symbol to the price. for cheap hardware price, choose a hardware between 200-300\$. for the expensive one, choose the best possible hardware:

{
"hardware_bottleneck":"gpu, cpu, or ram",
"gpu":{
 "is_my_gpu_amd_or_nvidia":amd or nvidia,
   "game_minimum_gpu":{
     "amd":"___",
     "nvidia":"___"
   },
   "game_recommended_gpu":{
     "amd":"___",
     "nvidia":"___"
   },
   "is_my_gpu_above_minimum_settings":true or false,
   "is_my_gpu_above_recommended_settings":true or false,
   "gpu_upgrade_for_100fps":{
      "mid":{
       "amd":"___",
       "nvidia":"___",
       "amd_price_new":"___",
       "amd_price_used":"___",
       "nvidia_price_new":"___",
       "nvidia_price_used":"___"
      },
      "expensive":{
       "amd":"___",
       "nvidia":"___",
       "amd_price_new":"___",
       "amd_price_used":"___",
       "nvidia_price_new":"___",
       "nvidia_price_used":"___"
      }
   }
},
  "cpu":{
   "is_my_cpu_ryzen_or_intel":"amd or nvidia",
   "game_minimum_cpu":{
     "ryzen":"___",
     "intel":"___",
   },
   "game_recommended_cpu":{
     "ryzen":"___",
     "intel":"___",
   },
   "is_my_cpu_above_minimum_settings":true or false,
   "is_my_cpu_above_recommended_settings":true or false,
   "cpu_upgrade_for_100fps":{
      "mid":{
       "ryzen":"___",
       "intel":"___",
       "ryzen_price_new":"___",
       "ryzen_price_used":"___",
       "intel_price_new":"___",
       "intel_price_used":"___"
      },
      "expensive":{
       "ryzen":"___",
       "intel":"___",
       "ryzen_price_new":"___",
       "ryzen_price_used":"___",
       "intel_price_new":"___",
       "intel_price_used":"___"
      }
   }
},
  "ram":{
   "game_minimum_ram":"___",
   "game_recommended_ram":"___",
   "is_my_ram_above_minimum_settings":true or false,
   "is_my_ram_above_recommended_settings":true or false,
   
   }}
''';
    state = const AsyncLoading();
    try {
      final response = await Gemini.instance.text(prompt);
      final data = response?.output;
      print(data);

      final parsedData = jsonDecode((response?.output ?? '{}').replaceAll("`", "").replaceAll("json", "").replaceAll("JSON", ""));

      final isAboveMinimum = parsedData['gpu']['is_my_gpu_above_minimum_settings'] == true &&
          parsedData['cpu']['is_my_cpu_above_minimum_settings'] == true &&
          parsedData['ram']['is_my_ram_above_minimum_settings'] == true;
      final isAboveRecommended = parsedData['gpu']['is_my_gpu_above_recommended_settings'] == true &&
          parsedData['cpu']['is_my_cpu_above_recommended_settings'] == true &&
          parsedData['ram']['is_my_ram_above_recommended_settings'] == true;

      state = AsyncData(
        {
          'response': 'ok',
          'data': parsedData,
          'isAboveMinimum': isAboveMinimum,
          'isAboveRecommended': isAboveRecommended,
        },
      );
    } catch (c) {
      state = AsyncData({'response': 'error', 'data': c});
    }
  }
}

final canRunGameProvider = AsyncNotifierProvider<GeminiNotifier, Map<String, dynamic>?>(() {
  return GeminiNotifier();
});
final searchGameProvider = StateProvider<String?>((ref) => null);
