import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Screens/CpuScreen/cpu_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/chart_widget.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class CpuWidget extends ConsumerWidget {
  const CpuWidget({super.key, required this.computerData});
  final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CpuScreen()));
      },
      child: CardWidget(
        title: "CPU",
        titleIcon: Image.asset(
          "assets/images/icons/cpu.png",
          height: 3.h,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: IntrinsicColumnWidth(flex: 2),
                    1: IntrinsicColumnWidth(flex: 2),
                  },
                  children: <TableRow>[
                    tableRow(
                      context,
                      "",
                      FontAwesomeIcons.clock,
                      "${computerData.cpu.clocks.entries.firstOrNull?.value?.round() ?? 'NaN'} MHZ",
                    ),
                    tableRow(
                      context,
                      "",
                      Icons.power,
                      "${computerData.cpu.power.round()}W",
                    ),
                    tableRow(
                      context,
                      "",
                      FontAwesomeIcons.fan,
                      "",
                      showIcon: false,
                    ),
                  ],
                ),
                Text(
                  getTemperatureText(computerData.cpu.temperature, ref),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(computerData.cpu.temperature ?? 0)),
                ),
              ],
            ),
            const Divider(),
            ChartWidget(
              data: computerData.charts['cpuTemperature'] ?? [],
              title: "Temperature",
              maxYAxisNumber: 100,
              minYAxisNumber: 0,
              yAxisLabel: (ref.read(settingsProvider).valueOrNull?['useCelcius'] ?? false) ? 'c' : 'f',
              compact: true,
              wrapInCard: false,
              removePadding: true,
            ),
            Row(
              children: [
                Expanded(child: HorizontalCircleProgressBar(progress: computerData.cpu.load / 100)),
                SizedBox(width: 2.w),
                Text(
                  "${computerData.cpu.load.round()}%",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
