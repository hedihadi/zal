import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/SettingsScreen/Widgets/select_primary_network_screen.dart';
import 'package:zal/Widgets/SettingsUI/custom_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/switch_setting_ui.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
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
                value: settings?['useLocalConnection'] ?? false,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateSettings('useLocalConnection', value),
                title: "Local Connection",
                subtitle:
                    "If you have trouble connecting through Internet, enable this option. but your phone must be connected to the same network as your PC.",
                icon: const Icon(FontAwesomeIcons.house),
              ),
              if (settings?['useLocalConnection'] == true)
                CustomSettingUi(
                  title: "Your Local Address",
                  subtitle:
                      "if Local Connection is enabled, you must provide this address. you can find the address by checking Zal on your PC. it's written at the bottom right corner.",
                  icon: const Icon(FontAwesomeIcons.house),
                  child: SizedBox(
                    width: 35.w,
                    child: TextField(
                      controller: TextEditingController(text: settings?['localConnectionAddress'])
                        ..selection = TextSelection.collapsed(offset: settings?['localConnectionAddress'].length ?? 0),
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).updateSettings('localConnectionAddress', value);
                      },
                    ),
                  ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign out")),
              TextButton.icon(
                  onPressed: () async {
                    final response = await showConfirmDialog(
                        "Delete Account", "you want to proceed? your account will be permanently deleted, you cannot undo this!", context);
                    if (response == true) {
                      AlertDialog alert = AlertDialog(
                        title: const Text("enter your Password"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("provide your current password to delete your account"),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Delete my Account"),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );

                      // show the dialog
                      final response1 = (await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              )) ==
                              true
                          ? true
                          : false;
                      if (response1 == true) {
                        await FirebaseAuth.instance
                            .signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser?.email ?? "", password: passwordController.text);
                        await FirebaseAuth.instance.currentUser?.delete();
                        await FirebaseAuth.instance.signOut();
                        ref.invalidate(authProvider);
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete Account")),
            ],
          ),
          SectionSettingUi(
            children: [
              Text("Purchases ID:\n${ref.watch(revenueCatIdProvider).value}"),
              Text("UID:\n${ref.watch(authProvider).value?.uid}"),
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
