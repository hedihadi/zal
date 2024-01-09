import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Screens/FpsScreen/Widgets/chart.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:zal/Widgets/card_widget.dart';

class FpsPresetsWidget extends ConsumerWidget {
  const FpsPresetsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsPresets = ref.watch(fpsRecordsProvider);
    return ListView.builder(
      itemCount: fpsPresets.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final fpsPreset = fpsPresets[index];
        return CardWidget(
          title: fpsPreset.presetName,
          titleIconAtRight: true,
          titleIcon: IconButton(
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size.fromRadius(15),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              ref.read(fpsRecordsProvider.notifier).removePreset(fpsPreset);
            },
            icon: Icon(
              FontAwesomeIcons.xmark,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [fpsPreset.note == null ? Container() : Text(fpsPreset.note!), Text(fpsPreset.presetDuration)],
              ),
              LineZoneChartWidget(fpsData: fpsPreset.fpsData),
            ],
          ),
        );
      },
    );
  }
}
