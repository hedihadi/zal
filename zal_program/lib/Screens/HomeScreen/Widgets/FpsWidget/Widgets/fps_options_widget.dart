import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Screens/HomeScreen/providers/fps_provider.dart';

class FpsOptionsWidget extends ConsumerWidget {
  const FpsOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fpsDataProvider);
    final autoDetect = ref.watch(autoDetectGameProcessProvider);
    final processes = ref.read(fpsDataProvider.notifier).processes;
    final chosenProcess = ref.read(fpsChosenProcessProvider).value;
    return Column(
      children: [
        Text(
          "FPS",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          children: [
            Text(
              "Auto Detect: ",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Checkbox(
              value: autoDetect,
              onChanged: (value) {
                ref.read(autoDetectGameProcessProvider.notifier).state = !ref.read(autoDetectGameProcessProvider.notifier).state;
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Process: ",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              elevation: 5,
              shadowColor: Colors.transparent,
              child: Column(
                children: [
                  DropdownButton<String>(
                    underline: Container(),
                    value: chosenProcess?.name,
                    onChanged: (String? value) {
                      if (value == null) return;
                      ref.read(fpsChosenProcessProvider.notifier).chooseProcess(value);
                    },
                    items: processes.map<DropdownMenuItem<String>>((ProcessData value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(value.name),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
