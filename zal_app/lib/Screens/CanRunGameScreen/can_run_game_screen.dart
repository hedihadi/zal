import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_provider.dart';
import 'package:zal/Screens/CanRunGameScreen/result_widget.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/inline_ad.dart';
import '../../Functions/analytics_manager.dart';

class CanRunGameScreen extends ConsumerWidget {
  const CanRunGameScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("can-run-game"));
    final canRunGame = ref.watch(canRunGameProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: ListView(
        children: [
          SizedBox(height: 2.h),
          TextField(
            decoration: const InputDecoration(label: Text("what game you want to play?")),
            onChanged: (value) {
              ref.read(searchGameProvider.notifier).state = value;
            },
          ),
          SizedBox(height: 1.h),

          if (ref.watch(searchGameProvider)?.isNotEmpty ?? false)
            ElevatedButton(
              onPressed: () {
                if (canRunGame.isLoading) return;
                final data = ref.read(computerSpecsProvider).value!;
                ref.read(canRunGameProvider.notifier).proceed();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: canRunGame.isLoading ? const CircularProgressIndicator() : const Text("Proceed"),
              ),
            ),
          // const ProceedButton(),
          SizedBox(height: 1.h),

          ResultWidget(
            result: canRunGame.value,
          ),

          SizedBox(height: 1.h),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
