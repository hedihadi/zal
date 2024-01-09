import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/Widgets/select_primary_network_screen.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';

import '../Functions/analytics_manager.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(socketProvider).valueOrNull;
    ref.read(screenViewProvider("network"));
    return Scaffold(
      appBar: AppBar(title: const Text("Network")),
      body: ListView(
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 3.h),
                      Center(
                        child: Table(
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                          },
                          children: <TableRow>[
                            tableRow(
                              context,
                              "Upload Speed",
                              FontAwesomeIcons.cloudArrowUp,
                              "${computerData?.networkSpeed?.upload.toSize(decimals: 1)}/s",
                              addSpacing: true,
                            ),
                            tableRow(
                              context,
                              "Download Speed",
                              FontAwesomeIcons.cloudArrowDown,
                              "${computerData?.networkSpeed?.download.toSize(decimals: 1)}/s",
                              addSpacing: true,
                            ),
                            tableRow(
                              context,
                              "",
                              FontAwesomeIcons.cloudArrowDown,
                              "",
                              addSpacing: true,
                              showIcon: false,
                            ),
                            tableRow(
                              context,
                              "Total Upload",
                              FontAwesomeIcons.cloudArrowUp,
                              "${computerData?.networkInterfaces.firstWhereOrNull((element) => element.isPrimary == true)?.bytesSent.toSize(decimals: 1)}",
                              addSpacing: true,
                            ),
                            tableRow(
                              context,
                              "Total Download",
                              FontAwesomeIcons.cloudArrowDown,
                              "${computerData?.networkInterfaces.firstWhereOrNull((element) => element.isPrimary == true)?.bytesReceived.toSize(decimals: 1)}",
                              addSpacing: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ChartWidget(
                data: computerData?.charts['networkDownload'] ?? [],
                title: "Download",
                minYAxisNumber: 0,
                yAxisLabel: 'MB',
              ),
              ChartWidget(
                data: computerData?.charts['networkUpload'] ?? [],
                title: "Upload",
                minYAxisNumber: 0,
                yAxisLabel: 'MB',
              ),
              const Divider(),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectPrimaryNetworkScreen()));
                      },
                      icon: const Icon(FontAwesomeIcons.gear),
                      label: const Text("Primary Network"))),
            ],
          ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
