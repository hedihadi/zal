import 'dart:async';
import 'dart:convert';
import 'package:color_print/color_print.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_screen.dart';
import 'package:http/http.dart' as http;
import 'package:zal/Screens/ConnectedScreen/connected_screen_providers.dart';

class GeminiNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, String>?> build() async {
    return null;
  }

  proceed() async {
    state = const AsyncLoading();

    final specs = ref.read(computerSpecsProvider).value!;
    final game = ref.read(searchGameProvider);
    final appid = ref.read(selectedGameProvider)!['appid'];
    final response = await http.get(Uri.parse("https://store.steampowered.com/api/appdetails?appids=$appid"));
    final parsedData = jsonDecode(response.body)[appid]['data'];
    final prompt = '''
* **Game Name:** $game.
* **Game Minimum Specs:** ${parsedData['pc_requirements']['minimum']}.
* **Game Recommended Specs:** ${parsedData['pc_requirements']['recommended']}.
* **My Device GPU:** ${specs.gpuName}.
* **My Device CPU:** ${specs.cpuName}.
* **My Device RAM:** ${specs.ramSize}.
''';

    try {
      final response = await Gemini.instance.text(prompt);
      final data = response?.output!.replaceAll("`", "").replaceAll("json", "").replaceAll("JSON", "");
      logInfo(data);

      final parsedData = jsonDecode((data ?? '{}'));

      final isAboveMinimum = parsedData['gpu']['is_my_gpu_above_minimum_specs'] == true &&
          parsedData['cpu']['is_my_cpu_above_minimum_specs'] == true &&
          parsedData['ram']['is_my_ram_above_minimum_specs'] == true;
      final isAboveRecommended = parsedData['gpu']['is_my_gpu_above_recommended_specs'] == true &&
          parsedData['cpu']['is_my_cpu_above_recommended_specs'] == true &&
          parsedData['ram']['is_my_ram_above_recommended_specs'] == true;

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
final gameNameProvider = StateProvider<String?>((ref) => null);

final searchGameProvider = FutureProvider<List<Map<String, String>>?>((ref) async {
  final gameName = ref.watch(gameNameProvider);
  final List<Map<String, String>> result = [];
  if (gameName == null || gameName == "") {
    return null;
  }
  final response = await http.get(Uri.parse("https://steamcommunity.com/actions/SearchApps/$gameName"));
  final parsedData = jsonDecode(response.body);
  for (final game in parsedData) {
    result.add({
      'name': game['name'].toString(),
      'logo': game['logo'].toString(),
      'appid': game['appid'].toString(),
    });
  }
  return result;
});
