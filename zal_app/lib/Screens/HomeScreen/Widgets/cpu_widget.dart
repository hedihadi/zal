import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/cpu_screen.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/card_widget.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class CpuWidget extends ConsumerWidget {
  const CpuWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);

    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
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
                            "${data.cpu.clocks.entries.firstOrNull?.value?.round() ?? 'NaN'} MHZ",
                          ),
                          tableRow(
                            context,
                            "",
                            Icons.power,
                            "${data.cpu.power.round()}W",
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
                        getTemperatureText(data.cpu.temperature, ref),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(data.cpu.temperature ?? 0)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: HorizontalCircleProgressBar(progress: data.cpu.load / 100)),
                      SizedBox(width: 2.w),
                      Text(
                        "${data.cpu.load.round()}%",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container());
  }
}
