import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class TitleWidget extends ConsumerWidget {
  const TitleWidget(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3.h),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
