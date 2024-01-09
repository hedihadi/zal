import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: notifications.map((e) => Text(e.factorType.toString())).toList(),
      ),
    
    );
  }
}
