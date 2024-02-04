import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/FilesScreen/Providers/directory_provider.dart';
import 'package:zal/Screens/FilesScreen/Providers/move_file_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

class MoveFileWidget extends ConsumerWidget {
  const MoveFileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moveFileModel = ref.watch(moveFileProvider);
    if (moveFileModel == null) return Container();
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                ref.read(moveFileProvider.notifier).state = null;
              },
              icon: const Icon(FontAwesomeIcons.xmark),
            ),
            Expanded(
              child: Text(
                "${moveFileModel.moveType == MoveFileType.copy ? 'copying' : 'moving'} ${moveFileModel.file.name}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () {
                final file = moveFileModel.file;
                final currentFolderPath = ref.read(directoryProvider.notifier).getCurrentFolderPath();
                ref.read(webrtcProvider.notifier).sendMessage(
                    moveFileModel.moveType == MoveFileType.move ? 'move_file' : 'copy_file',
                    jsonEncode({
                      'oldPath': "${file.directory}\\${file.name}",
                      'newPath': "$currentFolderPath\\${file.name}",
                    }));
              },
              icon: const Icon(FontAwesomeIcons.paste),
            ),
          ],
        ),
      ),
    );
  }
}
