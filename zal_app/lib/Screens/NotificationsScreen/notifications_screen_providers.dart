import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/Providers/computer_data_provider.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';

class NewNotificationsDataNotifier extends StateNotifier<NotificationData> {
  AutoDisposeStateNotifierProviderRef<NewNotificationsDataNotifier, NotificationData> ref;

  NewNotificationsDataNotifier(this.ref) : super(NotificationData(factorType: NewNotificationFactorType.Higher, secondsThreshold: 10));
  setKey(NewNotificationKey newKey) {
    state = state.copyWith(key: newKey, childKey: null);
  }

  setChildKey(NotificationKeyWithUnit childKey) {
    state = state.copyWith(childKey: childKey);
  }

  setFactorType(NewNotificationFactorType factorType) {
    state = state.copyWith(factorType: factorType);
  }

  setFactorValue(String factorValue) {
    final parsedDouble = double.tryParse(factorValue);
    if (parsedDouble == null) return;
    state = state.copyWith(factorValue: parsedDouble);
  }

  setSecondsThreshold(int secondsThreshold) {
    state = state.copyWith(secondsThreshold: secondsThreshold);
  }

  List<NotificationKeyWithUnit> getChildrenForSelectedKey() {
    final parsedData = ref.read(computerDataProvider).valueOrNull?.rawData;
    final computerData = ref.read(computerDataProvider).valueOrNull;
    final isCelcius = ref.read(settingsProvider).valueOrNull?['useCelcius'] ?? true;
    if (parsedData == null) return [];
    if (state.key == NewNotificationKey.Gpu) {
      final primaryGpu = ref.read(primaryGpuProvider);
      if (primaryGpu == null) return [];
      List<NotificationKeyWithUnit> notificationKeys = [];
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'temperature', unit: isCelcius ? 'C' : 'F'));

      notificationKeys.add(NotificationKeyWithUnit(keyName: 'corePercentage', unit: '%'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'fanSpeedPercentage', unit: "%"));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'power', unit: 'W'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'coreSpeed', unit: 'MHz'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'memorySpeed', unit: 'MHz'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'voltage', unit: 'V'));

      return notificationKeys;
    } else if (state.key == NewNotificationKey.Cpu) {
      List<NotificationKeyWithUnit> notificationKeys = [];
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'temperature', unit: isCelcius ? 'C' : 'F'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'load', unit: '%'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'power', unit: 'W'));

      return notificationKeys;
    } else if (state.key == NewNotificationKey.Ram) {
      List<NotificationKeyWithUnit> notificationKeys = [];
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'memoryUsedPercentage', unit: '%'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'memoryUsed', unit: 'GB'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'memoryAvailable', unit: 'GB'));

      return notificationKeys;
    } else if (state.key == NewNotificationKey.Network) {
      List<NotificationKeyWithUnit> notificationKeys = [];
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'totalUpload', unit: 'GB'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'totalDownload', unit: 'GB'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'downloadSpeed', unit: 'MB/s'));
      notificationKeys.add(NotificationKeyWithUnit(keyName: 'uploadSpeed', unit: 'MB/s'));

      return notificationKeys;
    } else if (state.key == NewNotificationKey.Storage) {
      List<NotificationKeyWithUnit> notificationKeys = [];
      for (final Storage storage in computerData?.storages ?? []) {
        notificationKeys.add(NotificationKeyWithUnit(
            keyName: "${storage.diskNumber}", displayName: "(${storage.getDisplayName()}) temperature", unit: isCelcius ? 'C' : 'F'));
      }

      return notificationKeys;
    }
    return [];
  }
}

final newNotificationDataProvider = StateNotifierProvider.autoDispose<NewNotificationsDataNotifier, NotificationData>((ref) {
  return NewNotificationsDataNotifier(ref);
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationData>> {
  NotificationsNotifier();

  @override
  Future<List<NotificationData>> build() async {
    final data = await ref.watch(_notificationsDataProvider.future);
    final parsedData = jsonDecode(data.data);
    List<NotificationData> notifications = [];
    for (final rawNotification in parsedData) {
      notifications.add(NotificationData.fromJson(rawNotification));
    }
    return notifications;
  }

  ///this function is used as a fake effect to delete notifications.
  ///because the notifications are saved on the computer app, we have to
  ///send data to the computer, the computer deletes the notification and sends the data back.
  ///so we delete the notification from showing up on the phone and send data to the computer to delete the notification.
  deleteNotification(NotificationData notification) {
    state = AsyncData(state.value!.where((element) => element.key != notification.key).toList());
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<NotificationData>>(() {
  return NotificationsNotifier();
});

///this provider only updates if the data type is [StreamDataType.Notifications]
final _notificationsDataProvider = FutureProvider<WebrtcData>((ref) {
  final sub = ref.listen(webrtcProvider, (prev, cur) {
    if (cur.data?.type == WebrtcDataType.notifications) {
      ref.state = AsyncData(cur.data!);
    } else {}
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
