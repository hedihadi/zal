import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';
import 'package:http/http.dart' as http;

class AnalyticsManager {
  static String databaseUrl = dotenv.env['SERVER'] == 'production' ? "https://zalapp.com/api" : "http://192.168.0.102:8000/api";
  static const String pcNotificationChannelId = 'pc_notifications_channel';
  static const String pcNotificationChannelName = 'PC Notifications';
  static Future<void> sendUserDataToDatabase(bool isPremium) async {
    final userResponse = await requestFirebaseMessagingPermission();
    if (userResponse == false) return;
    final userUsingAdblock = await isUserUsingAdblock();
    final firebaseMessagingId = await FirebaseMessaging.instance.getToken();

    await sendDataToDatabase("consumer", data: {
      'userUsingAdblock': "$userUsingAdblock",
      'isPremium': "$isPremium",
      'firebaseMessagingId': firebaseMessagingId,
    });
  }

  static sendDataToDatabase(String route, {Map<String, dynamic> data = const {}}) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

    final url = Uri.parse("$databaseUrl/$route");
    final body = jsonEncode(data);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    final response = await http.post(url, body: body, headers: headers);
    return response;
  }

  static Future<bool> requestFirebaseMessagingPermission() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      pcNotificationChannelId,
      pcNotificationChannelName,
      description: "receive notifications from your PC",
      importance: Importance.high,
      enableLights: true,
      playSound: true,
      sound: UriAndroidNotificationSound('beep'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.denied) {
      return true;
    }
    return false;
  }

  static Future<void> setForegroundListenerForFirebaseMessaging() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
            0, // Notification ID
            message.notification!.title, // Notification title
            message.notification!.body, // Notification body

            const NotificationDetails(
                android: AndroidNotificationDetails(
              pcNotificationChannelId,
              pcNotificationChannelName,
              sound: UriAndroidNotificationSound('beep'),
            )));
      }
    });
  }

  static Future<void> setIsUserUsingAdblock() async {
    final result = await isUserUsingAdblock();
    await FirebaseAnalytics.instance.setUserProperty(name: "using-adblock", value: result.toString());
  }

  static Future<void> logScreenView(String name) async {
    await FirebaseAnalytics.instance.setCurrentScreen(screenName: name);
  }

  static Future<void> logEvent(
    String name, {
    Map<String, dynamic> options = const {},

    /// if true, we will send this event whether the user has disabled analytics or not.
    bool ignoreSettings = false,
  }) async {
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: options);
  }
}

final screenViewProvider = FutureProviderFamily((ref, String screenName) async {
  await AnalyticsManager.logScreenView(screenName);
});
