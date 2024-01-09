import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';

class FpsHelpWidget extends ConsumerWidget {
  const FpsHelpWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        showConfirmDialog(
            "How it works?",
            "to use the FPS Counter, you must be playing a game. the Program will automatically detect it and will start sending FPS data to your mobile.",
            context);
      },
      icon: const Icon(FontAwesomeIcons.question),
    );
  }
}
