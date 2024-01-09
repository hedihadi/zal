import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/ram_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../Widgets/horizontal_circle_progressbar.dart';

class RamWidget extends ConsumerWidget {
  const RamWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);

    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Table(
                    children: <TableRow>[
                      tableRow(
                        context,
                        "Total",
                        FontAwesomeIcons.box,
                        "${(data.ram.memoryAvailable + data.ram.memoryUsed).round()} GB",
                      ),
                      tableRow(
                        context,
                        "used",
                        FontAwesomeIcons.memory,
                        "${data.ram.memoryUsed.toStringAsFixed(2)} GB",
                      ),
                      tableRow(
                        context,
                        "free",
                        FontAwesomeIcons.memory,
                        "${data.ram.memoryAvailable.toStringAsFixed(2)} GB",
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: HorizontalCircleProgressBar(progress: data.ram.memoryUsedPercentage / 100)),
                      SizedBox(width: 2.w),
                      Text(
                        "${data.ram.memoryUsedPercentage.round()}%",
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
