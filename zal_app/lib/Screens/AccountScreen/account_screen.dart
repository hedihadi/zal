import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/AboutScreen/about_screen.dart';
import 'package:zal/Screens/AccountScreen/Widgets/change_name_widget.dart';
import 'package:zal/Screens/AccountScreen/Widgets/specs_widget.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Widgets/inline_ad.dart';

import '../../Functions/analytics_manager.dart';

final bottomNavigationbarIndexProvider = StateProvider((ref) => 0);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("account"));
    final user = ref.watch(authProvider);
    return ListView(
      children: [
        SizedBox(height: 3.h),
        CircleAvatar(
          radius: 5.h,
          child: Icon(
            FontAwesomeIcons.user,
            size: 5.h,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.value!.isAnonymous ? 'Anonymous' : user.value!.displayName ?? 'Someone Mysterious',
                style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const ChangeNameWidget(),
          ],
        ),
        const Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Rig", style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
                  },
                  icon: const Icon(FontAwesomeIcons.gear)),
            ],
          ),
        ),
        const Card(child: SpecsWidget()),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Column(
              children: [
                const Text("have a question? join our Discord server!"),
                TextButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse("https://discord.gg/kfyZmqXjd6"), mode: LaunchMode.externalNonBrowserApplication);
                  },
                  icon: const Icon(FontAwesomeIcons.discord),
                  label: const Text("Discord Server"),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Column(
              children: [
                const Text("need help? visit our website!"),
                TextButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse("https://zalapp.com/"), mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(FontAwesomeIcons.mobileScreenButton),
                  label: const Text("Zalapp.com"),
                ),
              ],
            ),
          ),
        ),
        InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
      ],
    );
  }
}

class AuthorizedDrawer extends StatelessWidget {
  const AuthorizedDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: TextButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse("https://discord.gg/kfyZmqXjd6"), mode: LaunchMode.externalNonBrowserApplication);
                },
                icon: const Icon(FontAwesomeIcons.discord),
                label: const Text("Discord Server"),
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            ListTile(
              title: const Text('Account'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
