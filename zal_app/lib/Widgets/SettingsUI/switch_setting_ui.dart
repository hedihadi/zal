import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class SwitchSettingUi extends ConsumerWidget {
  const SwitchSettingUi({super.key, required this.title, required this.subtitle, required this.icon, required this.onChanged, required this.value});
  final String title;
  final String subtitle;
  final Widget icon;
  final Function(bool value) onChanged;
  final bool value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        icon,
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Wrap(
              children: [
                Text(
                  subtitle,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.labelSmall,
                )
              ],
            ),
          ],
        ),
        const Spacer(),
        Switch(value: value, onChanged: (value) => onChanged.call(value)),
      ],
    );
  }
}
