import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Widgets/FpsWidget/Widgets/fps_options_widget.dart';
import 'package:zal/Screens/HomeScreen/providers/fps_provider.dart';

class FpsWidget extends ConsumerWidget {
  const FpsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsData = ref.watch(fpsDataProvider);

    return fpsData.when(
      skipLoadingOnReload: true,
      data: (data) {
        final fpsDetails = ref.read(fpsDataProvider.notifier).fpsDetails;

        return SizedBox(
          height: 10.h,
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const FpsOptionsWidget(),
                    SizedBox(
                        height: 10.h,
                        child: data.isEmpty
                            ? Container()
                            : SfSparkAreaChart(
                                axisLineWidth: 2,
                                borderWidth: 2,
                                trackball: const SparkChartTrackball(shouldAlwaysShow: true),
                                color: Theme.of(context).primaryColor,
                                data: data.map((e) => e.fps).toList(),
                              )),
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                      },
                      children: <TableRow>[
                        tableRow(
                          context,
                          "Current FPS",
                          FontAwesomeIcons.memory,
                          "${data.isEmpty ? '' : data.last.fps}",
                          addSpacing: true,
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "%1 low",
                          FontAwesomeIcons.memory,
                          "${fpsDetails?.fps01Low.toStringAsFixed(1)}",
                          addSpacing: true,
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "%0.1 low",
                          FontAwesomeIcons.memory,
                          "${fpsDetails?.fps001Low.toStringAsFixed(1)}",
                          addSpacing: true,
                          showIcon: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text("");
      },
      loading: () {
        return Container();
      },
    );
  }
}
