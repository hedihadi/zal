import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class TextSettingUi extends ConsumerStatefulWidget {
  const TextSettingUi({super.key, required this.title, required this.subtitle, required this.icon, required this.onChanged, required this.value});
  final String title;
  final String subtitle;
  final Widget icon;
  final Function(String value) onChanged;
  final String value;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextSettingUiState(value: value);
}

class _TextSettingUiState extends ConsumerState<TextSettingUi> {
  _TextSettingUiState({required this.value});
  final String value;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
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
        Expanded(child: TextField(controller: controller, onSubmitted: (value) => widget.onChanged.call(value))),
      ],
    );
  }
}
