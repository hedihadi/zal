import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdmobConsentHelper {
  Future<void> initialize({bool forced = false}) async {
    //wait for 2 days before showing consent to user.
    if (forced != true) {
      if (await shouldShowConsent() == false) return;
    }

    final params = ConsentRequestParameters(
        consentDebugSettings:
            ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: ['4439C2062462DFFEDC9E8F2D3AEC04C8']));
    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      final isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
      if (isConsentFormAvailable) {
        //we may have to show consent
        ConsentForm.loadConsentForm((consentForm) async {
          final status = await ConsentInformation.instance.getConsentStatus();
          if (status == ConsentStatus.required) {
            consentForm.show((formError) {
              print(formError);
            });
          }
        }, (error) {
          print(error);
        });
      }
    }, (error) {
      // Manage error
      print(error);
    });
  }

  Future<bool> shouldShowConsent() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('firstOpen')) {
      final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('firstOpen')!);
      if (DateTime.now().difference(firstOpenDate).inDays >= 2) {
        return true;
      }
    } else {
      prefs.setInt('firstOpen', DateTime.now().millisecondsSinceEpoch);
    }
    return false;
  }

  Future<FormError?> _loadConsentForm() async {
    final completer = Completer<FormError?>();

    ConsentForm.loadConsentForm((consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((formError) {
          completer.complete(_loadConsentForm());
        });
      } else {
        // The user has chosen an option,
        // it's time to initialize the ads component.
        completer.complete();
      }
    }, (FormError? error) {
      completer.complete(error);
    });

    return completer.future;
  }
}
