import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Screens/FilesScreen/Providers/directory_provider.dart';
import 'package:zal/Screens/FilesScreen/Widgets/bottom_file_screen_widget.dart';
import 'package:zal/Screens/FilesScreen/Widgets/file_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zal/Screens/FilesScreen/Widgets/move_file_widget.dart';

final showGridProvider = StateProvider<bool>((ref) => true);

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final RefreshController refreshController1 = RefreshController(initialRefresh: false);
  final RefreshController refreshController2 = RefreshController(initialRefresh: false);

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1), () {
      ref.watch(directoryProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final directoryData = ref.watch(directoryProvider);
    final showGrid = ref.watch(showGridProvider);
    return directoryData.when(
      //skipLoadingOnReload: true,
      data: (data) {
        return WillPopScope(
          onWillPop: () async {
            ref.read(directoryProvider.notifier).goBack();
            return false;
          },
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ref.read(directoryProvider.notifier).folders.map((folder) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              elevation: const MaterialStatePropertyAll(0),
                              backgroundColor: MaterialStatePropertyAll(Theme.of(context).appBarTheme.backgroundColor)),
                          onPressed: () {
                            ref.read(directoryProvider.notifier).goBackToFolder(folder);
                          },
                          child: Row(
                            children: [
                              Text(
                                '${folder.name} ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Icon(
                                FontAwesomeIcons.chevronRight,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ));
                  }).toList(),
                ),
              ),
              Visibility(
                visible: showGrid,
                child: Expanded(
                  child: SmartRefresher(
                    controller: refreshController1,
                    onRefresh: () async {
                      ref.read(directoryProvider.notifier).refresh();
                      await ref.read(directoryProvider.future);
                      refreshController1.refreshCompleted();
                    },
                    child: GridView.builder(
                      itemCount: data.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.2),
                      itemBuilder: (context, index) {
                        final file = data[index];
                        return FileWidget(file: file, grid: true);
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: showGrid == false,
                child: Expanded(
                  child: SmartRefresher(
                    controller: refreshController2,
                    onRefresh: () async {
                      ref.read(directoryProvider.notifier).refresh();
                      await ref.read(directoryProvider.future);
                      refreshController2.refreshCompleted();
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final file = data[index];
                        return FileWidget(file: file, grid: false);
                      },
                    ),
                  ),
                ),
              ),
              const MoveFileWidget(),
              const BottomFileScreenWidget(),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text("error");
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
