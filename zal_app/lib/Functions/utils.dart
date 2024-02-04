import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';

WebrtcDataType convertStringToWebrtcDataType(String input) {
  //first convert camel_case to camelCase
  List<String> parts = input.split('_');
  String result = parts[0];

  for (int i = 1; i < parts.length; i++) {
    result += parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  //then get the data type from it
  return WebrtcDataType.values.byName(result);
}

String truncateString(String text, length) {
  return (text.length <= length) ? text : '${text.substring(0, length)}...';
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

TableRow rowWidget(String title1, String value1, String title2, String value2, context) {
  return TableRow(children: [
    TableCell(
      child: Text(
        title1,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
    TableCell(
      child: Text(
        value1,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
    TableCell(
      child: Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: Text(
          title2,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.end,
        ),
      ),
    ),
    TableCell(
      child: Text(
        value2,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
  ]);
}

Color getTemperatureColor(double temperature) {
  // List of colors from blue to red
  List<Color> colors = [
    HexColor("#00BBFF"),
    HexColor("#87DFFF"),
    HexColor("#FFF94C"),
    HexColor("#ffd000"),
    HexColor("#f4a261"),
    HexColor("#FF3838"),
  ];
  final t = temperature;
  if (-50 <= t && t <= 10) {
    return colors[0];
  } else if (10 <= t && t <= 30) {
    return colors[1];
  } else if (30 <= t && t <= 50) {
    return colors[2];
  } else if (50 <= t && t <= 60) {
    return colors[3];
  } else if (60 <= t && t <= 80) {
    return colors[4];
  } else if (80 <= t && t <= 1000) {
    return colors[5];
  } else {
    return Colors.orange;
  }
}

///converts seconds into this format 00:00
String formatTime(int seconds) {
  int minutes = (seconds ~/ 60);
  int remainingSeconds = seconds % 60;

  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

  return '$formattedMinutes:$formattedSeconds';
}

///this function is used to get the color for ram in task manager
Color getRamAmountColor(double megabytes) {
  // List of colors from blue to red
  List<Color> colors = [
    HexColor("#00BBFF"),
    HexColor("#87DFFF"),
    HexColor("#FFF94C"),
    HexColor("#ffd000"),
    HexColor("#f4a261"),
    HexColor("#FF3838"),
  ];
  final t = megabytes;
  if (-50 <= t && t <= 40) {
    return colors[0];
  } else if (40 <= t && t <= 100) {
    return colors[1];
  } else if (100 <= t && t <= 300) {
    return colors[2];
  } else if (300 <= t && t <= 600) {
    return colors[3];
  } else if (600 <= t && t <= 1000) {
    return colors[4];
  } else if (1000 <= t && t <= 999999999) {
    return colors[5];
  } else {
    return Colors.orange;
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}

Future<bool> showConfirmDialog(String title, String message, BuildContext context, {bool showButtons = true}) async {
  AlertDialog alert = AlertDialog(
    title: Text(title, style: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayLarge),
    content: Text(message),
    actions: showButtons
        ? [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ]
        : null,
  );

  // show the dialog
  return (await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          )) ==
          true
      ? true
      : false;
}

///convers camelCase to readable text,
///ex: computerData -> Computer Data.
String convertCamelToReadable(String input) {
  String result = input.replaceAllMapped(RegExp(r'([A-Z])'), (Match match) {
    return ' ${match.group(1)}';
  });

  // Capitalize the first letter and remove leading whitespace
  result = result.trim().replaceFirstMapped(RegExp(r'^\w'), (match) {
    String letter = match.group(0) ?? ''; // Extract the matched string
    return letter.toUpperCase(); // Convert to uppercase
  });

  return result;
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

Future<void> showInformationDialog(String? title, String message, BuildContext context) async {
  AlertDialog alert = AlertDialog(
    title: title == null ? null : Text(title),
    content: Text(message),
  );

  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

///https://stackoverflow.com/questions/39735145/how-to-compress-a-string-using-gzip-or-similar-in-dart
String compressGzip(String text) {
  final enCodedJson = utf8.encode(text);
  final gZipJson = gzip.encode(enCodedJson);
  final base64Json = base64.encode(gZipJson);
  return base64Json;
}

///https://stackoverflow.com/questions/39735145/how-to-compress-a-string-using-gzip-or-similar-in-dart
String decompressGzip(String text) {
  final decodeBase64Json = base64.decode(text);
  final decodegZipJson = gzip.decode(decodeBase64Json);
  final originalJson = utf8.decode(decodegZipJson);
  return originalJson;
}

extension FancyNum on num {
  String toSize({decimals = 2, addSpace = false}) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (this == 0) return '0${addSpace ? ' ' : ''}${suffixes[0]}';
    var i = (log(this) / log(1024)).floor();
    return "${(this / pow(1024, i)).toStringAsFixed(decimals)}${addSpace ? ' ' : ''}${suffixes[i]}";
  }

  String removeTrailingZero() {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

    String s = toString().replaceAll(regex, '');
    return s;
  }
}

String secondsToWrittenTime(int seconds) {
  if (seconds < 60) {
    return '$seconds seconds';
  }

  final Duration duration = Duration(seconds: seconds);
  final int years = (duration.inDays / 365.25).floor();
  final int days = duration.inDays % 365;

  List<String> parts = [];

  if (years > 0) {
    parts.add('$years ${years == 1 ? 'year' : 'years'}');
  }

  if (days > 0) {
    parts.add('$days ${days == 1 ? 'day' : 'days'}');
  }

  return parts.join(' and ');
}

TableRow tableRow(BuildContext context, String title, IconData icon, String text,
    {bool addSpacing = false, bool colorTitle = true, bool showIcon = true, Widget? customIcon, Widget? suffixIcon}) {
  final paddingHeight = 1.h;
  return TableRow(
    children: <Widget>[
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.top,
        child: Padding(
          padding: EdgeInsets.only(top: paddingHeight / 2, bottom: paddingHeight / 2, right: addSpacing ? 2.w : 0),
          child: Row(
            children: [
              showIcon ? (customIcon ?? Icon(icon, size: 2.h, color: colorTitle ? Theme.of(context).primaryColor : null)) : Container(),
              SizedBox(width: 2.w),
              Text(title, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: colorTitle ? Theme.of(context).primaryColor : null)),
              suffixIcon ?? Container(),
            ],
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.top,
        child: Padding(
          padding: EdgeInsets.only(top: paddingHeight / 2, bottom: paddingHeight / 2),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    ],
  );
}

///if [returnFahrenheit] is true, we will convert the celcius to fahrenheit
String getTemperatureText(double? tempCelcius, WidgetRef ref, {bool round = true}) {
  if (tempCelcius == null) {
    return '';
  }
  if (ref.read(settingsProvider).value?.useCelcius ?? true) {
    return "${round ? tempCelcius.round() : tempCelcius.toStringAsFixed(2)}°C";
  }

  double f = (tempCelcius * (9 / 5)) + 32;

  return "${round ? f.round() : f.toStringAsFixed(2)}°F";
}

Future<bool> isUserUsingAdblock() async {
  try {
    final response = await http.get(Uri.parse("https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"));
    return false;
  } on Exception {
    return true;
  }
}

void showSnackbar(String text, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          text,
        ),
        showCloseIcon: true,
        // backgroundColor: Theme.of(context).cardColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
