import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/ram_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/chart_widget.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class RamWidget extends ConsumerWidget {
  const RamWidget({super.key, required this.computerData});
  final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RamScreen()));
      },
      child: CardWidget(
        title: "RAM",
        titleIcon: Image.asset(
          "assets/images/icons/ram.png",
          height: 3.h,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Table(
              children: <TableRow>[
                //tableRow(
                //  context,
                //  "Total",
                //  FontAwesomeIcons.box,
                //  "${(computerData.ram.memoryAvailable + computerData.ram.memoryUsed).round()} GB",
                //),
                tableRow(
                  context,
                  "used",
                  FontAwesomeIcons.memory,
                  "${computerData.ram.memoryUsed.toStringAsFixed(2)} GB",
                ),
                tableRow(
                  context,
                  "free",
                  FontAwesomeIcons.memory,
                  "${computerData.ram.memoryAvailable.toStringAsFixed(2)} GB",
                ),
              ],
            ),
            const Divider(),
            ChartWidget(
              data: computerData.charts['ramPercentage'] ?? [],
              title: "Percentage",
              maxYAxisNumber: 100,
              minYAxisNumber: 0,
              yAxisLabel: '%',
              compact: true,
              wrapInCard: false,
              removePadding: true,
            ),
            Row(
              children: [
                Expanded(child: HorizontalCircleProgressBar(progress: computerData.ram.memoryUsedPercentage / 100)),
                SizedBox(width: 2.w),
                Text(
                  "${computerData.ram.memoryUsedPercentage.round()}%",
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
