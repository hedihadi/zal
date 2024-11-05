import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Screens/InitialConnectionScreen/initial_connection_screen_providers.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:zal/Widgets/SettingsUI/custom_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/switch_setting_ui.dart';

class InitialConnectionSettingsScreen extends ConsumerWidget {
  const InitialConnectionSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final networkPrefix = ref.watch(networkPrefixProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connection Settings"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SectionSettingUi(
            children: [
              CustomSettingUi(
                title: "Port",
                subtitle: "use the same number as your PC",
                icon: const Icon(FontAwesomeIcons.temperatureHalf),
                child: Expanded(
                  child: TextFormField(
                    initialValue: settings?['port'] ?? '4920',
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateSettings('port', value.isEmpty ? null : value);
                    },
                  ),
                ),
              ),
              CustomSettingUi(
                title: "Network Prefix",
                subtitle:
                    "the app will try to get this automatically. if for some reason it can't. you may manually specify the network prefix manually.",
                icon: const Icon(FontAwesomeIcons.temperatureHalf),
                child: Expanded(
                  child: TextFormField(
                    initialValue: networkPrefix,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateSettings('networkPrefix', value.isEmpty ? null : value);
                    },
                  ),
                ),
              ),
            ],
          ),
          Text('network prefix: $networkPrefix'),
          Text('port: ${settings?["port"] ?? "null, using default port 4920"}'),
        ],
      ),
    );
  }
}
