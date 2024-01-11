import 'package:firedart/generated/google/protobuf/timestamp.pb.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/Models/computer_data_models.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/analytics_manager.dart';
import 'package:zal/Functions/local_database_manager.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/providers/local_socket_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_stream_provider.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationData>> {
  NotificationsNotifier();

  ///this variable holds the timestamps for the notification keys. we use this to keep track of the tresholds.
  List<NotificationWithTimestamp> notificationTimestamps = [];
  @override
  Future<List<NotificationData>> build() async {
    final notifications = await LocalDatabaseManager.loadNotifications();
    Future.delayed(const Duration(milliseconds: 500), () => setBasicNotifications());
    if (notifications != null) return notifications;

    return [];
  }

  Future<void> setBasicNotifications() async {
    final isFirstRun = await LocalDatabaseManager.loadIsFirstRun();
    if (isFirstRun) {
      addNewNotification(
        NotificationData(
          key: NewNotificationKey.Cpu,
          childKey: NotificationKeyWithUnit(keyName: 'temperature', unit: 'C'),
          factorType: NewNotificationFactorType.Higher,
          factorValue: 65,
          secondsThreshold: 5,
          suspended: false,
        ),
      );
      addNewNotification(
        NotificationData(
          key: NewNotificationKey.Gpu,
          childKey: NotificationKeyWithUnit(keyName: 'temperature', unit: 'C'),
          factorType: NewNotificationFactorType.Higher,
          factorValue: 65,
          secondsThreshold: 5,
          suspended: false,
        ),
      );
      addNewNotification(
        NotificationData(
          key: NewNotificationKey.Ram,
          childKey: NotificationKeyWithUnit(keyName: 'memoryUsedPercentage', unit: '%'),
          factorType: NewNotificationFactorType.Higher,
          factorValue: 95,
          secondsThreshold: 5,
          suspended: false,
        ),
      );
      await LocalDatabaseManager.saveIsFirstRun();
    }
  }

  Future<void> checkNotifications(ComputerData data) async {
    final notifications = state.valueOrNull;
    if (notifications == null) return;

    for (final notification in notifications) {
      if (notification.suspended) continue;
      double? currentValue;
      String? id;

      ///each hardware has their own structure, so we have to get [currentValue] and [id] for each hardware in different ways.
      if (notification.key == NewNotificationKey.Gpu) {
        id = 'gpuData.${notification.childKey.keyName}';

        final primaryGpu = ref.read(localSocketProvider.notifier).getPrimaryGpu();
        if (primaryGpu == null) continue;
        currentValue = ((List<dynamic>.from(data.parsedData['gpuData']))
                .firstWhere((element) => element['name'] == primaryGpu.name)[notification.childKey.keyName] as int)
            .forceDouble();
      } else if (notification.key == NewNotificationKey.Cpu) {
        id = 'cpuData.${notification.childKey.keyName}';
        currentValue = (data.parsedData['cpuData'][notification.childKey.keyName] as int).forceDouble();
      } else if (notification.key == NewNotificationKey.Ram) {
        id = 'ramData.${notification.childKey.keyName}';
        currentValue = (data.parsedData['ramData'][notification.childKey.keyName] as int).forceDouble();
      } else if (notification.key == NewNotificationKey.Storage) {
        id = 'storagesData.${notification.childKey.keyName}';
        currentValue = ((List<dynamic>.from(data.parsedData['storagesData']))
                .firstWhere((element) => element['diskNumber'] == int.parse(notification.childKey.keyName))['temperature'] as int)
            .forceDouble();
      } else if (notification.key == NewNotificationKey.Network) {
        final keyName = notification.childKey.keyName;
        id = 'networkData.$keyName';
        if (keyName == "totalUpload") {
          currentValue =
              bytesToGB((List<dynamic>.from(data.parsedData['networkInterfaces'])).firstWhere((element) => element['isPrimary'] == true)['bytesSent'])
                  .forceDouble();
        } else if (keyName == "totalDownload") {
          currentValue = bytesToGB(
                  (List<dynamic>.from(data.parsedData['networkInterfaces'])).firstWhere((element) => element['isPrimary'] == true)['bytesReceived'])
              .forceDouble();
        } else if (keyName == "downloadSpeed") {
          currentValue = bytesToMB(data.parsedData['primaryNetworkSpeed']['download']).forceDouble();
        } else if (keyName == "uploadSpeed") {
          currentValue = bytesToMB(data.parsedData['primaryNetworkSpeed']['upload']).forceDouble();
        }
      }

      if ([currentValue, id].contains(null)) {
        throw Exception("failed to find notification id or value");
      }
      final notificationWithTimestamp = notificationTimestamps.where((element) => element.id == id).firstOrNull;
      if (notificationWithTimestamp == null) {
        notificationTimestamps
            .add(NotificationWithTimestamp(id: id!, notification: notification, lastCheck: Timestamp.fromDateTime(DateTime.now()), flipflop: false));
        continue;
      }

      ///if [isDataAboveValue] is true, that means we theoretically should send the notification
      bool isDataAboveValue = false;

      ///determining [isDataAboveValue]
      if (notification.factorType == NewNotificationFactorType.Higher) {
        if (currentValue! > notification.factorValue) isDataAboveValue = true;
      } else {
        if (currentValue! < notification.factorValue) isDataAboveValue = true;
      }
      if (isDataAboveValue) {
        if (notificationWithTimestamp.getElpasedTime() > notification.secondsThreshold && notificationWithTimestamp.flipflop == false) {
          AnalyticsManager.sendAlertToMobile(notification, currentValue);
          notificationTimestamps[notificationTimestamps.indexWhere((element) => element.id == id)].flipflop = true;
        }
      } else {
        notificationTimestamps[notificationTimestamps.indexWhere((element) => element.id == id)].lastCheck = Timestamp.fromDateTime(DateTime.now());
        notificationTimestamps[notificationTimestamps.indexWhere((element) => element.id == id)].flipflop = false;
      }
    }
  }

  double bytesToGB(int bytes) {
    const int gigabyte = 1024 * 1024 * 1024;
    return bytes / gigabyte;
  }

  double bytesToMB(int bytes) {
    const int gigabyte = 1024 * 1024;
    return bytes / gigabyte;
  }

  addNewRawNotification(String rawNotification) {
    final notification = NotificationData.fromJson(rawNotification);
    addNewNotification(notification);
  }

  addNewNotification(NotificationData notification) {
    state = AsyncData([...state.value!, notification]);
    LocalDatabaseManager.saveNotifications(state.value!);
    broadcastNotificationsToMobile();
  }

  editNotification(Map<String, dynamic> data) {
    NotificationData notification = NotificationData.fromJson(data['notification']);
    String type = data['type'];
    if (state.value == null) return;
    if (type == 'delete') {
      state = AsyncData(state.value!.where((element) => element != notification).toList());
      LocalDatabaseManager.saveNotifications(state.value!);
      notificationTimestamps = notificationTimestamps.where((element) => element.notification != notification).toList();
    } else if (type == 'suspend') {
      List<NotificationData> notifications = state.value!.where((element) => element != notification).toList();
      notifications.add(notification.copyWith(suspended: true));
      state = AsyncData(notifications);
      LocalDatabaseManager.saveNotifications(state.value!);
    } else if (type == 'unsuspend') {
      List<NotificationData> notifications = state.value!.where((element) => element != notification).toList();
      notifications.add(notification.copyWith(suspended: false));
      state = AsyncData(notifications);
      LocalDatabaseManager.saveNotifications(state.value!);
    }
    broadcastNotificationsToMobile();
  }

  broadcastNotificationsToMobile() async {
    //keep trying until you send notifications to the phone.
    while (true) {
      if (ref.read(serverSocketObjectProvider).valueOrNull != null && state.value != null) {
        ref.read(serverSocketObjectProvider).valueOrNull?.socket.emit('notifications', {'data': state.value!.map((e) => e.toJson()).toList()});
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<NotificationData>>(() {
  return NotificationsNotifier();
});
