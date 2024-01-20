import 'dart:convert';

import 'package:firedart/generated/google/protobuf/timestamp.pb.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum StreamDataType { FPS, DATA }

enum WebrtcDataType {
  restartAdmin,
  changePrimaryNetwork,
  newNotification,
  editNotification,
  killProcess,
}


enum NewNotificationKey { Gpu, Cpu, Ram, Storage, Network }

enum NewNotificationFactorType { Higher, Lower }

class WebrtcData {
  WebrtcDataType type;
  String data;
  WebrtcData({
    required this.data,
    required this.type,
  });
}

class WebrtcProviderModel {
  final bool isConnected;
  final WebrtcData? data;

  WebrtcProviderModel({
    required this.isConnected,
    this.data,
  });
}

class WebrtcConnectionModel {
  final bool isConnected;
  WebrtcConnectionModel({
    required this.isConnected,
  });
}

class NotificationWithTimestamp {
  final String id;
  final NotificationData notification;
  Timestamp lastCheck;
  bool flipflop;
  NotificationWithTimestamp({
    required this.id,
    required this.notification,
    required this.lastCheck,
    required this.flipflop,
  });
  int getElpasedTime() {
    return (Timestamp.fromDateTime(DateTime.now()).seconds - lastCheck.seconds).toInt();
  }
}

///used for creating new notification, this object holds the key's children with the unit of measurement.
class NotificationKeyWithUnit {
  String keyName;
  String unit;

  ///if [displayName] isn't null, it'll be shown instead of keyName.
  String? displayName;
  NotificationKeyWithUnit({required this.keyName, required this.unit, this.displayName});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationKeyWithUnit && other.keyName == keyName && other.unit == unit;
  }

  @override
  int get hashCode => keyName.hashCode ^ unit.hashCode;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'keyName': keyName});
    result.addAll({'unit': unit});
    result.addAll({'displayName': displayName});

    return result;
  }

  factory NotificationKeyWithUnit.fromMap(Map<String, dynamic> map) {
    return NotificationKeyWithUnit(
      keyName: map['keyName'] ?? '',
      unit: map['unit'] ?? '',
      displayName: map['displayName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationKeyWithUnit.fromJson(String source) => NotificationKeyWithUnit.fromMap(json.decode(source));
}

///this model is used for creating a new notification
class NotificationData {
  final NewNotificationKey key;
  final NotificationKeyWithUnit childKey;
  final NewNotificationFactorType factorType;
  final double factorValue;
  final int secondsThreshold;
  final bool suspended;
  NotificationData({
    required this.key,
    required this.childKey,
    required this.factorType,
    required this.factorValue,
    required this.secondsThreshold,
    required this.suspended,
  });

  NotificationData copyWith({
    NewNotificationKey? key,
    NotificationKeyWithUnit? childKey,
    NewNotificationFactorType? factorType,
    double? factorValue,
    int? secondsThreshold,
    bool? suspended,
  }) {
    return NotificationData(
      key: key ?? this.key,
      childKey: childKey ?? this.childKey,
      factorType: factorType ?? this.factorType,
      factorValue: factorValue ?? this.factorValue,
      secondsThreshold: secondsThreshold ?? this.secondsThreshold,
      suspended: suspended ?? this.suspended,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'key': key.name.toString()});
    result.addAll({'childKey': childKey.toMap()});
    result.addAll({'factorType': factorType.name.toString()});
    result.addAll({'factorValue': factorValue});
    result.addAll({'secondsThreshold': secondsThreshold});
    result.addAll({'suspended': suspended});

    return result;
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      key: NewNotificationKey.values.byName(map['key']),
      childKey: NotificationKeyWithUnit.fromMap(map['childKey']),
      factorType: NewNotificationFactorType.values.byName(map['factorType']),
      factorValue: double.parse(map['factorValue'].toString()),
      secondsThreshold: map['secondsThreshold']?.toInt(),
      suspended: map['suspended'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationData.fromJson(String source) => NotificationData.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationData &&
        other.key == key &&
        other.childKey == childKey &&
        other.factorType == factorType &&
        other.factorValue == factorValue &&
        other.secondsThreshold == secondsThreshold;
  }

  @override
  int get hashCode {
    return key.hashCode ^ childKey.hashCode ^ factorType.hashCode ^ factorValue.hashCode ^ secondsThreshold.hashCode ^ suspended.hashCode;
  }
}



class LocalSocketio {
  late Socket socket;
  LocalSocketio() {
    socket = io(
      'http://localhost:3000/',
      <String, dynamic>{
        'transports': ['websocket'],
        'query': {
          'EIO': '3',
        },
      },
    );

    //socket.onAny((event, data) => print(event));
  }

  // sendData(String to, String data) {
  //   socket.emit(to, {'data': data});
  // }
}

class ServerSocketio {
  late Socket socket;
  ServerSocketio(String uid, String idToken, String computerName) {
    socket = io(
      dotenv.env['SERVER'] == 'production' ? 'https://api.zalapp.com' : 'http://192.168.1.104:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'query': {
          'EIO': '3',
          'uid': uid,
          'idToken': idToken,
          'type': 0,
          'version': 1,
          'computerName': computerName,
        },
      },
    );
  }

  // sendData(String to, String data) {
  //   socket.emit(to, {'data': data});
  // }
}

class ServerSocketData {
  final bool isConnected;
  final bool isMobileConnected;
  ServerSocketData({
    required this.isConnected,
    required this.isMobileConnected,
  });
}

class StreamData {
  StreamDataType type;
  dynamic data;
  StreamData({
    required this.type,
    required this.data,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StreamData && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class ProcessData {
  int id;
  String name;
  ProcessData({
    required this.id,
    required this.name,
  });
}

class FpsDetails {
  final double averageFps;
  final double fps01Low;
  final double fps001Low;
  FpsDetails({
    required this.averageFps,
    required this.fps01Low,
    required this.fps001Low,
  });
}

class FpsData {
  final String processName;
  final int fps;
  final int processId;
  FpsData({
    required this.processName,
    required this.fps,
    required this.processId,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'processName': processName});
    result.addAll({'fps': fps});
    result.addAll({'processId': processId});

    return result;
  }

  factory FpsData.fromMap(Map<String, dynamic> map) {
    return FpsData(
      processName: map['processName'] ?? '',
      fps: (1000 / map['msBetweenPresents']).round(),
      processId: map['processId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FpsData.fromJson(String source) => FpsData.fromMap(json.decode(source));
}

class Settings {
  final String computerName;
  final bool personalizedAds;
  final bool useCelcius;
  final bool sendAnalaytics;
  final String? primaryGpuName;
  final bool runOnStartup;
  final bool startMinimized;
  final bool runInBackground;
  final bool runAsAdmin;
  Settings({
    required this.computerName,
    required this.personalizedAds,
    required this.useCelcius,
    required this.sendAnalaytics,
    this.primaryGpuName,
    required this.runOnStartup,
    required this.startMinimized,
    required this.runInBackground,
    required this.runAsAdmin,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'computerName': computerName});

    result.addAll({'personalizedAds': personalizedAds});
    result.addAll({'useCelcius': useCelcius});
    result.addAll({'sendAnalaytics': sendAnalaytics});
    if (primaryGpuName != null) {
      result.addAll({'primaryGpuName': primaryGpuName});
    }
    result.addAll({'runOnStartup': runOnStartup});
    result.addAll({'startMinimized': startMinimized});
    result.addAll({'runInBackground': runInBackground});
    result.addAll({'runAsAdmin': runAsAdmin});

    return result;
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      computerName: map['computerName'] ?? 'Personal PC',
      personalizedAds: map['personalizedAds'] ?? false,
      useCelcius: map['useCelcius'] ?? true,
      sendAnalaytics: map['sendAnalaytics'] ?? false,
      primaryGpuName: map['primaryGpuName'],
      runOnStartup: map['runOnStartup'] ?? true,
      startMinimized: map['startMinimized'] ?? true,
      runInBackground: map['runInBackground'] ?? true,
      runAsAdmin: map['runAsAdmin'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Settings.fromJson(String source) => Settings.fromMap(json.decode(source));

  Settings copyWith({
    String? computerName,
    bool? personalizedAds,
    bool? useCelcius,
    bool? sendAnalaytics,
    String? primaryGpuName,
    bool? runOnStartup,
    bool? startMinimized,
    bool? runInBackground,
    bool? runAsAdmin,
  }) {
    return Settings(
      computerName: computerName ?? this.computerName,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      useCelcius: useCelcius ?? this.useCelcius,
      sendAnalaytics: sendAnalaytics ?? this.sendAnalaytics,
      primaryGpuName: primaryGpuName ?? this.primaryGpuName,
      runOnStartup: runOnStartup ?? this.runOnStartup,
      startMinimized: startMinimized ?? this.startMinimized,
      runInBackground: runInBackground ?? this.runInBackground,
      runAsAdmin: runAsAdmin ?? this.runAsAdmin,
    );
  }

  factory Settings.defaultSettings() {
    return Settings.fromMap({});
  }
}
