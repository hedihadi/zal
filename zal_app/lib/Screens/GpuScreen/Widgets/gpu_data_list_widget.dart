import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';

class GpuDataListWidget extends ConsumerWidget {
  const GpuDataListWidget({super.key, required this.gpu});
  final Gpu gpu;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        tableRow(
          context,
          "Temperature",
          FontAwesomeIcons.temperatureFull,
          getTemperatureText(gpu.temperature, ref),
          addSpacing: true,
          suffixIcon: InkWell(
            onTap: () {
              showInformationDialog(
                  null,
                  "the shown temperature is hotspot temperature, which shows the hottest sensored temp on your GPU.\nGpus has many temperature representations, we have chosen to show hotspot as it's the more critical one amongst the others.",
                  context);
            },
            child: Icon(
              FontAwesomeIcons.question,
              size: 2.h,
            ),
          ),
        ),
        tableRow(
          context,
          "Load",
          Icons.scale,
          "${gpu.corePercentage.round()}%",
          addSpacing: true,
        ),
        tableRow(
          context,
          "Core Speed",
          FontAwesomeIcons.gauge,
          "${gpu.coreSpeed.round()}Mhz",
        ),
        tableRow(
          context,
          "Memory Speed",
          Icons.memory,
          "${gpu.memorySpeed.round()}Mhz",
        ),
        tableRow(
          context,
          "Memory Usage",
          Icons.memory,
          (gpu.dedicatedMemoryUsed * 1000 * 1000).toSize(),
        ),
        tableRow(
          context,
          "Power",
          FontAwesomeIcons.plug,
          "${gpu.power.round()}W",
        ),
        tableRow(
          context,
          "Voltage",
          Icons.electric_bolt,
          "${gpu.voltage.toStringAsFixed(2)}V",
        ),
        tableRow(
          context,
          "Fan Speed",
          FontAwesomeIcons.fan,
          "${gpu.fanSpeedPercentage.round()}%",
        ),
      ],
    );
  }
}
