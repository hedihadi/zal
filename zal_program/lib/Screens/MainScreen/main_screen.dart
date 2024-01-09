import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/programs_runner.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/LoginScreen/main_login_screen.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/authorized_screen.dart';
import 'package:flutter/material.dart' hide MenuItem;

final didRunStartupCodeProvider = StateProvider<bool>((ref) => false);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WindowListener, TrayListener {
  @override
  Widget build(BuildContext context) {
    ref.read(executableProvider);
    final user = ref.watch(userProvider).value;
    WidgetsBinding.instance.addPostFrameCallback((_) => runStartupCode(ref, context));
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: user == null ? const MainLoginScreen() : const AuthorizedScreen(),
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowClose() async {
    Settings settings = await LocalDatabaseManager.loadSettings();
    if (settings.runInBackground) {
      await windowManager.hide();
    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    windowManager.setPreventClose(true);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
    } else if (menuItem.key == 'quit_app') {
      exit(0);
    }
  }

  runStartupCode(WidgetRef ref, BuildContext context) async {
    if (ref.read(didRunStartupCodeProvider) == true) {
      return;
    }
    ref.read(didRunStartupCodeProvider.notifier).state = true;

    //set contextProvider
    ref.read(contextProvider.notifier).state = context;

    //check if update is available
    final shouldUpdate = await isUpdateAvailable();
    if (shouldUpdate) {
      final context = ref.read(contextProvider);
      final userResponse = await showConfirmDialog("UPDATE!", "a new update is available! would you like to update now?", context!);
      if (userResponse) {
        ProgramsRunner.downloadAndOpenInstaller();
      }
    }

    //setup system tray
    await trayManager.setIcon('assets/images/app_icon.ico');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(
        key: 'show_window',
        label: 'Show',
      ),
      MenuItem(
        key: 'quit_app',
        label: 'Quit',
      ),
    ]));
  }
}
