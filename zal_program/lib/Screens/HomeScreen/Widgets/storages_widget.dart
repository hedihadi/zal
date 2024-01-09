import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/StorageScreen/storage_screen.dart';

class StoragesWidget extends ConsumerWidget {
  const StoragesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSocket = ref.watch(localSocketProvider);
    return localSocket.when(
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null || (data.storages.isEmpty ?? true)) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Storages",
              style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 16.sp),
            ),
            customGridForStoragesWidget(data.storages, context, ref),
          ],
        );
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

  Widget getStorageWidget(Storage storage, BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 0.5.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset("assets/images/icons/${storage.type}.png", height: 3.h),
                    Text(
                      "${truncateString(storage.partitions?.firstOrNull?.label ?? "", 10)} | ${storage.totalSize.toSize(decimals: 0)}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Text(
                  getTemperatureText(storage.temperature.toDouble(), ref),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(storage.temperature.toDouble())),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                            canScaleToFit: true,
                            startAngle: 0,
                            endAngle: 360,
                            showTicks: false,
                            showLabels: false,
                            axisLineStyle: const AxisLineStyle(thickness: 10),
                            pointers: <GaugePointer>[
                              RangePointer(
                                value: ((storage.totalSize - storage.freeSpace) / storage.totalSize) * 100,
                                width: 10,
                                color: Theme.of(context).primaryColor,
                                enableAnimation: true,
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Text(
                                    storage.freeSpace.toSize(),
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor, fontSize: 12.sp),
                                  ),
                                  angle: 270,
                                  positionFactor: 0.1),
                            ])
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: <TableRow>[
                      tableRow(
                        context,
                        "",
                        FontAwesomeIcons.magnifyingGlass,
                        "${storage.readRate.toSize()}/s",
                      ),
                      tableRow(
                        context,
                        "",
                        FontAwesomeIcons.pencil,
                        "${storage.writeRate.toSize()}/s",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StorageScreen(diskNumber: storage.diskNumber)));
                    //showWindowDialog(StorageScreen(diskNumber: storage.diskNumber), context);
                  },
                  child: const Text("Open"),
                )),
          ],
        ),
      ),
    );
  }

  Widget customGridForStoragesWidget(List<Storage> storages, BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.3),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storages.length,
      itemBuilder: (BuildContext context, int index) {
        return getStorageWidget(storages[index], context, ref);
      },
    );
  }
}
