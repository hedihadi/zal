import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/gpu_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class GpuWidget extends ConsumerWidget {
   GpuWidget({super.key,required this.computerData});
final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();

    final primaryGpu = ref.read(computerDataProvider.notifier).getPrimaryGpu();
    if (primaryGpu == null) {
      return Container();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GpuScreen(
                    gpuName: primaryGpu.name,
                  ))),
          child: CardWidget(
            title: "GPU",
            titleIcon: Image.asset(
              "assets/images/icons/gpu.png",
              height: 3.h,
            ),
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
                          FontAwesomeIcons.memory,
                          (primaryGpu.dedicatedMemoryUsed * 1024 * 1024).toSize(),
                        ),
                        tableRow(
                          context,
                          "",
                          FontAwesomeIcons.fan,
                          "${primaryGpu.fanSpeedPercentage.round()}%",
                        ),
                        tableRow(
                          context,
                          "",
                          Icons.power,
                          "${primaryGpu.power.round()}W",
                        ),
                      ],
                    ),
                    Text(
                      getTemperatureText(primaryGpu.temperature, ref),
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(primaryGpu.temperature)),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: HorizontalCircleProgressBar(progress: primaryGpu.corePercentage / 100)),
                    SizedBox(width: 2.w),
                    Text(
                      "${primaryGpu.corePercentage.round()}%",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
