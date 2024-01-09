import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class SectionSettingUi extends ConsumerWidget {
  SectionSettingUi({super.key, required List<Widget> children}) {
    this.children = getChildrenWithDivider(children);
  }
  late final List<Widget> children;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //add divider between each child.

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  List<Widget> getChildrenWithDivider(List<Widget> children) {
    List<Widget> childrenWithDivider = [];
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      childrenWithDivider.add(child);
      //don't add divider if this widget is the last one.
      if ((i + 1) != childrenWithDivider.length) {
        childrenWithDivider.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: const Divider(),
        ));
      }
    }
    return childrenWithDivider;
  }
}
