import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_provider.dart';

class PhoneWidget extends ConsumerWidget {
  const PhoneWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverSocketData = ref.watch(serverSocketProvider).value;
    ref.watch(sendDataToMobileProvider);
    if (serverSocketData == null) return const Text("..");
    return Column(
      children: [
        Image.asset("assets/images/icons/phone.png", height: 3.h),
        const SizedBox(height: 4),
        Container(
          width: 10, // Change the size of the circle here
          height: 10, // Change the size of the circle here
          decoration: BoxDecoration(
            color: serverSocketData.isMobileConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
