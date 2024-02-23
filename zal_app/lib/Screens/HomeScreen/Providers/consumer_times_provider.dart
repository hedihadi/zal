import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_screen.dart';

final todayConsumerTimeProvider = FutureProvider<int?>((ref) async {
  final response = await AnalyticsManager.getDataFromDatabase("consumer-times", queries: {'date_range': 'today'});
  if (response.statusCode != 200) return null;
  final data = int.parse(response.body);
  return data;
});

final consumerTimeProvider = FutureProvider<int?>((ref) async {
  final programtimeFrame = ref.watch(programtimeFrameProvider);
  final response = await AnalyticsManager.getDataFromDatabase("consumer-times", queries: {'date_range': programtimeFrame.name});
  if (response.statusCode != 200) return null;
  final data = int.parse(response.body);
  return data;
});

final weekConsumerTimeProvider = FutureProvider<Map<DateTime, int>?>((ref) async {
  final response = await AnalyticsManager.getDataFromDatabase("consumer-times/week");
  if (response.statusCode != 200) return null;
  final parsedData = Map<String, int>.from(jsonDecode(response.body));
  Map<DateTime, int> result = {};
  for (final data in parsedData.entries) {
    DateTime dateTime = DateFormat("yyyy-MM-dd").parse(data.key);
    result[dateTime] = data.value;
  }
  return result;
});
