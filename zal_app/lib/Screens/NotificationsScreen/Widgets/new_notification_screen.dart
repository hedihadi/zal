import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';
import 'package:zal/Widgets/inline_ad.dart';

final newNotificationTimeProvider = StateProvider<int>((ref) => 0);

class NewNotificationScreen extends ConsumerWidget {
  const NewNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedData = ref.read(socketProvider).valueOrNull?.rawData;
    final notificationData = ref.watch(newNotificationDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("New Notification")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Choose the variable you want to observe",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IntrinsicWidth(
              child: DropdownButtonFormField<NewNotificationKey>(
                style: Theme.of(context).textTheme.labelMedium,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: notificationData.key,
                onChanged: (NewNotificationKey? value) {
                  if (value == null) return;
                  ref.watch(newNotificationDataProvider.notifier).setKey(value);
                },
                items: NewNotificationKey.values.map<DropdownMenuItem<NewNotificationKey>>((NewNotificationKey value) {
                  return DropdownMenuItem<NewNotificationKey>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 1.h),
            IntrinsicWidth(
              child: DropdownButtonFormField<NotificationKeyWithUnit>(
                style: Theme.of(context).textTheme.labelMedium,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: notificationData.childKey,
                onChanged: (NotificationKeyWithUnit? value) {
                  if (value == null) return;
                  ref.read(newNotificationDataProvider.notifier).setChildKey(value);
                },
                items: ref
                    .read(newNotificationDataProvider.notifier)
                    .getChildrenForSelectedKey()
                    .map<DropdownMenuItem<NotificationKeyWithUnit>>((NotificationKeyWithUnit value) {
                  return DropdownMenuItem<NotificationKeyWithUnit>(
                    value: value,
                    child: Row(
                      children: [
                        Text(value.displayName ?? convertCamelToReadable(value.keyName)),
                        Text(
                          "  ${value.unit}",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              "Choose the comparing factor",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IntrinsicWidth(
                  child: DropdownButtonFormField<NewNotificationFactorType>(
                    style: Theme.of(context).textTheme.labelMedium,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: notificationData.factorType,
                    onChanged: (NewNotificationFactorType? value) {
                      if (value == null) return;
                      ref.read(newNotificationDataProvider.notifier).setFactorType(value);
                    },
                    items: NewNotificationFactorType.values.map<DropdownMenuItem<NewNotificationFactorType>>((NewNotificationFactorType value) {
                      return DropdownMenuItem<NewNotificationFactorType>(
                        value: value,
                        child: Text(value.name.toString()),
                      );
                    }).toList(),
                  ),
                ),
                IntrinsicWidth(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) => ref.read(newNotificationDataProvider.notifier).setFactorValue(value),
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      suffixIcon: Padding(padding: const EdgeInsets.all(15), child: Text('${notificationData.childKey?.unit}')),
                      hintText: 'write a number',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              "Choose the seconds threshold",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: (notificationData.secondsThreshold ?? 0).toDouble(),
              max: 60,
              divisions: 60,
              label: '${notificationData.secondsThreshold}',
              onChanged: (double value) {
                ref.read(newNotificationDataProvider.notifier).setSecondsThreshold(value.toInt());
              },
            ),
            const Divider(),
            Text(
              "the result",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Card(
              shadowColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: RichText(
                  text: TextSpan(
                    text: "",
                    children: <TextSpan>[
                      const TextSpan(text: "if "),
                      TextSpan(
                        text: "${notificationData.key?.name}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const TextSpan(text: "'s "),
                      TextSpan(
                        text: notificationData.childKey?.displayName ?? convertCamelToReadable(notificationData.childKey?.keyName ?? ''),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const TextSpan(text: " becomes "),
                      TextSpan(
                        text: "${notificationData.factorType?.name}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const TextSpan(text: " than "),
                      TextSpan(
                        text: "${notificationData.factorValue}${notificationData.childKey?.unit}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const TextSpan(text: " for more than "),
                      TextSpan(
                        text: "${notificationData.secondsThreshold}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const TextSpan(text: " seconds, a notification will be sent to your Mobile device."),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  ref.read(socketObjectProvider.notifier).state?.socket.emit('new_notification', {'data': notificationData.toJson()});
                  Navigator.of(context).pop();
                },
                child: const Text("Proceed")),
            InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
          ],
        ),
      ),
    );
  }
}
