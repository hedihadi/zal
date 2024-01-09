import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'package:zal/Functions/utils.dart';

class PartitionWidget extends ConsumerWidget {
  const PartitionWidget({super.key, required this.partition});
  final Partition partition;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("${partition.driveLetter} - ${partition.label == '' ? partitionDefaultName() : partition.label}"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text((partition.size - partition.freeSpace).toSize()),
                SizedBox(width: 1.w),
                Expanded(
                  flex: 4,
                  child: LinearProgressIndicator(
                    value: ((partition.size - partition.freeSpace) / partition.size),
                  ),
                ),
                SizedBox(width: 1.w),
                Text(partition.size.toSize()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String partitionDefaultName() {
    return "Local Disk ${partition.driveLetter}";
  }
}
