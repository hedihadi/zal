import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zal/Functions/models.dart';

class LocalDatabaseManager {
  static Future<ComputerSpecs?> loadComputerSpecs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('computerSpecs')) {
      return ComputerSpecs.fromJson(prefs.getString('computerSpecs')!);
    }
    return null;
  }

  static Future<void> saveComputerSpecs(ComputerSpecs computerSpecs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('computerSpecs', computerSpecs.toJson());
  }

  //static Future<void> saveProgramTimes(List<ProgramTime> programTimes) async {
  //  var box = await Hive.openBox('myBox');
  //  box.put('program-times', jsonEncode(programTimes.map((e) => e.toMap()).toList()));
  //}
//
  //static Future<List<ProgramTime>?> loadProgramTimes() async {
  //  var box = await Hive.openBox('myBox');
  //  final String? data = box.get('program-times');
  //  if (data == null) return null;
//
  //  final parsedData = jsonDecode(data);
  //  final List<ProgramTime> result = [];
  //  for (final data in parsedData) {
  //    result.add(ProgramTime.fromMap(data));
  //  }
  //  return result;
  //}

  static Future<String?> getProgramIcon(String name) async {
    var box = await Hive.openBox('program-icons');
    final data = box.get(name);
    return data;
  }

  static Future<void> saveProgramIcon(String name, String base64Icon) async {
    var box = await Hive.openBox('program-icons');
    await box.put(name, base64Icon);
  }
}
