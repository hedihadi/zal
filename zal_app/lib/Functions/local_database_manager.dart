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
}
