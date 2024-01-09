import 'package:firedart/auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:zal/Widgets/SettingsUI/switch_setting_ui.dart';
import 'package:zal/Functions/programs_runner.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_stream_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_provider.dart';
import 'package:zal/Screens/StorageScreen/Widgets/text_with_link_icon.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key});
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final runningProcesses = ref.watch(runningProcessesProvider).value;
    return ListView(
      children: [
        SectionSettingUi(
          children: [
            SwitchSettingUi(
              title: "Use Celcius",
              subtitle: "switch between Celcius and Fahreneit",
              value: settings?.useCelcius ?? true,
              onChanged: (value) => ref.read(settingsProvider.notifier).updateUseCelcius(value),
              icon: const Icon(FontAwesomeIcons.temperatureHalf),
            ),
          ],
        ),
        SectionSettingUi(
          children: [
            SwitchSettingUi(
              title: "Run on Startup",
              subtitle: "run Zal when your PC starts",
              value: settings?.runOnStartup ?? true,
              onChanged: (value) => ref.read(settingsProvider.notifier).updateRunOnStartup(value),
              icon: const Icon(FontAwesomeIcons.temperatureHalf),
            ),
            SwitchSettingUi(
              title: "Start Minimized",
              subtitle: "we minimize Zal when you start it",
              value: settings?.startMinimized ?? true,
              onChanged: (value) => ref.read(settingsProvider.notifier).updateStartMinimized(value),
              icon: const Icon(FontAwesomeIcons.userNinja),
            ),
            SwitchSettingUi(
              title: "Run in Background",
              subtitle: "Zal will continue running in Background when you close it",
              value: settings?.runInBackground ?? true,
              onChanged: (value) => ref.read(settingsProvider.notifier).updateRunInBackground(value),
              icon: const Icon(FontAwesomeIcons.windowMaximize),
            ),
            SwitchSettingUi(
              title: "Run as Admin on Startup",
              subtitle: "the Program will automatically ask for admin privileges when you run Zal.",
              value: settings?.runAsAdmin ?? true,
              onChanged: (value) => ref.read(settingsProvider.notifier).updateRunAsAdmin(value),
              icon: const Icon(FontAwesomeIcons.windowMaximize),
            ),
          ],
        ),
        ref.watch(localSocketProvider).value == null
            ? Container()
            : SectionSettingUi(children: [
                const Text("Select your primary GPU"),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ref.watch(localSocketProvider).value!.gpus.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 4),
                  itemBuilder: (context, index) {
                    final gpu = ref.read(localSocketProvider).value!.gpus[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(settingsProvider.notifier).updatePrimaryGpuName(gpu.name);
                      },
                      child: Card(
                        color: (settings?.primaryGpuName ?? "") == gpu.name ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        elevation: 5,
                        shadowColor: Colors.transparent,
                        child: Center(
                          child: Text(
                            gpu.name,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]),
        //MISC
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout), label: const Text("Sign out")),
            const SizedBox(width: 10),
            ElevatedButton.icon(
                onPressed: () async {
                  final response =
                      await showConfirmDialog("Delete Account", "your account will be permanently deleted, you cannot undo this!", context);
                  if (response == true) {
                    AlertDialog alert = AlertDialog(
                      title: const Text("enter your Password"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("provide your current password to delete your account"),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Delete my Account"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );

                    // show the dialog
                    final response1 = (await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            )) ==
                            true
                        ? true
                        : false;
                    if (response1 == true) {
                      await FirebaseAuth.instance.signIn((await FirebaseAuth.instance.getUser()).email ?? "", passwordController.text);
                      await FirebaseAuth.instance.deleteAccount();
                      FirebaseAuth.instance.signOut();
                      ref.invalidate(userProvider);
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text("Delete Account")),
          ],
        ),
        SectionSettingUi(
          children: [
            SelectableText("UID: ${ref.watch(userProvider).value?.id}"),
          ],
        ),
        SectionSettingUi(
          children: [
            Text(
              "Advanced",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 40),
            ),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
                4: FlexColumnWidth(),
              },
              children: <TableRow>[
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextWithLinkIcon(
                        text: 'zal-console.exe',
                        url: "https://zalapp.com/info#processes",
                        textStyle: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      width: 10, // Change the size of the circle here
                      height: 10, // Change the size of the circle here
                      decoration: BoxDecoration(
                        color: (runningProcesses?['zal-console.exe'] ?? false) ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text((runningProcesses?['zal-console.exe'] ?? false) ? "Running" : "Not running"),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: ElevatedButton(onPressed: () => ProgramsRunner.runZalConsole(ref.read(settingsProvider).valueOrNull?.runAsAdmin ?? false), child: const Text("Restart zal-console.exe")),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(child: Container(height: 30)),
                  TableCell(child: Container()),
                  TableCell(child: Container()),
                  TableCell(child: Container()),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextWithLinkIcon(
                        text: 'zal-server.exe',
                        url: "https://zalapp.com/info#processes",
                        textStyle: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      width: 10, // Change the size of the circle here
                      height: 10, // Change the size of the circle here
                      decoration: BoxDecoration(
                        color: (runningProcesses?['zal-server.exe'] ?? false) ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text((runningProcesses?['zal-server.exe'] ?? false) ? "Running" : "Not running")),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: ElevatedButton(onPressed: () => ProgramsRunner.runServer(), child: const Text("Restart zal-server.exe")),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(child: Container(height: 30)),
                  TableCell(child: Container()),
                  TableCell(child: Container()),
                  TableCell(child: Container()),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        "Zal Server",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      width: 10, // Change the size of the circle here
                      height: 10, // Change the size of the circle here
                      decoration: BoxDecoration(
                        color: (ref.watch(serverSocketObjectProvider).value?.socket.connected ?? false) ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text((ref.watch(serverSocketObjectProvider).value?.socket.connected ?? false) ? "Connected" : "Not connected")),
                  ),
                  TableCell(
                    child: Container(),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: "${ref.read(localSocketProvider).value?.parsedData}"));
              },
              child: const Text("copy backend data"),
            ),
          ],
        ),
      ],
    );
  }
}
