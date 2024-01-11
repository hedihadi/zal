import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/NotificationsScreen/Widgets/new_notification_screen.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zal/Widgets/inline_ad.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            onPressed: () {
              launchUrl(Uri.parse("https://zalapp.com/info#notification"), mode: LaunchMode.inAppWebView);
            },
            icon: const Icon(FontAwesomeIcons.question),
          ),
        ],
      ),
      body: ListView(
        children: [
          notifications == null
              ? Container()
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 10),
                      child: Card(
                        color: notification.suspended ? Theme.of(context).colorScheme.errorContainer : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "",
                                  children: <TextSpan>[
                                    const TextSpan(text: "when "),
                                    TextSpan(
                                      text: "${notification.key?.name}",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    const TextSpan(text: "'s "),
                                    TextSpan(
                                      text: convertCamelToReadable(notification.childKey?.keyName ?? ''),
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    const TextSpan(text: " becomes "),
                                    TextSpan(
                                      text: "${notification.factorType?.name}",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    const TextSpan(text: " than "),
                                    TextSpan(
                                      text: "${notification.factorValue}${notification.childKey?.unit}",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    const TextSpan(text: " for more than "),
                                    TextSpan(
                                      text: "${notification.secondsThreshold}",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                                    ),
                                    const TextSpan(text: " seconds."),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        ref.read(socketObjectProvider.notifier).state?.socket.emit(
                                          'edit_notification',
                                          {
                                            'data': {'type': (notification.suspended ? 'unsuspend' : 'suspend'), 'notification': notification},
                                          },
                                        );
                                      },
                                      child: Text(notification.suspended ? 'un-suspend' : 'suspend')),
                                  IconButton(
                                      onPressed: () {
                                        ref.read(socketObjectProvider.notifier).state?.socket.emit(
                                          'edit_notification',
                                          {
                                            'data': {'type': 'delete', 'notification': notification},
                                          },
                                        );
                                        ref.read(notificationsProvider.notifier).deleteNotification(notification);
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.trash,
                                        color: Theme.of(context).colorScheme.error,
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewNotificationScreen()));
        },
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }
}
