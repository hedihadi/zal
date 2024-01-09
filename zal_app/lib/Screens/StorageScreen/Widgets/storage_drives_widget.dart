import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';

class StorageDrivesWidget extends ConsumerWidget {
  const StorageDrivesWidget({super.key, required this.storage});
  final Storage storage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: storage.partitions?.length,
      itemBuilder: (context, index) {
        final partition = storage.partitions![index];
        return Card(
          elevation: 4,
          shadowColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${partition.driveLetter} - ${partition.label == '' ? partitionDefaultName(partition) : partition.label}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text((partition.size - partition.freeSpace).toSize()),
                    SizedBox(width: 1.w),
                    Expanded(
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
      },
    );
  }

  String partitionDefaultName(Partition partition) {
    return "Local Disk ${partition.driveLetter}";
  }
}
