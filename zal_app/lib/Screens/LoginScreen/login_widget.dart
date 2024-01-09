import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

class ManualLoginNotifier extends AsyncNotifier {
  @override
  FutureOr build() {
    return false;
  }

  login(email, password) async {
    state = const AsyncValue.loading();
    final auth = FirebaseAuth.instance;
    try {
      if ([email, password].contains('')) {
        state = AsyncError('Email or Password is empty', StackTrace.current);
        return;
      }
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await Purchases.setEmail(email);
    } on FirebaseAuthException catch (c) {
      state = AsyncError(c.message.toString(), StackTrace.current);
      return;
    }
  }
}

final asyncManualLoginProvider = AsyncNotifierProvider<ManualLoginNotifier, dynamic>(() {
  return ManualLoginNotifier();
});

class LoginWidget extends ConsumerWidget {
  LoginWidget({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(hintText: 'Email', isDense: true),
            validator: (value) {
              final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
              if (emailRegExp.hasMatch(value ?? "")) {
                return null;
              }
              return "email not valid";
            },
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
              hintText: 'Password',
              isDense: true,
            ),
          ),
        ),
        ElevatedButton.icon(
            onPressed: () async {
              ref.read(asyncManualLoginProvider.notifier).login(emailController.text, passwordController.text);
            },
            icon: const FaIcon(FontAwesomeIcons.rightToBracket),
            label: ref.watch(asyncManualLoginProvider).isLoading ? const CircularProgressIndicator() : const Text("Login")),
        Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
            child: ref.watch(asyncManualLoginProvider).error == null
                ? Container()
                : Text(
                    "${ref.watch(asyncManualLoginProvider).error}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.error),
                  )),
      ],
    );
  }
}
