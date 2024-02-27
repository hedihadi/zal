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
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';
import '../../Functions/analytics_manager.dart';

final selectedGameProvider = StateProvider.autoDispose<Map<String, String>?>((ref) => null);

class CanRunGameScreen extends ConsumerWidget {
  const CanRunGameScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("can-run-game"));
    ref.watch(settingsProvider);
    final canRunGame = ref.watch(canRunGameProvider);
    final selectedGame = ref.watch(selectedGameProvider);
    ref.read(computerSpecsProvider);
    final gpu = ref.read(settingsProvider).value?['primaryGpuName'];
    if (gpu == null) {
      return const Center(
        child: Text(
          "We currently do not have your PC specifications saved, please connect to your PC before using this feature.",
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: ListView(
        children: [
          Text(
            "Our system will compare your PC with the specifications of the desired game to ensure you can play the game. this is a feature in beta, you may encounter bugs.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey[400]),
          ),
          SizedBox(height: 2.h),
          TextField(
            decoration: const InputDecoration(label: Text("what game you want to play?")),
            onChanged: (value) {
              ref.read(gameNameProvider.notifier).state = value;
            },
          ),
          SizedBox(height: 1.h),
          const GamesList(),
          if (selectedGame != null)
            canRunGame.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
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
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7125283104" : "ca-app-pub-5545344389727160/2500971371"),
        ],
      ),
    );
  }
}

class GamesList extends ConsumerWidget {
  const GamesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchGameResult = ref.watch(searchGameProvider);

    return searchGameResult.when(
        data: (data) {
          if (data == null) return Container();
          if (data.isEmpty) {
            return Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: const Text("No Game found..."),
            ));
          }
          return Column(
            children: [
              Text("Choose your game", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
              SizedBox(
                height: 15.h,
                child: ListView.builder(
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final game = data[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedGameProvider.notifier).state = game;
                      },
                      child: Card(
                        color: ref.watch(selectedGameProvider) == game ? Theme.of(context).primaryColor : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(
                                  game['name']!,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Image.network(game['logo']!),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          print(error);
          print(stackTrace);
          return Text("$error");
        },
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
