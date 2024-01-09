import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/LoginScreen/Widgets/forgot_password_button.dart';
import 'package:zal/Screens/LoginScreen/login_widget.dart';
import 'package:zal/Screens/LoginScreen/sign_up_widget.dart';

final isCreatingAccountProvider = StateProvider<bool>((ref) => false);

final isConnectingAccountProvider = StateProvider<bool>((ref) => false);

class MainLoginScreen extends ConsumerWidget {
  const MainLoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnecting = ref.watch(isConnectingAccountProvider);
    ref.read(screenViewProvider("login"));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(isConnecting ? 'choose a method to connect' : 'Please Sign in  Continue',
                style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Center(
                child: TextButton(
                    onPressed: () async {
                      await showInformationDialog(
                          null, "an account is required to establish a secure connection between your mobile and your PC.", context);
                    },
                    child: const Text("why do i need an Account?"))),
            Builder(
              builder: (context) {
                return ref.watch(isCreatingAccountProvider) ? SignupWidget() : LoginWidget();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isConnecting
                    ? Container()
                    : TextButton.icon(
                        onPressed: () {
                          ref.read(isCreatingAccountProvider.notifier).state = !ref.read(isCreatingAccountProvider);
                        },
                        icon: Container(),
                        label: Text(ref.watch(isCreatingAccountProvider) ? "Login instead" : "Create an Account")),
                const Text("|"),
                ForgotPasswordButton(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
