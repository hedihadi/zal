import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_information_widget.dart';

class ConnectManuallyWidget extends ConsumerWidget {
  ConnectManuallyWidget({super.key});
  TextEditingController addressController = TextEditingController(text: "192.168.");
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text("Computer Address:"),
            IconButton(
              onPressed: () {
                showInformationDialog(null, "You can find this address by opening Zal on your Computer, and check the bottom left corner.", context);
              },
              icon: Icon(
                FontAwesomeIcons.question,
                size: 2.h,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: addressController,
        ),
        const SizedBox(height: 8),
        Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
                onPressed: () {
                  ref.read(socketProvider.notifier).connect(null, manualAddress: addressController.text, forceConnect: true);
                  Navigator.pop(context);
                },
                child: const Text("Connect"))),
      ],
    );
  }
}
