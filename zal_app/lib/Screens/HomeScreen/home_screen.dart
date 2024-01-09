import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/Widgets/battery_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/cpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/gpu_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/is_program_adminstrator_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/network_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/ram_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/report_error_widget.dart';
import 'package:zal/Screens/HomeScreen/Widgets/storage_widget.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/TaskManagerScreen/Widgets/taskmanager_table_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/staggered_gridview.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socket = ref.watch(socketProvider);
    ref.watch(shouldShowUpdateDialogProvider);
    ref.read(processIconProvider);
    return Center(
      child: socket.when(
        skipLoadingOnReload: true,
        data: (data) {
          return ListView(
            children: [
              const IsProgramAdminstratorWidget(),
              StaggeredGridview(
                children: [
                  const CpuWidget(),
                  const GpuWidget(),
                  const RamWidget(),
                  data.battery.hasBattery ? const BatteryWidget() : null,
                  //const FpsWidget(),
                  const NetworkWidget(),
                ],
              ),
              const StorageWidget(),
              InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/4695435315" : "ca-app-pub-5545344389727160/5860639295"),
            ],
          );
        },
        error: (error, stackTrace) {
          if (error.runtimeType == ComputerOfflineException) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("your PC is offline, make sure Zal is running on your Computer.", textAlign: TextAlign.center),
                ElevatedButton(
                    onPressed: () {
                      ref.read(socketObjectProvider)?.socket.connect();
                    },
                    child: const Text("Reconect")),
                TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://zalapp.com/info#connect"));
                    },
                    child: const Text("Help")),
              ],
            );
          }
          if (error.runtimeType == TooEarlyToReturnError) {
            return Container();
          }
          if (error.runtimeType == NotConnectedToSocketException) {
            return const Text("not connected to server, make sure you have internet connection", textAlign: TextAlign.center);
          } else if (error.runtimeType == DataIsNullException) {
            return Container();
          } else if (error.runtimeType == ErrorParsingComputerData) {
            return ReportErrorWidget(error: error);
          } else {
            print(error);
            print("$stackTrace");
            return Text("$error");
          }
        },
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
