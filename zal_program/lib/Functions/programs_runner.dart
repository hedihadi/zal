import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ProgramsRunner {
  static Future<void> downloadAndOpenInstaller() async {
    late String filePath;
    filePath = "${(await getTemporaryDirectory()).path}\\zal-update.msi";

    var response = await http.get(Uri.parse(dotenv.env['PROGRAM_URL']!));
    if (response.statusCode == 200) {
      var file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      Process.run('msiexec', ['/i', filePath]);
    }
  }

  static Future<void> openFileFromPath(String path) async {
    Process.run('start', ['notepad.exe', path], runInShell: true);
  }

  static Future<void> runServer() async {
    await Process.run('taskkill', ['/F', '/IM', 'zal-server.exe']);

    final assetsFolder = getAssetsFolder();
    final serverFilePath = "${assetsFolder}executables\\zal-server.exe";
    Process.run(serverFilePath, [' start ']);
  }

  static Future<void> runZalConsole(bool runAsAdmin) async {
    await Process.run('taskkill', ['/F', '/IM', 'zal-console.exe']);
    final assetsFolder = getAssetsFolder();
    final filePath = "${assetsFolder}executables\\zal-console\\zal-console.exe";
    Process.run(filePath, [runAsAdmin ? '1' : '0']);
  }

  static String getAssetsFolder() {
    final filePath = Platform.resolvedExecutable;
    int lastIndex = filePath.lastIndexOf('\\'); // Find the index of the last backslash
    String result = filePath.substring(0, lastIndex + 1); // Extract substring up to the last backslash (inclusive)
    result = "${result}data\\flutter_assets\\assets\\";
    return result;
  }
}
