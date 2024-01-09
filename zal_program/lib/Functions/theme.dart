import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});

class AppTheme {
  static ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.bahamaBlue,
    usedColors: 1,
    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    blendLevel: 4,
    appBarStyle: FlexAppBarStyle.background,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendTextTheme: true,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
      elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
      segmentedButtonSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorBackgroundAlpha: 43,
      inputDecoratorRadius: 8.0,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      popupMenuRadius: 6.0,
      popupMenuElevation: 4.0,
      dialogElevation: 3,
      dialogRadius: 20,
      drawerIndicatorSchemeColor: SchemeColor.primary,
      bottomNavigationBarMutedUnselectedLabel: false,
      bottomNavigationBarMutedUnselectedIcon: false,
      menuRadius: 6.0,
      menuElevation: 4.0,
      menuBarRadius: 0.0,
      menuBarElevation: 1.0,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarMutedUnselectedLabel: false,
      navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
      navigationBarMutedUnselectedIcon: false,
      navigationBarIndicatorSchemeColor: SchemeColor.primary,
      navigationBarIndicatorOpacity: 1.00,
      navigationBarBackgroundSchemeColor: SchemeColor.background,
      navigationBarElevation: 0,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailMutedUnselectedLabel: false,
      navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
      navigationRailMutedUnselectedIcon: false,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailIndicatorOpacity: 1.00,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    tones: FlexTones.oneHue(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    // To use the Playground font, add GoogleFonts package and uncomment
    // fontFamily: GoogleFonts.notoSans().fontFamily,
  );
  static ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.amber,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useM2StyleDividerInM3: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    // To use the playground font, add GoogleFonts package and uncomment
    //  fontFamily: GoogleFonts.aBeeZee().fontFamily,
  );
}
