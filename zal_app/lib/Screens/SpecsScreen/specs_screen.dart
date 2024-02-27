import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:sizer/sizer.dart';

import '../../Functions/analytics_manager.dart';

class SpecsScreen extends ConsumerWidget {
  const SpecsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("specs"));
    final socket = ref.watch(computerDataProvider);
    return socket.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        final table = Table(
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
              data.motherboard.name,
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
              "${ref.watch(primaryGpuProvider)?.name}",
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.cpu.cpuInfo.name,
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
              "${(data.ram.memoryAvailable + data.ram.memoryUsed).round()} GB:\n${data.ram.ramPieces.map((e) => '      ${e.capacity.toSize(decimals: 0)} ${e.clockSpeed}Mhz ${e.manufacturer}\n').toString().replaceAll('(', '').replaceAll(')', '').replaceAll(', ', '')}",
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
              data.storages
                  .map((e) => '${(e.totalSize / 1000 / 1000 / 1000).round()} GB ${e.type}\n')
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll(', ', ''),
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
              data.monitors
                  .map((e) => '${e.width} x ${e.height}${e.primary ? ' primary' : ''}\n')
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll(', ', ''),
              customIcon: Image.asset(
                "assets/images/icons/monitor.png",
                height: 25,
              ),
              addSpacing: true,
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: table,
        );
      },
      error: (error, stackTrace) {
        return Container();
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}
