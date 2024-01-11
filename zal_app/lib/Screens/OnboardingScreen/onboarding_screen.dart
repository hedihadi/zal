import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/OnboardingScreen/onboarding_screen_providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to Zal!",
            body: "we'll walk you through to get started.",
            image: Center(
                child: CircleAvatar(
              radius: 15.h,
              foregroundImage: const AssetImage("assets/images/original.png"),
              backgroundColor: Colors.white,
            )),
          ),
          PageViewModel(
            title: "have you installed Zal on you PC?",
            body: 'Zal app needs to somehow communicate with your PC, so you need to install Zal on PC from ZalApp.com',
            image: Container(),
          ),
          PageViewModel(
            title: "how do i connect to my PC?",
            body: "just sign into the same account as your mobile, it can't get easier!",
            image: Container(),
          ),
          PageViewModel(
            title: "we'll setup some notifications for you!",
            body:
                "With Zal, you have the ability to create personalized notifications that your computer can send to your mobile device. To help you get started, we'll create some temperature notifications!",
            image: Container(),
          ),
          PageViewModel(
            title: "remember, Zal is new!",
            body: "with a solo developer, there are too many things to do. don't forget to report any problem you have on Discord!",
            image: Container(),
          ),
        ],
        showNextButton: false,
        done: const Text("Done"),
        onDone: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('onboarding', true);
          ref.invalidate(shouldShowOnboardingProvider);
        },
      ),
    );
  }
}
