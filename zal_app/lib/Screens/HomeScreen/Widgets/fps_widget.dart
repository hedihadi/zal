import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/FpsScreen/fps_screen.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Widgets/card_widget.dart';

class FpsWidget extends ConsumerWidget {
  const FpsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);
    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
          final Gpu? gpu = data.gpus.firstWhereOrNull((element) => element.fps != -1);

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FpsScreen()));
              ref.read(socketObjectProvider.notifier).state!.sendData('start_fps', "");
            },
            child: CardWidget(
              title: "FPS Counter",
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gpu == null ? 'no game running' : '${gpu.fps} FPS',
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container());
  }
}
