import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/is_computer_online_on_server_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/HomeScreen/Widgets/home_screen_connected_widget.dart';

final shouldListenToWebrtcDataChangesProvider = StateProvider<bool>((ref) => true);
final shouldShowConnectedWidgetProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnectedToServer = ref.watch(isConnectedToServerProvider);
    final isComputerOnlineOnServer = ref.watch(isComputerOnlineOnServerProvider);
    final isWebrtcConnected = ref.watch(webrtcProvider.select((value) => value.isConnected));
    WebrtcData? webrtcData;
    final shouldListenToWebrtcDataChanges = ref.read(shouldListenToWebrtcDataChangesProvider);
    if (isWebrtcConnected == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shouldListenToWebrtcDataChangesProvider.notifier).state = true;
      });
    }
    if (shouldListenToWebrtcDataChanges) {
      webrtcData = ref.watch(webrtcProvider.select((value) => value.data));
      if (webrtcData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(shouldListenToWebrtcDataChangesProvider.notifier).state = false;
        });
      }
    }
    bool shouldShowConnectedWidget = false;
    if (isConnectedToServer &&
        isComputerOnlineOnServer.valueOrNull == true &&
        isWebrtcConnected &&
        (webrtcData != null || shouldListenToWebrtcDataChanges == false)) {
      shouldShowConnectedWidget = true;
    }
    if (shouldShowConnectedWidget) {
      return const HomeScreenConnectedWidget();
    }
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
              },
              children: [
                tableRow(context, '', isConnectedToServer ? Icons.check : Icons.close, "Connecting to server"),
                tableRow(context, '', isComputerOnlineOnServer.valueOrNull == true ? Icons.check : Icons.close, "waiting for PC to respond"),
                tableRow(context, '', isWebrtcConnected ? Icons.check : Icons.close, "establishing peer-to-peer connection"),
                tableRow(context, '', (webrtcData != null || shouldListenToWebrtcDataChanges == false) ? Icons.check : Icons.close,
                    "waiting for PC to send first data"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
