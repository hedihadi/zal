import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';

class ChangeNameWidget extends ConsumerWidget {
  const ChangeNameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController nameController = TextEditingController(text: FirebaseAuth.instance.currentUser!.displayName);

    return IconButton(
      onPressed: () {
        Widget okButton = TextButton(
          child: const Text("OK"),
          onPressed: () async {
            await FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text);
            FirebaseAuth.instance.currentUser!.reload();
            ref.invalidate(authProvider);
            Navigator.pop(context);
          },
        );

        AlertDialog alert = AlertDialog(
          content: Padding(
            padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 1.h),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'your name',
                isDense: true,
              ),
            ),
          ),
          actions: [
            okButton,
          ],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      },
      icon: const FaIcon(FontAwesomeIcons.edit),
    );
  }
}
