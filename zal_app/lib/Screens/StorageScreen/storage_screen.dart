import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Screens/ConnectedScreen/connected_screen_providers.dart';
import 'package:zal/Screens/StorageScreen/Widgets/smart_data_widget.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_drives_widget.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_information_widget.dart';
import '../../Functions/analytics_manager.dart';
import '../../Widgets/inline_ad.dart';
import 'package:url_launcher/url_launcher.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key, required this.diskNumber});
  final int diskNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("storage"));
    final computerData = ref.watch(computerDataProvider).value;
    if (computerData == null) return Container();
    final storages = computerData.storages;
    final foundStorages = storages.where((element) => element.diskNumber == diskNumber).toList();
    if (foundStorages.isEmpty) return const Text("storage doesn't exist anymore :o where did it go?");
    final storage = foundStorages.first;

    return Scaffold(
      appBar: AppBar(
        title: Text("Storage ${storage.diskNumber}"),
        actions: [
          IconButton(
            onPressed: () {
              launchUrl(Uri.parse("https://zalapp.com/info#storage"), mode: LaunchMode.inAppWebView);
            },
            icon: const Icon(FontAwesomeIcons.question),
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text("${truncateString(storage.partitions?.first.label ?? "", 10)} | ${storage.totalSize.toSize(decimals: 0)}",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
                  SizedBox(height: 3.h),
                  Row(
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
                                        cornerStyle: CornerStyle.bothCurve,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                            (storage.freeSpace).toSize(decimals: 1),
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
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
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Table(
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
                      ),
                    ],
                  ),
                  StorageDrivesWidget(storage: storage),
                ],
              ),
            ),
          ),
          //StorageErrorsWidget(storage: storage),
          const SizedBox(height: 40),
          Card(
            elevation: 0.5,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Info",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  StorageInformationWidget(storage: storage),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            elevation: 0.5,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "S.M.A.R.T. data",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  SmartDataTableWidget(storage: storage),
                ],
              ),
            ),
          ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
