import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/LoginScreen/main_login_screen.dart';

class ManualSignupNotifier extends AsyncNotifier {
  @override
  FutureOr build() {
    return false;
  }

  Future<bool> signup(email, password, username) async {
    state = const AsyncValue.loading();
    final auth = FirebaseAuth.instance;
    try {
      if ([email, password, username].contains('')) {
        state = AsyncError('Email, Username, or Password is empty', StackTrace.current);
        return false;
      }
      final isConnectingAccount = ref.read(isConnectingAccountProvider);
      if (isConnectingAccount) {
        final credential = EmailAuthProvider.credential(email: email, password: password);
        final userCredential = await auth.currentUser!.linkWithCredential(credential);
        return true;
      }
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      await auth.currentUser!.updateDisplayName(username);
      await auth.currentUser!.reload();
    } on FirebaseAuthException catch (c) {
      state = AsyncError(c.message.toString(), StackTrace.current);
      return false;
    }
    return false;
  }
}

final asyncManualSignupProvider = AsyncNotifierProvider<ManualSignupNotifier, dynamic>(() {
  return ManualSignupNotifier();
});

class SignupWidget extends ConsumerWidget {
  SignupWidget({super.key});
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Username', isDense: true),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email', isDense: true),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
          child: TextField(
            controller: passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Password',
              isDense: true,
            ),
          ),
        ),
        ElevatedButton.icon(
            onPressed: () async {
              final response =
                  await ref.read(asyncManualSignupProvider.notifier).signup(emailController.text, passwordController.text, usernameController.text);
              if (response == true) {
                Navigator.pop(context);
              }
            },
            icon: const FaIcon(FontAwesomeIcons.rightToBracket),
            label: ref.watch(asyncManualSignupProvider).isLoading ? const CircularProgressIndicator() : const Text("Signup")),
        Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
            child: ref.watch(asyncManualSignupProvider).error == null
                ? Container()
                : Text(
                    "${ref.watch(asyncManualSignupProvider).error}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.error),
                  )),
      ],
    );
  }
}
