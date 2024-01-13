import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';

class NetworkSpeedWidget extends ConsumerWidget {
  const NetworkSpeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSocket = ref.watch(localSocketProvider);
    return localSocket.when(
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null || data.networkSpeed == null) return Container();
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Network",
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
                        FontAwesomeIcons.cloudArrowUp,
                        "${data.networkSpeed!.upload.toSize(decimals: 1)}/s",
                      ),
                      tableRow(
                        context,
                        "",
                        FontAwesomeIcons.cloudArrowDown,
                        "${data.networkSpeed!.download.toSize(decimals: 1)}/s",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text("");
      },
      loading: () {
        return Container();
      },
    );
  }
}
