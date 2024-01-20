import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/first_row_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_speed_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/storages_widget.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/log_list_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_stream_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';

final sidebarSelectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(serverSocketStreamProvider);
    ref.watch(webrtcProvider);
    final localSocket = ref.watch(localSocketProvider);
    final notifications = ref.watch(notificationsProvider);
    final logList = ref.watch(logListProvider);
    return ListView(
      children: [
        const SizedBox(height: 5),
        const ReportErrorWidget(),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: FlexColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: FlexColumnWidth(),
          },
          children: <TableRow>[
            TableRow(children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    "Zal Server",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  width: 10, // Change the size of the circle here
                  height: 10, // Change the size of the circle here
                  decoration: BoxDecoration(
                    color: (ref.watch(serverSocketObjectProvider).value?.socket.connected ?? false) ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text((ref.watch(serverSocketObjectProvider).value?.socket.connected ?? false) ? "Connected" : "Not connected")),
              ),
              TableCell(
                child: Container(),
              ),
            ]),
            TableRow(children: [
              TableCell(child: Container(height: 30)),
              TableCell(child: Container()),
              TableCell(child: Container()),
              TableCell(child: Container()),
            ]),
            TableRow(children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    "Mobile p2p connection",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  width: 10, // Change the size of the circle here
                  height: 10, // Change the size of the circle here
                  decoration: BoxDecoration(
                    color: (ref.watch(webrtcProvider).isConnected) ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                    padding: const EdgeInsets.only(left: 5), child: Text((ref.watch(webrtcProvider).isConnected) ? "Connected" : "Not connected")),
              ),
              TableCell(
                child: Container(),
              ),
            ]),
          ],
        ),
        Card(
          elevation: 5,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: logList.length,
            itemBuilder: (context, index) {
              final log = logList[index];
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(log),
                ),
              );
            },
          ),
        ),
      ],
    );
    return ListView(
      shrinkWrap: true,
      children: [
        ElevatedButton(
            onPressed: () {
              final data = ref.read(webrtcProvider.notifier).webrtc.sendMessage('hiii');
            },
            child: const Text("send")),
        const FirstRowWidget(),
        SizedBox(height: 2.h),
        const Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: NetworkSpeedWidget(),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 150,
                child: BatteryWidget(),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        const StoragesWidget(),
        //SizedBox(height: 40.h, child: const FpsWidget()),
      ],
    );
  }
}
