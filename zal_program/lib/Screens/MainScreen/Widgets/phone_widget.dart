import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';

class PhoneWidget extends ConsumerWidget {
  const PhoneWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webrtc = ref.watch(webrtcProvider);
    ref.watch(sendDataToMobileProvider);
    return Column(
      children: [
        Image.asset("assets/images/icons/phone.png", height: 3.h),
        const SizedBox(height: 4),
        Container(
          width: 10, // Change the size of the circle here
          height: 10, // Change the size of the circle here
          decoration: BoxDecoration(
            color: webrtc.isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
