import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firedart/firedart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/theme.dart';
import 'package:zal/Screens/SettingsScreen/settings_provider.dart';
import 'package:http/http.dart' as http;

WebrtcDataType convertStringToWebrtcDataType(String input) {
  switch (input) {
    case "restart_admin":
      return WebrtcDataType.restartAdmin;
    case "edit_notification":
      return WebrtcDataType.editNotification;
    case "new_notification":
      return WebrtcDataType.newNotification;
    case "kill_process":
      return WebrtcDataType.killProcess;
    default:
      throw throw Exception("Invalid input");
  }
}

///this function calls zalapp.com/version and compares it to the local version. if the versions don't match, the function will return true.
Future<bool> isUpdateAvailable() async {
  try {
    final response = await http.get(Uri.parse(dotenv.env['VERSION_URL']!));
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (response.body != packageInfo.version) {
      return true;
    }
  } catch (e) {}
  return false;
}

Future<void> showWindowDialog(Widget content, BuildContext context) async {
  AlertDialog alert = AlertDialog(
    elevation: 0,
    contentPadding: EdgeInsets.zero,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    content: SizedBox(width: 90.w, child: content),
  );

  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void showSnackbar(String text, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

///the file must be inside assets/executables folder,
///example: getExecutablePathForAssetFile('program.exe');
Future<String> getExecutablePathForAssetFile(String fileName) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  ByteData data = await rootBundle.load('assets/executables/$fileName');
  List<int> bytes = data.buffer.asUint8List();
  File executableFile = File('$tempPath\\$fileName');
  await executableFile.writeAsBytes(bytes);
  return executableFile.path;
}

Future<void> restartAsAdministrator() async {
  final programPath = Platform.resolvedExecutable;

  final executablePath = await getExecutablePathForAssetFile("run_as_admin.bat");
  ProcessResult result = await Process.run('cmd', ['/c', executablePath, programPath]);

  // Check the result
  if (result.exitCode == 0) {
    exit(0);
  } else {
    print('Error: ${result.stderr}');
  }
}

extension FancyNum on num {
  String toSize({decimals = 2, addSpace = false}) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (this == 0) return '0${addSpace ? ' ' : ''}${suffixes[0]}';
    var i = (log(this) / log(1024)).floor();
    return "${(this / pow(1024, i)).toStringAsFixed(decimals)}${addSpace ? ' ' : ''}${suffixes[i]}";
  }

  ///convert int to double, or return double if it's already double
  double forceDouble() {
    return this + .0;
  }
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
              showIcon ? (customIcon ?? Icon(icon, size: 25, color: colorTitle ? Theme.of(context).primaryColor : null)) : Container(),
              SizedBox(width: 2.w),
              SelectableText(title,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: colorTitle ? Theme.of(context).primaryColor : null, fontWeight: FontWeight.bold)),
              suffixIcon ?? Container(),
            ],
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(top: paddingHeight / 2, bottom: paddingHeight / 2),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
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

Future<void> showInformationDialog(String? title, String message, BuildContext context) async {
  AlertDialog alert = AlertDialog(
    backgroundColor: Theme.of(context).primaryColorDark,
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

/// Stores tokens using a Hive store.
/// Depends on the Hive plugin: https://pub.dev/packages/hive
class HiveStore extends TokenStore {
  static const keyToken = "auth_token";

  static Future<HiveStore> create() async {
    final path = await getTemporaryDirectory();
    try {
      Hive.init(path.path);
      Hive.registerAdapter(TokenAdapter());
    } catch (c) {}

    var box = await Hive.openBox(keyToken, compactionStrategy: (entries, deletedEntries) => deletedEntries > 50);
    return HiveStore(box);
  }

  final Box _box;

  HiveStore(this._box);

  @override
  Token? read() {
    final a = _box.get(keyToken);
    return a;
  }

  @override
  void write(Token? token) => _box.put(keyToken, token);

  @override
  void delete() => _box.delete(keyToken);
}

class TokenAdapter extends TypeAdapter<Token> {
  @override
  final typeId = 42;

  @override
  void write(BinaryWriter writer, Token token) => writer.writeMap(token.toMap());

  @override
  Token read(BinaryReader reader) => Token.fromMap(reader.readMap().map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, value)));
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

String truncateString(String text, length) {
  return (text.length <= length) ? text : '${text.substring(0, length)}...';
}
