import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/SettingsUI/custom_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/switch_setting_ui.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

import '../../Functions/admob_consent_helper.dart';

final revenueCatIdProvider = FutureProvider((ref) => Purchases.appUserID);

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key});
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController localConnectionAddressController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("settings"));
    final settings = ref.watch(settingsProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SectionSettingUi(
            children: [
              SwitchSettingUi(
                title: "Use Celcius",
                subtitle: "switch between Celcius and Fahreneit",
                value: settings?['useCelcius'] ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateSettings('useCelcius', value),
                icon: const Icon(FontAwesomeIcons.temperatureHalf),
              ),
            ],
          ),

          SectionSettingUi(
            children: [
              SwitchSettingUi(
                title: "Send Analytics",
                subtitle:
                    "your data will be used to see how the App\nbehaves on different PC Specs,this is \nextremely helpful to me, please leave it ON.",
                value: settings?['sendAnalaytics'] ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateSettings('sendAnalaytics', value),
                icon: const Icon(FontAwesomeIcons.paintRoller),
              ),
              CustomSettingUi(
                title: "Personalized Ads",
                subtitle: "",
                icon: const Icon(FontAwesomeIcons.paintbrush),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () async {
                        await ConsentInformation.instance.reset();
                        AdmobConsentHelper().initialize(forced: true);
                      },
                      child: const Text("choose")),
                ),
              ),
            ],
          ),

          //MISC
          SectionSettingUi(
            children: [
              Text("Purchases ID:\n${ref.watch(revenueCatIdProvider).value}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://www.freeprivacypolicy.com/live/6a690c4a-7f7a-4614-aee0-fce78a3e2995"),
                  );
                },
                child: const Text("Privacy Policy"),
              ),
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://developer.apple.com/app-store/review/guidelines/#privacy"),
                  );
                },
                child: const Text("TOS"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
