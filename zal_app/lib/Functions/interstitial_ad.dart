import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  int loadAttempts = 0;
  int maxFailedLoadAttempts = 5;
  static const AdRequest request = AdRequest();
  Completer<bool> _adCompletion = Completer<bool>();
  StateNotifierProviderRef ref;

  InterstitialAdNotifier(this.ref) : super(null) {
    _createInterstitialAd();
  }

  Future<void> _createInterstitialAd() async {
    if (ref.read(isUserPremiumProvider)) return;
    state?.dispose();
    state = null;

    InterstitialAd.load(
        adUnitId: Platform.isAndroid ? 'ca-app-pub-5545344389727160/8974425828' : 'ca-app-pub-5545344389727160/7210198225',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) async {
            print('$ad loaded');
            state = ad;
            loadAttempts = 0;
            state!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            loadAttempts += 1;
            state = null;
            if (loadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  Future<bool> showAd() async {
    if (ref.read(isUserPremiumProvider)) return false;

    _adCompletion = Completer<bool>();

    if (state == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return false;
    }
    state!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        _adCompletion.complete(false); // Ad dismissed
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
        _adCompletion.complete(false); // Ad failed to show
      },
    );
    await state!.show();
    state = null;
    return _adCompletion.future;
  }
}

final interstitialAdProvider = StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) => InterstitialAdNotifier(ref));
