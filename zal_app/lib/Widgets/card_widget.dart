import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class CardWidget extends ConsumerWidget {
  CardWidget({
    super.key,
    required this.title,
    required this.child,
    this.titleIcon = const SizedBox(),
    this.contentPadding,
    this.titleFontSize,
    this.titleIconAtRight = false,
    this.titleContainerColor,
  });
  final String title;
  final Widget child;
  final Widget titleIcon;
  final bool titleIconAtRight;
  final double? titleFontSize;
  final Color? titleContainerColor;
  EdgeInsetsGeometry? contentPadding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 20,
            shadowColor: Colors.transparent,
            shape: const BeveledRectangleBorder(),
            child: Container(
                color: titleContainerColor,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  child: Stack(
                    alignment: titleIconAtRight ? Alignment.topRight : Alignment.topLeft,
                    children: [
                      titleIcon,
                      Center(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontSize: titleFontSize ?? Theme.of(context).textTheme.titleLarge!.fontSize),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      titleIcon,
                    ],
                  ),
                )),
          ),
          Padding(
            padding: contentPadding != null ? contentPadding! : EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            child: child,
          ),
        ],
      ),
    );
  }
}
