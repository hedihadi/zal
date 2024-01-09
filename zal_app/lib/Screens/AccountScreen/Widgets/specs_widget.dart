import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:sizer/sizer.dart';

class SpecsWidget extends ConsumerWidget {
  const SpecsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSpecs = ref.watch(computerSpecsProvider);
    return computerSpecs.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null) return Container();
        final table = Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: <TableRow>[
            tableRow(
              context,
              "",
              FontAwesomeIcons.chessBoard,
              data.motherboardName,
              addSpacing: true,
              customIcon: Image.asset(
                "assets/images/icons/motherboard.png",
                height: 25,
              ),
            ),
            tableRow(
              context,
              "",
              customIcon: Image.asset(
                "assets/images/icons/gpu.png",
                height: 25,
              ),
              Icons.power,
              data.gpusName.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.cpuName,
              customIcon: Image.asset(
                "assets/images/icons/cpu.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.ramSize,
              customIcon: Image.asset(
                "assets/images/icons/ram.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.storages.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
              customIcon: Image.asset(
                "assets/images/icons/memorycard.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.monitors.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'),
              customIcon: Image.asset(
                "assets/images/icons/monitor.png",
                height: 25,
              ),
              addSpacing: true,
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children:  [
              table,
              //Screenshot(
              //  controller: screenshotController,
              //  child: table,
              //),
              // Center(
              //   child: ElevatedButton.icon(
              //       onPressed: () {
              //         screenshotController.captureFromWidget(table).then((capturedImage) async {
              //           //save the image
              //           showSnackbar("took!", context);
              //         });
              //       },
              //       icon: const Icon(FontAwesomeIcons.image),
              //       label: const Text('take Screenshot')),
              // )
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);
        
        print(stackTrace);
        return Text("$error");
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}
