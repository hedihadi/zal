import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:upgrader/upgrader.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen.dart';
import 'package:zal/firebase_options.dart';
import 'Functions/theme.dart';

final _revenueCatConfiguration = PurchasesConfiguration(Platform.isAndroid ? 'goog_xokAwGykaqKIgLAIODrNHTTMnxF' : 'appl_eqiIImrSxvAweggWipqxMOgYidj');
Future<void> main() async {
  Gemini.init(apiKey: 'AIzaSyCAsBp3Ol_W-3zaS6AFI5eJfs8hvr3VDPo');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: Platform.isAndroid ? DefaultFirebaseOptions.android : DefaultFirebaseOptions.ios);
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await AnalyticsManager.requestFirebaseMessagingPermission();
  await AnalyticsManager.setForegroundListenerForFirebaseMessaging();

  MobileAds.instance.initialize();
  Purchases.configure(_revenueCatConfiguration);
  await dotenv.load(fileName: ".env");
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
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      themeMode: ref.watch(themeModeProvider),
      theme: AppTheme.lightTheme,
      //darkTheme: FlexThemeData.dark(
      //  colors: FlexSchemeColor.from(
      //    primary: Colors.lightBlueAccent,
      //    primaryContainer: Colors.red,
      //    secondary: Colors.red,
      //  ),
      //  usedColors: 1,
      //  surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      //  blendLevel: 1,
      //  appBarStyle: FlexAppBarStyle.background,
      //  subThemesData: const FlexSubThemesData(
      //    blendOnLevel: 1,
      //    blendTextTheme: true,
      //    useTextTheme: true,
      //    useM2StyleDividerInM3: true,
      //    elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
      //    elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
      //    segmentedButtonSchemeColor: SchemeColor.primary,
      //    inputDecoratorSchemeColor: SchemeColor.primary,
      //    inputDecoratorBackgroundAlpha: 43,
      //    inputDecoratorRadius: 8.0,
      //    inputDecoratorUnfocusedHasBorder: false,
      //    inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      //    popupMenuRadius: 6.0,
      //    popupMenuElevation: 4.0,
      //    dialogElevation: 3,
      //    dialogRadius: 20,
      //    drawerIndicatorSchemeColor: SchemeColor.primary,
      //    bottomNavigationBarMutedUnselectedLabel: false,
      //    bottomNavigationBarMutedUnselectedIcon: false,
      //    menuRadius: 6.0,
      //    menuElevation: 4.0,
      //    menuBarRadius: 0.0,
      //    menuBarElevation: 1.0,
      //    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      //    navigationBarMutedUnselectedLabel: false,
      //    navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
      //    navigationBarMutedUnselectedIcon: false,
      //    navigationBarIndicatorSchemeColor: SchemeColor.primary,
      //    navigationBarIndicatorOpacity: 1.00,
      //    navigationBarBackgroundSchemeColor: SchemeColor.background,
      //    navigationBarElevation: 0,
      //    navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      //    navigationRailMutedUnselectedLabel: false,
      //    navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
      //    navigationRailMutedUnselectedIcon: false,
      //    navigationRailIndicatorSchemeColor: SchemeColor.primary,
      //    navigationRailIndicatorOpacity: 1.00,
      //  ),
      //  keyColors: const FlexKeyColors(
      //    useSecondary: true,
      //    useTertiary: true,
      //  ),
      //  tones: FlexTones.oneHue(Brightness.dark),
      //  visualDensity: FlexColorScheme.comfortablePlatformDensity,
      //  useMaterial3: false,
      //  darkIsTrueBlack: false,
      //  // To use the Playground font, add GoogleFonts package and uncomment
      //  // fontFamily: GoogleFonts.notoSans().fontFamily,
      //).copyWith(
      //  //cardColor: HexColor("#1b1b1b"),
      //  scaffoldBackgroundColor: HexColor("#121212"),
      //  inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme
      //      .copyWith(focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder!.copyWith(borderSide: BorderSide.none)),
      //  textTheme: AppTheme.darkTheme.textTheme.copyWith(
      //    labelSmall: AppTheme.darkTheme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w300),
      //    titleLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleLarge,
      //  ),
      //),
      darkTheme: AppTheme.darkTheme.copyWith(
        inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme
            .copyWith(focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder!.copyWith(borderSide: BorderSide.none)),
        textTheme: AppTheme.darkTheme.textTheme.copyWith(
          labelSmall: AppTheme.darkTheme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w300),
          titleLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleLarge,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: UpgradeAlert(
        child: const LoaderOverlay(overlayColor: Colors.black54, child: MainScreen()),
      ),
    );
  }
}
