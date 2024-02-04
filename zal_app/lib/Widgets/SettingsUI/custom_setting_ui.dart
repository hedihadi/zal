import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class CustomSettingUi extends ConsumerStatefulWidget {
  const CustomSettingUi({super.key, required this.title, required this.subtitle, required this.icon, required this.child});
  final String title;
  final String subtitle;
  final Widget icon;
  final Widget child;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomSettingUiState();
}

class _CustomSettingUiState extends ConsumerState<CustomSettingUi> {
  _CustomSettingUiState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.icon,
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title),
              Wrap(
                children: [
                  Text(
                    widget.subtitle,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
            ],
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
