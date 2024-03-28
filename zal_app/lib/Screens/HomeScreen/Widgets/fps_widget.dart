import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/FpsScreen/fps_screen.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:zal/Widgets/card_widget.dart';

class FpsWidget extends ConsumerWidget {
  const FpsWidget({super.key, required this.computerData});
  final ComputerData computerData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpu = ref.watch(computerDataProvider).value?.gpu;
    if (gpu == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FpsScreen()));
        ref.read(fpsDataProvider.notifier).showChooseGameDialog(dismissible: false);
      },
      child: CardWidget(
        title: "FPS Counter",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gpu.fps == -1 ? 'no game running' : '${gpu.fps} FPS',
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }
}
