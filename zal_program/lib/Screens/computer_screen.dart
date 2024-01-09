import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/utils.dart';

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

class ComputerScreen extends ConsumerWidget {
  const ComputerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSpecs = ref.watch(computerSpecsProvider);
    return computerSpecs.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null) return Container();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: <TableRow>[
              tableRow(
                context,
                "",
                FontAwesomeIcons.chessBoard,
                data.motherboardName,
                addSpacing: true,
                customIcon: Image.asset(
                  "assets/images/icons/motherboard.png",
                  height: 25,
                ),
              ),
              tableRow(
                context,
                "",
                customIcon: Image.asset(
                  "assets/images/icons/gpu.png",
                  height: 25,
                ),
                Icons.power,
                data.gpusName.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
                addSpacing: true,
              ),
              tableRow(
                context,
                "",
                Icons.power,
                data.cpuName,
                customIcon: Image.asset(
                  "assets/images/icons/cpu.png",
                  height: 25,
                ),
                addSpacing: true,
              ),
              tableRow(
                context,
                "",
                Icons.power,
                data.ramSize,
                customIcon: Image.asset(
                  "assets/images/icons/ram.png",
                  height: 25,
                ),
                addSpacing: true,
              ),
              tableRow(
                context,
                "",
                Icons.power,
                data.storages.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
                customIcon: Image.asset(
                  "assets/images/icons/memorycard.png",
                  height: 25,
                ),
                addSpacing: true,
              ),
              tableRow(
                context,
                "",
                Icons.power,
                data.monitors.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
                customIcon: Image.asset(
                  "assets/images/icons/monitor.png",
                  height: 25,
                ),
                addSpacing: true,
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);

        print(stackTrace);
        return Text("$error");
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}
