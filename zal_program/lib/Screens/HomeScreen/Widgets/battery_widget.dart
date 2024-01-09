import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class BatteryWidget extends ConsumerWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSocket = ref.watch(localSocketProvider);
    return localSocket.when(
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null) return Container();
        final battery = data.battery;
        if (battery == null) return Container();
        //final battery = Battery(isCharging: true, batteryPercentage: 56, lifeRemaining: 43453, hasBattery: true);
        if (battery.hasBattery) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Battery",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 14.sp),
                  ),
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
                  Row(
                    children: [
                      Expanded(child: LinearProgressIndicator(value: battery.batteryPercentage / 100)),
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
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text("error");
      },
      loading: () {
        return Container();
      },
    );
  }
}
