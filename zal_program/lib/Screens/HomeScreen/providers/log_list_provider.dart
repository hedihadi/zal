import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogListNotifier extends StateNotifier<List<String>> {
  LogListNotifier() : super([]);

  addElement(String text) {
    List<String> data = state;
    data.add(text);
    if (data.length > 8) {
      data.removeAt(0);
    }
    state = data;
  }
}

final logListProvider = StateNotifierProvider<LogListNotifier, List<String>>((ref) {
  return LogListNotifier();
});
