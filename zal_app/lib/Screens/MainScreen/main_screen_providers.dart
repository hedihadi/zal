import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Functions/theme.dart';
import '../../Functions/analytics_manager.dart';
import '../HomeScreen/Providers/home_screen_providers.dart';

class IsUserPremiumNotifier extends StateNotifier<bool> {
  bool didSendUserData = false;
  IsUserPremiumNotifier() : super(true) {
    checkUserForSubscriptions();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      checkUserForSubscriptions();
    });
  }
  checkUserForSubscriptions() {
    Purchases.getCustomerInfo().then((value) async {
      if (value.activeSubscriptions.isNotEmpty) {
        state = true;
      } else {
        state = false;
      }
      if (didSendUserData == false) {
        try {
          await AnalyticsManager.sendUserDataToDatabase(state);
          didSendUserData = true;
        } catch (c) {
          Logger().i("failed sending data to database");
        }
      }
    });
  }
}

final isUserPremiumProvider = StateNotifierProvider<IsUserPremiumNotifier, bool>((ref) {
  return IsUserPremiumNotifier();
});

final contextProvider = StateProvider<BuildContext?>((ref) => null);

final shouldShowUpdateDialogProvider = FutureProvider((ref) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("app_minimum_build_version");
  final minimumBuildVersion = ((await dbRef.get()).value as int);
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  if (int.parse(packageInfo.buildNumber) < minimumBuildVersion) {
    ref.read(socketObjectProvider.notifier).state?.socket.disconnect();
    AlertDialog alert = AlertDialog(
      title: Text("new update!", style: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("great news! a new update is available, please update your App to keep using Zal."),
          ElevatedButton(
              onPressed: () {
                launchUrl(
                  Uri.parse(Platform.isAndroid ? dotenv.env['GOOGLE_PLAY_URL']! : dotenv.env['APP_STORE_URL']!),
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              },
              child: const Text("Update")),
        ],
      ),
    );
    final context = ref.read(contextProvider);
    await showDialog(
      context: context!,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: false,
    );
  }
  return true;
});
