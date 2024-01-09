import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';

class ForgotPasswordButton extends ConsumerWidget {
  ForgotPasswordButton({super.key});
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        AlertDialog alert = AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your Email address"),
              SizedBox(height: 1.h),
              TextField(
                controller: emailController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Proceed"),
              onPressed: () {
                FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
        final response = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                ) ==
                true
            ? true
            : false;
        if (response == true) {
          showInformationDialog(null, "an email has been sent to ${emailController.text}, you may open the link to reset your password.", context);
        }
      },
      icon: Container(),
      label: const Text("Forgot Password"),
    );
  }
}
