import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';

class SaveFpsWidget extends ConsumerWidget {
  SaveFpsWidget({super.key});
  final TextEditingController presetNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        AlertDialog alert = AlertDialog(
          title: Text("Save FPS record", style: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
                child: TextFormField(
                  controller: presetNameController,
                  decoration: const InputDecoration(hintText: 'Record Name', isDense: true),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
                child: TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(hintText: 'Note (optional)', isDense: true),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                if (presetNameController.text.isEmpty) {
                  return;
                }
                final value = ref.read(fpsDataProvider).value;
                if (value == null) return;
                ref
                    .read(fpsRecordsProvider.notifier)
                    .addPreset(value, presetNameController.text, noteController.text == '' ? null : noteController.text);
                Navigator.of(context).pop();
                ref.read(fpsDataProvider.notifier).reset();
              },
            ),
          ],
        );

        // show the dialog
        final response = (await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                )) ==
                true
            ? true
            : false;
      },
      icon: const Icon(FontAwesomeIcons.floppyDisk),
    );
  }
}
