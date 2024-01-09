import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectPrimaryNetworkScreen extends ConsumerWidget {
  const SelectPrimaryNetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerData = ref.watch(socketProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Primary network"),
        actions: [
          IconButton(
            onPressed: () {
              launchUrl(Uri.parse("https://zalapp.com/info#network"), mode: LaunchMode.inAppWebView);
            },
            icon: const Icon(FontAwesomeIcons.question),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: computerData?.networkInterfaces.length,
        itemBuilder: (context, index) {
          final e = computerData!.networkInterfaces[index];
          return GestureDetector(
            onTap: () {
              ref.read(socketObjectProvider.notifier).state?.sendData("change_primary_network", e.name);
              showSnackbar("primary network changed!", context);
            },
            child: CardWidget(
              titleContainerColor: e.isPrimary
                  ? Theme.of(context).primaryColor
                  : e.isEnabled
                      ? null
                      : Theme.of(context).colorScheme.errorContainer,
              title: e.name,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        tableRow(
                          context,
                          "Description",
                          FontAwesomeIcons.plug,
                          e.description,
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "Status",
                          FontAwesomeIcons.plug,
                          e.isEnabled ? "Enabled" : "Disabled",
                          showIcon: false,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        tableRow(
                          context,
                          "Download",
                          FontAwesomeIcons.plug,
                          e.bytesReceived.toSize(decimals: 0, addSpace: true),
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "Upload",
                          FontAwesomeIcons.plug,
                          e.bytesSent.toSize(decimals: 0, addSpace: true),
                          showIcon: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
