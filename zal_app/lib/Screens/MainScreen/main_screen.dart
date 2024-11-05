import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/admob_consent_helper.dart';
import 'package:zal/Screens/InitialConnectionScreen/initial_connection_screen.dart';

import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AdmobConsentHelper().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(contextProvider.notifier).state = context);
    return const InitialConnectionScreen();
    // return AuthorizedScreen();
  }
}

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        height: 10.h,
        width: 10.h,
        child: const CircularProgressIndicator(
          strokeWidth: 15,
        ),
      )),
    );
  }
}
