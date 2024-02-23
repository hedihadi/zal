import 'dart:convert';
import 'package:firedart/auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/utils.dart';

class AnalyticsManager {
  //static String databaseUrl = "https://zalapp.com/api/";
  static String databaseUrl = dotenv.env['SERVER'] == 'production' ? "https://zalapp.com/api" : "http://192.168.0.120:5555/api";

  static sendAlertToMobile(NotificationData notification, double value) async {
    String displayName = notification.childKey.displayName ?? "${notification.key.name}'s ${convertCamelToReadable(notification.childKey.keyName)}";
    String body =
        "$displayName ${notification.factorType == NewNotificationFactorType.Lower ? 'fell below' : 'reached'} ${_formatDouble(value)}${notification.childKey.unit}";
    AnalyticsManager.sendDataToDatabase('pc_message', data: {'title': 'ALERT!', 'body': body});
  }

  ///example: sendDataToDatabase('program-time',data);
  static Future<http.Response> sendDataToDatabase(String route, {Map<String, dynamic> data = const {}}) async {
    final idToken = await FirebaseAuth.instance.tokenProvider.idToken;

    final url = Uri.parse("$databaseUrl/$route");
    final body = jsonEncode(data);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
    print(idToken);
    final response = await http.post(url, body: body, headers: headers);
    return response;
  }

  static String _formatDouble(double number) {
    String formattedString = number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 1);
    return formattedString.endsWith('.0') ? formattedString.split('.')[0] : formattedString;
  }
}
