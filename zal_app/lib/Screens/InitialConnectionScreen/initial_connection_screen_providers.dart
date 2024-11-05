import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/SettingsScreen/settings_providers.dart';
import 'package:http/http.dart' as http;

final isConnectedToServerProvider = StateProvider<bool>((ref) => false);
final loadedComputerAddressesProvider = StateProvider<List<ComputerAddress>>((ref) => []);
final networkPrefixProvider = FutureProvider<String?>((ref) async {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings?['networkPrefix'] != null) {
    return settings!['networkPrefix'];
  }
  final address = await getLocalIpAddress();
  return address;
});

final localcomputerAddressesProvider = FutureProvider<List<ComputerAddress>?>((ref) async {
  ref.invalidate(loadedComputerAddressesProvider);
  final settings = ref.watch(settingsProvider);
  final networkPrefix = ref.watch(networkPrefixProvider);
  if (networkPrefix.isLoading || settings.isLoading) return null;
  if (networkPrefix.valueOrNull == null) throw NetworkPrefixIsNull();
  final List<ComputerAddress> result = [];

  final List<Future<ComputerAddress?>> futures = [];
  for (int i = 0; i < 255; i++) {
    final future = Future.delayed(const Duration(seconds: 0), () async {
      try {
        final port = settings.valueOrNull?['port'] ?? '4920';
        final ip = "http://${networkPrefix.valueOrNull}.$i:$port";
        final response = await http.get(Uri.parse(ip)).timeout(const Duration(seconds: 1));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['server'] == 'Zal') {
            ref.read(loadedComputerAddressesProvider.notifier).state = [
              ...ref.read(loadedComputerAddressesProvider),
              ComputerAddress(name: data['name'], ip: ip)
            ];
            return;
          }
        }
        return null;
      } catch (c) {
        return null;
      }
    });
    futures.add(future);
  }
  for (final future in futures) {
    final response = await future;
    if (response != null) {
      result.add(response);
    }
  }
  return result;
});
