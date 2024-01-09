import 'dart:async';

import 'package:firedart/auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      await auth.signIn(email, password);
    } on Exception catch (c) {
      state = AsyncError(c.toString(), StackTrace.current);
      return;
    }
  }
}

final asyncManualLoginProvider = AsyncNotifierProvider<ManualLoginNotifier, dynamic>(() {
  return ManualLoginNotifier();
});
