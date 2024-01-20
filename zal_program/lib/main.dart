import 'dart:io';

import 'package:firedart/firedart.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
// ignore: depend_on_referenced_packages
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:window_manager/window_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Screens/SettingsScreen/settings_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox("data");
  FirebaseAuth.initialize("AIzaSyDeYt8paN1Q8T-Rz_NfdLGgqWUbAM6AJA8", await HiveStore.create());
  await windowManager.ensureInitialized();
  windowManager.setSize(const Size(600, 400));
  windowManager.setResizable(false);
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('Zal');
  });
  //setting up launchAtStartup package
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  //for some reason this is needed to allow error printing
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  runApp(ProviderScope(
    child: Sizer(builder: (context, orientation, deviceType) {
      return const App();
    }),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider).value;
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: FlexColorScheme.dark(
        colors: FlexSchemeColor.from(
          primary: Colors.blueGrey,
          secondary: Colors.teal,
        ),
      ).toTheme.copyWith(
            inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme.copyWith(
              focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder!.copyWith(borderSide: BorderSide.none),
            ),
            textTheme: AppTheme.darkTheme.textTheme.copyWith(
              labelMedium: GoogleFonts.exoTextTheme(AppTheme.darkTheme.textTheme).labelMedium!.copyWith(fontWeight: FontWeight.bold),
              titleLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleLarge,
              titleMedium: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleMedium,
              displayLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayLarge,
              displayMedium: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayMedium,
            ),
          ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
