import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/network_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';

class NetworkWidget extends ConsumerWidget {
  const NetworkWidget({super.key, required this.computerData});
  final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NetworkScreen()));
      },
      child: CardWidget(
        title: "Network",
        titleIcon: Image.asset(
          "assets/images/icons/wifi.png",
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
                Expanded(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: IntrinsicColumnWidth(flex: 2),
                    },
                    children: <TableRow>[
                      tableRow(
                        context,
                        "",
                        FontAwesomeIcons.cloudArrowUp,
                        "${computerData.networkSpeed?.upload.toSize(decimals: 1)}/s",
                      ),
                      tableRow(
                        context,
                        "",
                        FontAwesomeIcons.cloudArrowDown,
                        "${computerData.networkSpeed?.download.toSize(decimals: 1)}/s",
                      ),
                    ],
                  ),
                ),
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
                      FontAwesomeIcons.cloudArrowUp,
                      computerData.networkInterfaces.firstWhereOrNull((element) => element.isPrimary == true)?.bytesSent.toSize(decimals: 1) ?? '0B',
                    ),
                    tableRow(
                      context,
                      "",
                      FontAwesomeIcons.cloudArrowDown,
                      computerData.networkInterfaces.firstWhereOrNull((element) => element.isPrimary == true)?.bytesReceived.toSize(decimals: 1) ??
                          '0B',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
