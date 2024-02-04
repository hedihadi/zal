import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FilesScreen/Providers/directory_provider.dart';
import 'package:zal/Screens/FilesScreen/files_screen.dart';
import 'package:zal/Widgets/SettingsUI/custom_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';

class BottomFileScreenWidget extends ConsumerWidget {
  const BottomFileScreenWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
      child: Row(
        children: [
          SizedBox(
            width: 50.w,
            child: TextField(
              onTapOutside: (a) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {
                ref.read(directoryProvider.notifier).searchFile(value);
              },
              decoration: const InputDecoration(hintText: 'filter...', isDense: true),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () async {
                    showModalBottomSheet(
                      builder: (context) {
                        return Column(
                          children: [
                            SectionSettingUi(children: [
                              CustomSettingUi(
                                title: "Sort by",
                                subtitle: 'how you want the files/folders to be sorted?',
                                icon: const Icon(FontAwesomeIcons.sort),
                                child: TextButton(
                                  onPressed: () {
                                    AlertDialog alert = AlertDialog(
                                        content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: SortFilesBy.values.map<Widget>((e) {
                                        return RadioListTile<SortFilesBy>(
                                          title: Text(convertCamelToReadable(e.name)),
                                          groupValue: ref.read(directoryProvider.notifier).sortFilesBy,
                                          value: e,
                                          onChanged: (SortFilesBy? value) {
                                            if (value != null) {
                                              ref.read(directoryProvider.notifier).changeSortBy(value);
                                              Navigator.pop(context);
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ));

                                    // show the dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  },
                                  child: Text(convertCamelToReadable(ref.read(directoryProvider.notifier).sortFilesBy.name)),
                                ),
                              ),
                              CustomSettingUi(
                                title: "Grid view",
                                subtitle: "files should be shown in grid or list",
                                icon: const Icon(FontAwesomeIcons.gripVertical),
                                child: TextButton(
                                  child: const Text('change'),
                                  onPressed: () {
                                    ref.read(showGridProvider.notifier).state = !ref.read(showGridProvider);
                                  },
                                ),
                              ),
                            ]),
                          ],
                        );
                      },
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                      ),
                    );
                  },
                  icon: const Icon(
                    FontAwesomeIcons.ellipsisVertical,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
