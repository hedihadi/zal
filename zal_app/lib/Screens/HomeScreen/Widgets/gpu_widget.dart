import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/GpuScreen/gpu_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/chart_widget.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class GpuWidget extends ConsumerWidget {
  const GpuWidget({super.key, required this.computerData});
  final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();

    final gpu = computerData.gpu;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GpuScreen(
                    gpuName: gpu.name,
                  ))),
          child: CardWidget(
            title: "GPU",
            titleIcon: Image.asset(
              "assets/images/icons/gpu.png",
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
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                      },
                      children: <TableRow>[
                        tableRow(
                          context,
                          "",
                          FontAwesomeIcons.memory,
                          "${gpu.coreSpeed.round()}Mhz",
                        ),
                        tableRow(
                          context,
                          "",
                          FontAwesomeIcons.fan,
                          "${gpu.fanSpeedPercentage.round()}%",
                        ),
                        tableRow(
                          context,
                          "",
                          Icons.power,
                          "${gpu.power.round()}W",
                        ),
                      ],
                    ),
                    Text(
                      getTemperatureText(gpu.temperature, ref),
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(gpu.temperature)),
                    ),
                  ],
                ),
                const Divider(),
                ChartWidget(
                  data: computerData.charts['gpuLoad'] ?? [],
                  title: "Load",
                  maxYAxisNumber: 100,
                  yAxisLabel: '%',
                  compact: true,
                  wrapInCard: false,
                  removePadding: true,
                ),
                Row(
                  children: [
                    Expanded(child: HorizontalCircleProgressBar(progress: gpu.corePercentage / 100)),
                    SizedBox(width: 2.w),
                    Text(
                      "${gpu.corePercentage.round()}%",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
