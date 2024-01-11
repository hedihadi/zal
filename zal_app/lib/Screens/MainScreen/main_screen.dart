import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/AuthorizedScreen/authorized_screen.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/LoginScreen/main_login_screen.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/OnboardingScreen/onboarding_screen.dart';
import 'package:zal/Screens/OnboardingScreen/onboarding_screen_providers.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final shouldShowOnboarding = ref.watch(shouldShowOnboardingProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(contextProvider.notifier).state = context);
    if (auth.hasValue == false || shouldShowOnboarding.hasValue == false) {
      return const OnboardingScreen();
    }
    if (shouldShowOnboarding.valueOrNull == true) return const OnboardingScreen();
    if (auth.value == null) return const MainLoginScreen();
    return AuthorizedScreen();
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
