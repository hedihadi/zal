import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:zal/Screens/HomeScreen/home_screen.dart';
import 'package:zal/Screens/MainScreen/Widgets/phone_widget.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_screen.dart';
import 'package:zal/Screens/computer_screen.dart';
final sidebarSelectedIndexProvider = StateProvider<int>((ref) => 0);

class AuthorizedScreen extends ConsumerWidget {
  const AuthorizedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarSelectedIndex = ref.watch(sidebarSelectedIndexProvider);
    ref.read(notificationsProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SidebarX(
          footerBuilder: (context, extended) {
            return const PhoneWidget();
          },
          controller: SidebarXController(selectedIndex: sidebarSelectedIndex),
          showToggleButton: false,
          items: [
            SidebarXItem(
              icon: FontAwesomeIcons.chartSimple,
              label: 'Home',
              onTap: () => ref.read(sidebarSelectedIndexProvider.notifier).state = 0,
            ),
            //SidebarXItem(
            //  icon: FontAwesomeIcons.bell,
            //  label: 'Notifications',
            //  onTap: () => ref.read(sidebarSelectedIndexProvider.notifier).state = 1,
            //),
            SidebarXItem(
              icon: FontAwesomeIcons.computer,
              label: 'Computer',
              onTap: () => ref.read(sidebarSelectedIndexProvider.notifier).state = 1,
            ),
            SidebarXItem(
              icon: FontAwesomeIcons.gear,
              label: 'Settings',
              onTap: () => ref.read(sidebarSelectedIndexProvider.notifier).state = 2,
            ),
          ],
        ),
        Expanded(
          child: [
            const HomeScreen(),
            //const NotificationsScreen(),
            const ComputerScreen(),
            SettingsScreen(),
          ][sidebarSelectedIndex],
        ),
      ],
    );
  }
}
