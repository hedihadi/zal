import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Widgets/chart_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CpuDataListWidget extends ConsumerWidget {
  const CpuDataListWidget({super.key, required this.cpu});
  final Cpu cpu;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        tableRow(
          context,
          "Power",
          FontAwesomeIcons.plug,
          "${cpu.power.round()}W",
        ),
        tableRow(
          context,
          "Temperature",
          FontAwesomeIcons.temperatureFull,
          getTemperatureText(cpu.temperature, ref),
        ),
        tableRow(
          context,
          "Load",
          Icons.scale,
          "${cpu.load.round()}%",
        ),
      ],
    );
  }
}
