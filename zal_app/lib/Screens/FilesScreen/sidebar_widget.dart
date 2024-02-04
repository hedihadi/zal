

//class SidebarWidget extends ConsumerWidget {
//  const SidebarWidget({super.key});
//
//  @override
//  Widget build(BuildContext context, WidgetRef ref) {
//    final directoryData = ref.watch(directoryp);
//    final drives = ref.watch(drivesProvider).valueOrNull;
//    return SizedBox(
//      width: 60.w,
//      child: SidebarX(
//        animationDuration: const Duration(milliseconds: 0),
//        showToggleButton: false,
//        controller: SidebarXController(
//          selectedIndex: drives?.indexWhere((element) => element == selectedFolder) ?? 0,
//          extended: true,
//        ),
//        items: [
//          ...drives?.map<SidebarXItem>(
//                (drive) {
//                  return SidebarXItem(
//                    label: "${drive.name} ${drive.label}",
//                    icon: FontAwesomeIcons.solidFolder,
//                    onTap: () => ref.read(selectedDriveProvider.notifier).state = drive,
//                  );
//                },
//              ).toList() ??
//              [],
//        ],
//      ),
//    );
//  }
//}
//