import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/ConnectedScreen/connected_screen.dart';
import 'package:zal/Screens/InitialConnectionScreen/Widgets/choose_computer_widget.dart';
import 'package:zal/Screens/InitialConnectionScreen/initial_connection_screen_providers.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

class InitialConnectionScreen extends ConsumerWidget {
  const InitialConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedToServerProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    ref.watch(socketStreamProvider);
    final address = settings?['address'];
    if (isConnected) return ConnectedScreen();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Spacer(),
          if (address == null) const Text("You haven't connected to any PC before, connect to a PC first."),
          if (address != null)
            Center(
              child: Text("Connecting to $address"),
            ),
          if (address != null) const Spacer(),
          Center(
            child: TextButton(
              onPressed: () {
                AlertDialog alert = AlertDialog(
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"))
                  ],
                  content: SizedBox(width: 90.w, child: const ChooseComputerWidget()),
                );

                // show the dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: const Text("Find your PC"),
            ),
          ),
          SizedBox(height: 4.h),
          if (address == null) const Spacer(),
        ],
      ),
    );
  }
}
