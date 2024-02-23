import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_provider.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_screen_pc_widget.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';
import '../../Functions/analytics_manager.dart';

final amdOrNvidiaProvider = StateProvider<AmdOrNvidia?>((ref) => null);
final ryzenOrIntelProvider = StateProvider<RyzenOrIntel?>((ref) => null);

class ResultWidget extends ConsumerWidget {
  ResultWidget({super.key, required this.result});
  Map<String, dynamic>? result;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result == null) return Container();
    if (result!['response'] == "error") {
      return Center(child: Text("something went wrong, please try again later...\n${result!['data']}"));
    }
    final specs = ref.watch(computerSpecsProvider).value;
    final gpu = ref.read(settingsProvider).value!['primaryGpuName'];
    final data = result!['data'];
    final amdOrNvidia = ref.watch(amdOrNvidiaProvider);
    final ryzenOrIntel = ref.watch(ryzenOrIntelProvider);

    return Column(
      children: [
        SizedBox(height: 1.h),
        Card(
          elevation: 1,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                title: Row(
                  children: [
                    const Text('Minimum'),
                    SizedBox(width: 2.w),
                    Icon(
                      result!['isAboveMinimum'] == true ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                      color: result!['isAboveMinimum'] == true ? Colors.green : Colors.red[300],
                      size: 20,
                    ),
                  ],
                ),
                children: [
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "GPU",
                              Icons.scale,
                              "${data['gpu']['game_minimum_gpu']['amd']}\n${data['gpu']['game_minimum_gpu']['nvidia']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['gpu']['is_my_gpu_above_minimum_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "$gpu",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['gpu']['is_my_gpu_above_minimum_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['gpu']['is_my_gpu_above_minimum_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['gpu']['is_my_gpu_above_minimum_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "CPU",
                              Icons.scale,
                              "${data['cpu']['game_minimum_cpu']['ryzen']}\n${data['cpu']['game_minimum_cpu']['intel']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['cpu']['is_my_cpu_above_minimum_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "${specs?.cpuName}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['cpu']['is_my_cpu_above_minimum_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['cpu']['is_my_cpu_above_minimum_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['cpu']['is_my_cpu_above_minimum_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "Ram",
                              Icons.scale,
                              "${data['ram']['game_minimum_ram']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['ram']['is_my_ram_above_minimum_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "${specs?.ramSize}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['ram']['is_my_ram_above_minimum_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['ram']['is_my_ram_above_minimum_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['ram']['is_my_ram_above_minimum_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
        Card(
          elevation: 1,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                title: Row(
                  children: [
                    const Text('Recommended'),
                    SizedBox(width: 2.w),
                    Icon(
                      result!['isAboveRecommended'] == true ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                      color: result!['isAboveRecommended'] == true ? Colors.green : Colors.red[300],
                      size: 20,
                    ),
                  ],
                ),
                children: [
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "GPU",
                              Icons.scale,
                              "${data['gpu']['game_recommended_gpu']['amd']}\n${data['gpu']['game_recommended_gpu']['nvidia']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['gpu']['is_my_gpu_above_recommended_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "$gpu",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['gpu']['is_my_gpu_above_recommended_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['gpu']['is_my_gpu_above_recommended_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['gpu']['is_my_gpu_above_recommended_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "CPU",
                              Icons.scale,
                              "${data['cpu']['game_recommended_cpu']['ryzen']}\n${data['cpu']['game_recommended_cpu']['intel']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['cpu']['is_my_cpu_above_recommended_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "${specs?.cpuName}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['cpu']['is_my_cpu_above_recommended_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['cpu']['is_my_cpu_above_recommended_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['cpu']['is_my_cpu_above_recommended_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    elevation: 0,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "Ram",
                              Icons.scale,
                              "${data['ram']['game_recommended_ram']}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['ram']['is_my_ram_above_recommended_settings'] ? const Color(0xff77839a) : null,
                            ),
                            tableRow(
                              context,
                              "yours",
                              Icons.scale,
                              "${specs?.ramSize}",
                              addSpacing: true,
                              showIcon: false,
                              wrapValueInExpanded: true,
                              textColor: data['ram']['is_my_ram_above_recommended_settings'] ? const Color(0xff77839a) : null,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 1.w),
                                child: Icon(
                                  data['ram']['is_my_ram_above_recommended_settings'] ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                  color: data['ram']['is_my_ram_above_recommended_settings'] ? Colors.green : Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
        Text(
          "Recommended Upgrades",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (data['gpu']['gpu_upgrade_for_100fps'] != null)
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "GPU Upgrade",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const Text(
                    "you'll get more performance if you upgrade your GPU, consider these suggested upgrades",
                    style: TextStyle(
                      color: Color(0xff77839a),
                    ),
                  ),
                  GridView(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2),
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        elevation: 0,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${data['gpu']['gpu_upgrade_for_100fps']['mid']['amd']}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(),
                                  1: IntrinsicColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  tableRow(
                                    context,
                                    "new",
                                    Icons.scale,
                                    '${data['gpu']['gpu_upgrade_for_100fps']['mid']['amd_price_new']}',
                                    addSpacing: true,
                                    showIcon: false,
                                    wrapValueInExpanded: true,
                                  ),
                                  tableRow(
                                    context,
                                    "used",
                                    Icons.scale,
                                    '${data['gpu']['gpu_upgrade_for_100fps']['mid']['amd_price_used']}',
                                    addSpacing: true,
                                    showIcon: false,
                                    wrapValueInExpanded: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        elevation: 0,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${data['gpu']['gpu_upgrade_for_100fps']['expensive']['amd']}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(),
                                  1: IntrinsicColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  tableRow(
                                    context,
                                    "new",
                                    Icons.scale,
                                    '${data['gpu']['gpu_upgrade_for_100fps']['expensive']['amd_price_new']}',
                                    addSpacing: true,
                                    showIcon: false,
                                    wrapValueInExpanded: true,
                                  ),
                                  tableRow(
                                    context,
                                    "used",
                                    Icons.scale,
                                    '${data['gpu']['gpu_upgrade_for_100fps']['expensive']['amd_price_used']}',
                                    addSpacing: true,
                                    showIcon: false,
                                    wrapValueInExpanded: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}

class QualityFpsWidget extends ConsumerWidget {
  const QualityFpsWidget({super.key, required this.text, required this.value});
  final String text;
  final String value;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
