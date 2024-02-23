import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FilesScreen/Providers/information_text_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/cpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/gpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/is_program_adminstrator_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/ram_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/StorageScreen/storage_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:zal/Widgets/title_widget.dart';

import 'HomeScreen/Widgets/fps_widget.dart';

class StoragesScreen extends ConsumerWidget {
  const StoragesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(shouldShowUpdateDialogProvider);
    ref.read(informationTextProvider);
    final computerData = ref.watch(computerDataProvider);
    return computerData.when(
      skipLoadingOnReload: true,
      data: (data) {
        final storages = data.storages;

        return ListView(
          children: [
            const IsProgramAdminstratorWidget(),
            StaggeredGridview(
              children: [
                CpuWidget(computerData: data),
                GpuWidget(computerData: data),
                RamWidget(computerData: data),
                // if (data.battery.hasBattery) BatteryWidget(computerData: data),
                // FpsWidget(computerData: data),
                NetworkWidget(computerData: data),
              ],
            ),
            storages.isNotEmpty ? const TitleWidget("Storage") : Container(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: storages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 100.w / (100.h / 2.8)),
              itemBuilder: (context, index) {
                final storage = storages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StorageScreen(diskNumber: storage.diskNumber)));
                  },
                  child: CardWidget(
                    titleIcon: Image.asset(
                      "assets/images/icons/${storage.type}.png",
                      height: 3.h,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.2.h),
                    title: storage.getDisplayName(),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            getTemperatureText(storage.temperature.toDouble(), ref),
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: getTemperatureColor(storage.temperature.toDouble())),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 10.h,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: SfRadialGauge(
                                    animationDuration: 0,
                                    axes: <RadialAxis>[
                                      RadialAxis(
                                          canScaleToFit: true,
                                          startAngle: 0,
                                          endAngle: 360,
                                          showTicks: false,
                                          showLabels: false,
                                          axisLineStyle: const AxisLineStyle(thickness: 5),
                                          pointers: <GaugePointer>[
                                            RangePointer(
                                              value: ((storage.totalSize - storage.freeSpace) / storage.totalSize) * 100,
                                              width: 5,
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
                              child: Table(
                                defaultColumnWidth: const IntrinsicColumnWidth(),
                                children: <TableRow>[
                                  tableRow(
                                    context,
                                    "",
                                    FontAwesomeIcons.magnifyingGlass,
                                    "${storage.readRate.toSize(decimals: 0)}/s",
                                  ),
                                  tableRow(
                                    context,
                                    "",
                                    FontAwesomeIcons.pen,
                                    "${storage.writeRate.toSize(decimals: 0)}/s",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/4695435315" : "ca-app-pub-5545344389727160/5860639295"),
          ],
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return Center(child: ReportErrorWidget(error: error as ErrorParsingComputerData));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
