import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/InitialConnectionScreen/Widgets/initial_connection_settings_screen.dart';
import 'package:zal/Screens/InitialConnectionScreen/initial_connection_screen_providers.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class ChooseComputerWidget extends ConsumerWidget {
  const ChooseComputerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computers = ref.watch(loadedComputerAddressesProvider);
    final isLoading = ref.watch(localcomputerAddressesProvider).isLoading;
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 2.h),
        Center(
          child: Text(
            "Choose the PC you want to connect",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (ref.read(localcomputerAddressesProvider).error?.runtimeType == NetworkPrefixIsNull)
          const Card(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("we couldn't get the network prefix, please manually set it in Settings"),
          )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                ref.invalidate(localcomputerAddressesProvider);
              },
              icon: const Icon(FontAwesomeIcons.arrowsRotate),
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InitialConnectionSettingsScreen()));
              },
              icon: const Icon(FontAwesomeIcons.gear),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: computers.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          computers[index].name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text("IP: ${computers[index].ip.replaceAll('http://', '')}"),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Connect"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Divider(),
        Wrap(
          children: [
            const Text("your phone must be connected to the same network as your PC"),
            TextButton.icon(
              onPressed: () {
                launchUrl(Uri.parse("https://discord.gg/kfyZmqXjd6"), mode: LaunchMode.externalNonBrowserApplication);
              },
              label: const Text("Get help on Discord"),
              icon: const Icon(FontAwesomeIcons.discord),
            ),
          ],
        ),
      ],
    );
    // return computers.when(
    //   data: (data) {
    //
    //   },
    //   error: (error, stackTrace) {
    //     print(stackTrace);
    //     print(error);
    //     return const Text("error");
    //   },
    //   loading: () {
    //     return const CircularProgressIndicator();
    //   },
    // );
  }
}
