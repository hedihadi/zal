import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/models.dart';

class ComputerSpecsNotifier extends AsyncNotifier<ComputerSpecs?> {
  Future<void> saveSettings(ComputerData data) async {
    final computerSpecs = ComputerSpecs.fromComputerData(data);
    state = AsyncData(computerSpecs);
    await LocalDatabaseManager.saveComputerSpecs(computerSpecs);
  }

  Future<ComputerSpecs?> _fetchData() async {
    return await LocalDatabaseManager.loadComputerSpecs();
  }

  @override
  Future<ComputerSpecs?> build() async {
    return _fetchData();
  }
}

final computerSpecsProvider = AsyncNotifierProvider<ComputerSpecsNotifier, ComputerSpecs?>(() {
  return ComputerSpecsNotifier();
});
