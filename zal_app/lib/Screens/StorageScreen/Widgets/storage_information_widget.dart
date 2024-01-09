import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

class StorageInformationWidget extends ConsumerWidget {
  const StorageInformationWidget({super.key, required this.storage});
  final Storage storage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ssdWrite = storage.smartAttributes.firstWhereOrNull((element) => element.attributeName == "Host Writes");
    //final hddWrite = storage.smartAttributes.firstWhereOrNull((element) => element['attributeName'] == "Total Host Writes");
    final healthPercentage = storage.info.entries.firstWhereOrNull((element) => element.key == "healthPercentage")?.value;
    final healthText = storage.info.entries.firstWhereOrNull((element) => element.key == "healthText")?.value;
    return Column(
      children: [
        StaggeredGridview(
          children: [
            storage.info.containsKey("transferMode")
                ? CardWidget(
                    title: "Transfer mode",
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Table(
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            tableRow(
                              context,
                              "Current",
                              FontAwesomeIcons.indent,
                              "${storage.info['transferMode'][0]}",
                              showIcon: false,
                            ),
                            tableRow(
                              context,
                              "Supported",
                              FontAwesomeIcons.indent,
                              "${storage.info['transferMode'][1]}",
                              showIcon: false,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : Container(),
            CardWidget(
              title: "Working time",
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${storage.info['powerOnHours']} hours,",
                  ),
                  Text(
                    "Powered on ${storage.info['powerOnCount']} times.",
                  ),
                ],
              ),
            ),
            healthPercentage == null
                ? null
                : CardWidget(
                    title: "Health",
                    child: Column(
                      children: [
                        Text(
                          "$healthPercentage% ${(healthText != null) ? '($healthText)' : ''}",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: healthText == "Good"
                                  ? Colors.green
                                  : healthText == "Caution"
                                      ? Colors.yellow
                                      : healthText == "Bad"
                                          ? Colors.red
                                          : null),
                        ),
                        SizedBox(height: 0.5.h),
                        LinearProgressIndicator(value: healthPercentage / 100),
                        SizedBox(height: 0.5.h),
                      ],
                    ),
                  ),
            ssdWrite == null
                ? null
                : CardWidget(
                    title: "Total Write",
                    child: Text(
                      (ssdWrite.rawValue * 1024 * 1024 * 1024).toSize(addSpace: true),
                    ),
                  ),
            CardWidget(
              title: "Health",
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${storage.info['healthText']}",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: healthText == "Good"
                            ? Colors.green
                            : healthText == "Caution"
                                ? Colors.yellow
                                : healthText == "Bad"
                                    ? Colors.red
                                    : null),
                  ),
                ],
              ),
            ),
            CardWidget(
              title: "Features",
              child: Text(storage.info['features'].toString().replaceAll("[", "").replaceAll("]", "")),
            ),
          ],
        ),
      ],
    );
  }
}
