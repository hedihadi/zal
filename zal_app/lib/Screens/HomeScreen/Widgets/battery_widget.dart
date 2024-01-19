import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../Widgets/horizontal_circle_progressbar.dart';

class BatteryWidget extends ConsumerWidget {
   BatteryWidget({super.key,required this.computerData});
final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    if (computerData.battery.hasBattery) {
      final battery = computerData.battery;
      if (battery.hasBattery == false) return Container();
      return GestureDetector(
        onTap: () {},
        child: CardWidget(
          title: "Battery",
          titleIcon: Image.asset(
            "assets/images/icons/battery.png",
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
                        battery.lifeRemaining == -1
                            ? "forever"
                            : timeago
                                .format(DateTime.now().add(Duration(seconds: battery.lifeRemaining)), allowFromNow: true)
                                .replaceAll("from now", ""),
                      ),
                      tableRow(
                        context,
                        "",
                        Icons.power,
                        battery.isCharging ? 'charging' : 'on battery',
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(child: HorizontalCircleProgressBar(progress: battery.batteryPercentage / 100)),
                  SizedBox(width: 2.w),
                  Text(
                    "${battery.batteryPercentage}%",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
    return Container();
  }
}
