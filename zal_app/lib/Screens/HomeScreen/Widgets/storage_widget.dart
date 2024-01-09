import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/StorageScreen/storage_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/title_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StorageWidget extends ConsumerWidget {
  const StorageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);

    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
          final storages = data.storages;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          );
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container());
  }
}
