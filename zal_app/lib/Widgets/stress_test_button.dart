import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/interstitial_ad.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';

import '../Functions/analytics_manager.dart';

final secondsProvider = StateProvider<int>((ref) => 10);
final chosenTypeProvider = StateProvider<String>((ref) => "RAM");

class StressTestButton extends ConsumerWidget {
  const StressTestButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedToServerProvider);
    ref.read(screenViewProvider("stress-test"));
    if (isConnected == false) {
      return Container();
    }
    return IconButton(
      onPressed: () async {
        bool response = await showConfirmDialog(
            'are you sure?', 'Stress testing may heat up your computer, leading to unresponsiveness or damage. do you want to proceed?', context);
        if (response == false) return;

        AlertDialog alert = AlertDialog(
          title: const Text('Stress testing'),
          content: DialogWidget(),
          actions: [
            TextButton(
              child: const Text("Proceed"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
        response = (await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                )) ==
                true
            ? true
            : false;
        if (response == false) return;
        //show ad then start the stress test
        await ref.read(interstitialAdProvider.notifier).showAd();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Now stress testing your ${ref.read(chosenTypeProvider)}"),
          // margin: EdgeInsets.all(10.sp),
        ));
        //ref.read(computerDataProvider.notifier).stressTest(ref.read(chosenTypeProvider).toLowerCase(), ref.read(secondsProvider));
        AnalyticsManager.logEvent("stress-test", options: {'type': ref.read(chosenTypeProvider).toLowerCase()});
      },
      icon: const FaIcon(FontAwesomeIcons.bolt),
    );
  }
}

class DialogWidget extends ConsumerWidget {
  DialogWidget({super.key});
  final List<String> choices = ['RAM', 'CPU', 'GPU (coming soon)'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosenType = ref.watch(chosenTypeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToggleButtons(
          // ToggleButtons uses a List<bool> to track its selection state.
          isSelected: choices.map((e) => e == chosenType).toList(),
          // This callback return the index of the child that was pressed.
          onPressed: (int index) {
            if (index == 2) return;
            ref.read(chosenTypeProvider.notifier).state = choices[index];
          },
          // Constraints are used to determine the size of each child widget.
          constraints: const BoxConstraints(
            minHeight: 32.0,
            minWidth: 56.0,
          ),
          // ToggleButtons uses a List<Widget> to build its children.
          children: choices.map((e) => Text(e)).toList(),
        ),
        Text("Seconds: ${ref.watch(secondsProvider)}"),
        Slider(
            min: 1,
            max: 60,
            value: ref.watch(secondsProvider).toDouble(),
            onChanged: (val) => ref.read(secondsProvider.notifier).state = val.round()),
      ],
    );
  }
}
