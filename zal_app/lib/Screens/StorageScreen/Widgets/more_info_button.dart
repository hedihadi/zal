import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoreInfoButton extends ConsumerWidget {
  const MoreInfoButton({super.key, this.onTap});
  final Function? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          //color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Icon(
          FontAwesomeIcons.question,
          color: Theme.of(context).colorScheme.secondary,
          fill: 0.2,
        ),
      ),
    );
  }
}
