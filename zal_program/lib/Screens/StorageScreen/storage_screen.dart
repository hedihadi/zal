import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/StorageScreen/Widgets/partition_widget.dart';
import 'package:zal/Screens/StorageScreen/Widgets/smart_data_table_widget.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_info_widget.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key, required this.diskNumber});
  final int diskNumber;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(localSocketProvider);
    final storages = computerSocket.value!.storages;
    final foundStorages = storages.where((element) => element.diskNumber == diskNumber).toList() ?? [];
    if (foundStorages.isEmpty) return const SelectableText("storage doesn't exist anymore :o where did it go?");
    final storage = foundStorages.first;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/icons/${storage.type}.png", height: 3.h),
            SelectableText("${truncateString(storage.partitions?.firstOrNull?.label ?? "", 10)} | ${storage.totalSize.toSize(decimals: 0)}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 3.h),
        child: ListView(
          children: [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 15.h,
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
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: SelectableText(
                                            storage.freeSpace.toSize(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(color: Theme.of(context).primaryColor, fontSize: 15.sp),
                                          ),
                                          angle: 270,
                                          positionFactor: 0.1),
                                    ])
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "Disk number",
                              FontAwesomeIcons.indent,
                              "${storage.diskNumber}",
                            ),
                            tableRow(
                              context,
                              "Model",
                              Icons.analytics,
                              "${storage.info['model']}",
                            ),
                            tableRow(
                              context,
                              "Temperature",
                              FontAwesomeIcons.temperatureFull,
                              getTemperatureText(storage.temperature.toDouble(), ref),
                            ),
                            tableRow(
                              context,
                              "Type",
                              FontAwesomeIcons.question,
                              storage.type,
                            ),
                            tableRow(
                              context,
                              "Size",
                              FontAwesomeIcons.boxesStacked,
                              storage.totalSize.toSize(),
                            ),
                            tableRow(
                              context,
                              "Free",
                              FontAwesomeIcons.boxOpen,
                              storage.freeSpace.toSize(),
                            ),
                            tableRow(
                              context,
                              "Read",
                              FontAwesomeIcons.eye,
                              "${storage.readRate.toSize()}/s",
                            ),
                            tableRow(
                              context,
                              "Write",
                              FontAwesomeIcons.pencil,
                              "${storage.writeRate.toSize()}/s",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: storage.partitions?.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 100.w / (100.h / 10),
                    ),
                    itemBuilder: (context, index) {
                      return PartitionWidget(partition: storage.partitions![index]);
                    },
                  ),
                ],
              ),
            ),
            StorageInfoWidget(info: storage.info),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                "S.M.A.R.T Data",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),
            SmartDataTableWidget(storage: storage),
          ],
        ),
      ),
    );
  }
}
