import 'package:color_print/color_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/FilesScreen/Providers/file_provider.dart';

class FileTransferProgressWidget extends ConsumerWidget {
  const FileTransferProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(fileProvider);
    final size = file.valueOrNull?.file?.size ?? 0;

    return file.when(
        skipLoadingOnReload: true,
        data: (data) {
          //return GridView.builder(
          //  physics: const NeverScrollableScrollPhysics(),
          //  shrinkWrap: true,
          //  itemCount: ((data.file?.size ?? 0) / 153600).round(),
          //  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          //  itemBuilder: (context, index) {
          //    return Container(
          //      height: 10,
          //      width: 10,
          //      color: Colors.red,
          //    );
          //  },
          //);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.fileProviderState.name),
              LinearProgressIndicator(value: (data.lastBiggestByte / (data.file?.size ?? 1))),
              //  Text("${size - remainingBytes}/$size"),
              TextButton(
                  onPressed: () {
                    ref.read(fileProvider.notifier).openTransferredFile();
                  },
                  child: const Text("open"))
            ],
          );
        },
        error: (error, stackTrace) {
          logError(error);
          logError(stackTrace);
          return const Text("errr");
        },
        loading: () => const CircularProgressIndicator());
  }
}
