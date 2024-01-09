import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_screen.dart';
import 'package:http/http.dart' as http;

class AsyncSearchGameNotifier extends AutoDisposeAsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final gameName = ref.watch(searchGameProvider);
    final Map<String, String> result = {};
    if (gameName == null) {
      return {};
    }
    final response = await http.get(Uri.parse("https://steamcommunity.com/actions/SearchApps/$gameName"));
    final parsedData = jsonDecode(response.body);
    for (final game in parsedData) {
      result[game['name']] = game["logo"];
    }
    ref.read(isStreamLoadingProvider.notifier).state = false;
    return result;
  }
}

final searchGameResultProvider = AsyncNotifierProvider.autoDispose<AsyncSearchGameNotifier, Map<String, String>>(() {
  return AsyncSearchGameNotifier();
});
final searchGameProvider = StateProvider.autoDispose<String?>((ref) => null);
