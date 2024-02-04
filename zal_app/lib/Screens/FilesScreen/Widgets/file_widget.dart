import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FilesScreen/Providers/directory_provider.dart';
import 'package:zal/Screens/FilesScreen/Providers/move_file_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

class FileWidget extends ConsumerWidget {
  FileWidget({super.key, required this.file, required this.grid});
  final FileData file;
  final bool grid;
  TextEditingController renameFileController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (grid) {
      return InkWell(
        onTapUp: (TapUpDetails details) async {
          onFileTap(ref, context, file, details);
        },
        child: Column(
          children: [
            Image.asset(
              "assets/images/icons/${file.fileType.name}.png",
              height: 25,
            ),
            Text(
              file.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTapUp: (TapUpDetails details) async {
        onFileTap(ref, context, file, details);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Image.asset(
              "assets/images/icons/${file.fileType.name}.png",
              height: 25,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    file.size == 0 ? '' : file.size.toSize(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onFileTap(WidgetRef ref, BuildContext context, FileData file, TapUpDetails details) async {
    if (file.fileType == FileType.folder) {
      ref.read(directoryProvider.notifier).openFolder(file);
    } else {
      await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, details.globalPosition.dx, details.globalPosition.dy),
        items: [
          //PopupMenuItem<String>(
          //  child: const Text('view'),
          //  onTap: () {
          //    ref.read(fileProvider.notifier).viewFile(file);
          //    Future.delayed(const Duration(seconds: 0), () {
          //      Widget cancelButton = TextButton(
          //        child: const Text("Cancel"),
          //        onPressed: () {
          //          ref.read(fileProvider.notifier).cancelTransfer();
          //        },
          //      );
//
          //      // set up the AlertDialog
          //      AlertDialog alert = AlertDialog(
          //        content: const FileTransferProgressWidget(),
          //        actions: [
          //          cancelButton,
          //        ],
          //      );
//
          //      // show the dialog
          //      showDialog(
          //        context: context,
          //        builder: (BuildContext context) {
          //          return alert;
          //        },
          //      );
          //    });
          //  },
          //),
          //PopupMenuItem<String>(
          //  child: const Text('download'),
          //  onTap: () {},
          //),
          PopupMenuItem<String>(
            child: const Text('run'),
            onTap: () {
              final a = file;
              ref.read(webrtcProvider.notifier).sendMessage('run_file', '${file.directory}\\${file.name}');
            },
          ),
          PopupMenuItem<String>(
            child: const Text('rename'),
            onTap: () async {
              renameFileController.text = file.name;
              AlertDialog alert = AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      controller: renameFileController,
                    ),
                    SizedBox(height: 1.h),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(webrtcProvider.notifier).sendMessage(
                              'move_file',
                              jsonEncode({
                                'oldPath': "${file.directory}\\${file.name}",
                                'newPath': "${file.directory}\\${renameFileController.text}",
                              }));
                          Navigator.pop(context);
                        },
                        child: const Text("rename"),
                      ),
                    ),
                  ],
                ),
              );

              // show the dialog
              Future.delayed(const Duration(milliseconds: 1), () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              });
            },
          ),

          PopupMenuItem<String>(
            child: const Text('copy'),
            onTap: () {
              ref.read(moveFileProvider.notifier).state = MoveFileModel(file: file, moveType: MoveFileType.copy);
            },
          ),
          PopupMenuItem<String>(
            child: const Text('move'),
            onTap: () {
              ref.read(moveFileProvider.notifier).state = MoveFileModel(file: file, moveType: MoveFileType.move);
            },
          ),
          PopupMenuItem<String>(
            child: const Text('delete'),
            onTap: () {
              ref.read(webrtcProvider.notifier).sendMessage('delete_file', "${file.directory}\\${file.name}");
            },
          ),
        ],
        elevation: 2,
      );
    }
  }
}
