import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Screens/SettingsScreen/Widgets/select_primary_network_screen.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/switch_setting_ui.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:url_launcher/url_launcher.dart';

final revenueCatIdProvider = FutureProvider((ref) => Purchases.appUserID);

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key});
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("settings"));
    final settings = ref.watch(settingsProvider).value;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SectionSettingUi(
            children: [
              SwitchSettingUi(
                title: "Use Celcius",
                subtitle: "switch between Celcius and Fahreneit",
                value: settings?.useCelcius ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateUseCelcius(value),
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
                value: settings?.sendAnalaytics ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateSendAnalytics(value),
                icon: const Icon(FontAwesomeIcons.paintRoller),
              ),
              SwitchSettingUi(
                title: "Personalized Ads",
                subtitle: "",
                value: settings?.personalizedAds ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updatePersonalizedAds(value),
                icon: const Icon(FontAwesomeIcons.paintRoller),
              ),
            ],
          ),
          ref.watch(socketProvider).value == null
              ? Container()
              : SectionSettingUi(children: [
                  Text("Select your primary GPU", style: Theme.of(context).textTheme.titleLarge),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ref.watch(socketProvider).value!.gpus.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
                    itemBuilder: (context, index) {
                      final gpu = ref.read(socketProvider).value!.gpus[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(settingsProvider.notifier).updatePrimaryGpuName(gpu.name);
                        },
                        child: Card(
                          color: (settings?.primaryGpuName ?? "") == gpu.name ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                          elevation: 5,
                          shadowColor: Colors.transparent,
                          child: Center(
                            child: Text(
                              gpu.name,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).cardColor),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectPrimaryNetworkScreen()));
                          },
                          icon: const Icon(FontAwesomeIcons.gear),
                          label: const Text("Primary Network"))),
                ]),
          //MISC
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout), label: const Text("Sign out")),
              TextButton.icon(
                  onPressed: () async {
                    final response =
                        await showConfirmDialog("Delete Account", "your account will be permanently deleted, you cannot undo this!", context);
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
              Text("UID:\n${ref.watch(authProvider).value!.uid}"),
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
