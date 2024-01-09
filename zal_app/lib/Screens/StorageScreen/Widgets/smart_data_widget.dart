import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';

class SmartDataTableWidget extends ConsumerWidget {
  const SmartDataTableWidget({super.key, required this.storage});
  final Storage storage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: Theme.of(context).colorScheme.primaryContainer)),
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              children: getTableHeaders(context),
            ),
            ...getTableRows(context),
          ],
        ),
      ),
    );
  }

  List<TableRow> getTableRows(BuildContext context) {
    List<TableRow> tableRows = [];
    for (final e in storage.smartAttributes) {
      List<TableCell> tableCells = [];
      tableCells.add(
        TableCell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: SelectableText(e.attributeName),
          ),
        ),
      );
      if (e.currentValue != null) {
        tableCells.add(TableCell(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4), child: SelectableText("${e.currentValue}")),
        ));
      }
      if (e.worstValue != null) {
        tableCells.add(TableCell(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4), child: SelectableText("${e.worstValue}")),
        ));
      }
      if (e.threshold != null) {
        tableCells.add(TableCell(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4), child: SelectableText("${e.threshold}")),
        ));
      }
      tableCells.add(TableCell(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4), child: SelectableText("${e.rawValue}")),
      ));
      tableRows.add(TableRow(children: tableCells));
    }
    return tableRows;
  }

  List<TableCell> getTableHeaders(BuildContext context) {
    List<TableCell> result = [];
    result.add(TableCell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: SelectableText(
          "Name",
          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontFamily: "roboto", color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    ));
    if (storage.smartAttributes[0].currentValue != null) {
      result.add(TableCell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: SelectableText(
            "Current ",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontFamily: "roboto", color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ));
    }
    if (storage.smartAttributes[0].worstValue != null) {
      result.add(TableCell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: SelectableText(
            "Worst",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontFamily: "roboto", color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ));
    }
    if (storage.smartAttributes[0].threshold != null) {
      result.add(TableCell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: SelectableText(
            "Thresh.",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontFamily: "roboto", color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ));
    }
    result.add(TableCell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: SelectableText(
          "Raw Value",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: "roboto", color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    ));
    return result;
  }
}
