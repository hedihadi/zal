import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:color_print/color_print.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:zal/Functions/utils.dart';

enum AmdOrNvidia { amd, nvidia }

enum RyzenOrIntel { ryzen, intel }

enum ProgramTimesTimeframe { today, yesterday }

enum StorageType { SSD, HDD }

enum stressTestType { Ram, Cpu, Gpu }

enum SortBy { Name, Memory, Cpu }

enum DataType { Hardwares, TaskManager }

enum StreamDataType { RoomClients }

enum WebrtcDataType {
  pcData,
  notifications,
  drives,
  directory,
  file,
  informationText,
  fileComplete,
  gpuProcesses,
  fpsData,
  processIcon,
  runningProcesses
}

enum NewNotificationKey { Gpu, Cpu, Ram, Storage, Network }

enum NewNotificationFactorType { Higher, Lower }

enum FileType { file, folder }

enum FileProviderState { downloading, rebuilding, complete }

enum MoveFileType { move, copy }

enum SortFilesBy {
  nameAscending,
  nameDescending,
  sizeAscending,
  sizeDescending,
  dateModifiedAscending,
  dateModifiedDescending,
  dateCreatedAscending,
  dateCreatedDescending,
}

class GpuProcess {
  final int pid;
  final String? icon;
  final int usage;
  final String name;
  GpuProcess({
    required this.pid,
    required this.icon,
    required this.usage,
    required this.name,
  });

  factory GpuProcess.fromMap(MapEntry<String, dynamic> map) {
    return GpuProcess(
      pid: map.value['pid']?.toInt() ?? 0,
      icon: (map.value['icon'] as String?),
      usage: map.value['usage']?.toInt() ?? 0,
      name: map.key,
    );
  }

  factory GpuProcess.fromJson(String source) => GpuProcess.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GpuProcess && other.pid == pid;
  }

  @override
  int get hashCode {
    return pid.hashCode ^ icon.hashCode ^ usage.hashCode ^ name.hashCode;
  }
}

class MoveFileModel {
  final FileData file;
  final MoveFileType moveType;
  MoveFileModel({
    required this.file,
    required this.moveType,
  });
}

class FileProviderModel {
  FileData? file;
  int lastBiggestByte;
  FileProviderState fileProviderState;
  FileProviderModel({
    required this.file,
    required this.lastBiggestByte,
    required this.fileProviderState,
  });

  FileProviderModel copyWith({
    FileData? file,
    int? lastBiggestByte,
    FileProviderState? fileProviderState,
  }) {
    return FileProviderModel(
      file: file ?? this.file,
      lastBiggestByte: lastBiggestByte ?? this.lastBiggestByte,
      fileProviderState: fileProviderState ?? this.fileProviderState,
    );
  }
}

class FileData {
  final String name;

  final String? extension;
  final String directory;

  ///in bytes
  final int size;
  FileType fileType;
  final DateTime dateCreated;
  final DateTime dateModified;
  FileData({
    required this.name,
    this.extension,
    required this.directory,
    required this.size,
    required this.fileType,
    required this.dateCreated,
    required this.dateModified,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    if (extension != null) {
      result.addAll({'extension': extension});
    }
    result.addAll({'directory': directory});
    result.addAll({'size': size});
    result.addAll({'fileType': fileType.name});
    result.addAll({'dateCreated': dateCreated.millisecondsSinceEpoch});
    result.addAll({'dateModified': dateModified.millisecondsSinceEpoch});

    return result;
  }

  factory FileData.fromMap(Map<String, dynamic> map) {
    return FileData(
      name: map['name'] ?? '',
      extension: map['extension'],
      directory: map['directory'] ?? '',
      size: map['size']?.toInt() ?? 0,
      fileType: FileType.values.byName(map['fileType']),
      dateCreated: map['dateCreated'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateCreated']) : DateTime.fromMillisecondsSinceEpoch(0),
      dateModified: map['dateModified'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateModified']) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String toJson() => json.encode(toMap());

  factory FileData.fromJson(String source) => FileData.fromMap(json.decode(source));
}

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
    if (displayName != null) {
      result.addAll({'displayName': displayName});
    }

    return result;
  }

  factory NotificationKeyWithUnit.fromMap(Map<String, dynamic> map) {
    return NotificationKeyWithUnit(
      keyName: map['keyName'] ?? '',
      unit: map['unit'] ?? '',
      displayName: map['displayName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationKeyWithUnit.fromJson(String source) => NotificationKeyWithUnit.fromMap(json.decode(source));
}

///this model is used for creating a new notification
class NotificationData {
  final NewNotificationKey? key;
  final NotificationKeyWithUnit? childKey;
  final NewNotificationFactorType? factorType;
  final double? factorValue;
  final int? secondsThreshold;
  bool suspended;
  NotificationData({
    this.key,
    this.childKey,
    this.factorType,
    this.factorValue,
    this.secondsThreshold,
    this.suspended = false,
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

    if (key != null) {
      result.addAll({'key': key!.name.toString()});
    }
    if (childKey != null) {
      result.addAll({'childKey': childKey!.toMap()});
    }
    if (factorType != null) {
      result.addAll({'factorType': factorType!.name.toString()});
    }
    if (factorValue != null) {
      result.addAll({'factorValue': factorValue});
    }
    if (secondsThreshold != null) {
      result.addAll({'secondsThreshold': secondsThreshold});
    }
    result.addAll({'suspended': suspended});
    return result;
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      key: map['key'] != null ? NewNotificationKey.values.byName(map['key']) : null,
      childKey: map['childKey'] != null ? NotificationKeyWithUnit.fromMap(map['childKey']) : null,
      factorType: map['factorType'] != null ? NewNotificationFactorType.values.byName(map['factorType']) : null,
      factorValue: double.parse(map['factorValue'].toString()),
      secondsThreshold: map['secondsThreshold']?.toInt(),
      suspended: map['suspended'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationData.fromJson(String source) => NotificationData.fromMap(json.decode(source));
}

///this is solely used in home_screen for gpus widget
class ComputerDataWithBuildContext {
  final ComputerData computerData;
  final BuildContext context;
  ComputerDataWithBuildContext({
    required this.computerData,
    required this.context,
  });
}

class StreamData {
  StreamDataType type;
  dynamic data;
  StreamData({
    required this.type,
    required this.data,
  });
}

class FpsData {
  List<double> fpsList;
  double currentFps;
  double averageFps;
  double fps01Low;
  double fps001Low;

  calculateFps() {
    final sortedFps = List<double>.from(fpsList);
    sortedFps.sort((a, b) => a.compareTo(b));
    fps01Low = calculatePercentile(sortedFps, 0.01).toPrecision(2);
    fps001Low = calculatePercentile(sortedFps, 0.001).toPrecision(2);
    double totalFPS = sortedFps.reduce((a, b) => a + b);
    averageFps = totalFPS / fpsList.length;
  }

  addFps(double fps) {
    fpsList.add(fps);
  }

  double calculatePercentile(List<double> data, double percentile) {
    double realIndex = (percentile) * (data.length - 1);
    int index = realIndex.toInt();
    double frac = realIndex - index;
    if (index + 1 < data.length) {
      return data[index] * (1 - frac) + data[index + 1] * frac;
    } else {
      return data[index];
    }
  }

  FpsData({
    required this.fpsList,
    required this.currentFps,
    required this.fps01Low,
    required this.fps001Low,
    required this.averageFps,
  });

  FpsData copyWith({
    List<double>? fpsList,
    double? currentFps,
    double? averageFps,
    double? fps01Low,
    double? fps001Low,
    DateTime? date,
  }) {
    return FpsData(
      fpsList: fpsList ?? this.fpsList,
      currentFps: currentFps ?? this.currentFps,
      averageFps: averageFps ?? this.averageFps,
      fps01Low: fps01Low ?? this.fps01Low,
      fps001Low: fps001Low ?? this.fps001Low,
    );
  }
}

///used to keep track of highest values in fps screen
class FpsComputerData {
  final ComputerData computerData;
  final Map<String, num> highestValues;
  FpsComputerData({
    required this.computerData,
    required this.highestValues,
  });
}

class FpsRecord {
  FpsData fpsData;
  String presetName;

  ///how long the fps was running, in formatted text.
  String presetDuration;
  String? note;

  FpsRecord({
    required this.fpsData,
    required this.presetName,
    required this.presetDuration,
    this.note,
  });
}

///a class that contains fps and time, this is used to represent fps data on a line chart.
class FpsTime {
  double fps;
  DateTime time;
  FpsTime({
    required this.fps,
    required this.time,
  });
}

class ProgramTimeScreenData {
  Map<DateTime, int> dates;
  int totalYear;
  ProgramTimeScreenData({
    required this.dates,
    required this.totalYear,
  });

  factory ProgramTimeScreenData.fromMap(Map<String, dynamic> map) {
    Map<DateTime, int> result = {};
    for (final data in map['dates'].entries) {
      DateTime dateTime = DateFormat("yyyy-MM-dd").parse(data.key);
      result[dateTime] = data.value;
    }
    return ProgramTimeScreenData(
      dates: result,
      totalYear: map['total_year']?.toInt() ?? 0,
    );
  }

  factory ProgramTimeScreenData.fromJson(String source) => ProgramTimeScreenData.fromMap(json.decode(source));
}

class ProgramTime {
  final String name;
  final int minutes;
  ProgramTime({
    required this.name,
    required this.minutes,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'total_minutes': minutes});

    return result;
  }

  factory ProgramTime.fromMap(Map<String, dynamic> map) {
    return ProgramTime(
      name: map['name'] ?? '',
      minutes: map['minutes'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProgramTime.fromJson(String source) => ProgramTime.fromMap(json.decode(source));
}

class SocketObject {
  late Socket socket;
  Timer? timer;
  SocketObject(String uid, String idToken) {
    socket = io(
      dotenv.env['SERVER'] == 'production' ? 'https://api.zalapp.com' : 'http://192.168.0.120:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'query': {
          'EIO': '3',
          'uid': uid,
          'idToken': idToken,
          'type': 1,
          'version': 1,
        },
      },
    );

    socket.on('connection', (_) {
      print('connect ${_.toString()}');
    });
    socket.on('connect_error', (a) {
      print('error $a');
    });
    socket.onConnect((_) {
      //join the room
      // joinRoom();
      //send a keep_alive event so the pc starts sending data
      //socket.emit("keep_alive", "");
    });

    //send keep_alive event every 9 seconds so the computer's socket won't go into sleep mode
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      //socket.emit("keep_alive", "");
    });
  }

  sendData(String to, String data) {
    socket.emit(to, {'data': data});
  }

  // initiateTaskmanager() {
  //   if (timer != null) {
  //     socket.emit("taskmanager_keep_alive", "hi");
  //     timer = Timer.periodic(Duration(seconds: 9), (Timer t) {
  //       socket.emit("taskmanager_keep_alive", "hi");
  //     });
  //   }
  // }
}

class Cpu {
  /// name of the cpu
  String name;

  /// in celcious
  double? temperature;

  /// power in watts
  double power;

  /// watts used by each core
  SplayTreeMap<String, double> powers = SplayTreeMap();

  /// clock speed in mhz for each core
  SplayTreeMap<String, double?> clocks = SplayTreeMap();

  /// overall load of the cpu in percentage;
  double load;

  /// load percentage of each core
  SplayTreeMap<String, double> loads = SplayTreeMap();

  /// voltage of each core
  SplayTreeMap<String, double> voltages = SplayTreeMap();

  //static information about the cpu
  CpuInfo? cpuInfo;
  Cpu({
    required this.name,
    required this.temperature,
    required this.power,
    required this.powers,
    required this.clocks,
    required this.load,
    required this.loads,
    required this.voltages,
    required this.cpuInfo,
  });

  factory Cpu.fromMap(Map<String, dynamic> map) {
    SplayTreeMap<String, double?> clocks = SplayTreeMap<String, double?>();
    for (final clock in Map<String, dynamic>.from(map['clocks']).entries) {
      if (clock.value == "NaN") {
        clocks[clock.key] = null;
      } else {
        clocks[clock.key] = clock.value;
      }
    }
    double? temperature = map['temperature']?.toDouble();
    if (temperature == null || temperature < 0.1) {
      temperature = null;
    }
    final cpu = Cpu(
      name: map['name'] ?? '',
      temperature: temperature,
      power: map['power']?.toDouble() ?? 0.0,
      powers: SplayTreeMap<String, double>.from(map['powers']),
      clocks: clocks,
      load: map['load']?.toDouble() ?? 0.0,
      loads: SplayTreeMap<String, double>.from(map['loads']),
      voltages: SplayTreeMap<String, double>.from(map['voltages']),
      cpuInfo: map['cpuInfo'] != null ? CpuInfo.fromMap(map['cpuInfo']) : null,
    );

    cpu.loads = SplayTreeMap<String, double>.from(map['loads'], (a, b) => extractFirstNumber(a).compareTo(extractFirstNumber(b)));
    cpu.clocks.removeWhere((key, value) => key.contains('Core') == false);
    if (cpu.clocks.containsValue(null) == false) {
      cpu.clocks = SplayTreeMap<String, double>.from(cpu.clocks, (a, b) => extractFirstNumber(a).compareTo(extractFirstNumber(b)));
    }
    return cpu;
  }
  static int extractFirstNumber(String input) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(input);
    if (match != null) {
      String numberString = match.group(0) ?? '-1';
      int? number = int.tryParse(numberString);
      if (number != null) {
        return number;
      }
    }
    return -1;
  }

  factory Cpu.fromJson(String source) => Cpu.fromMap(json.decode(source));
  factory Cpu.nullData() {
    return Cpu(
        name: "-1",
        temperature: -1,
        power: -1,
        powers: SplayTreeMap(),
        clocks: SplayTreeMap(),
        load: -1,
        loads: SplayTreeMap(),
        voltages: SplayTreeMap(),
        cpuInfo: CpuInfo(name: "-1", socket: "-1", speed: -1, busSpeed: -1, l2Cache: -1, l3Cache: -1, cores: -1, threads: -1));
  }

  double getAverageClock() {
    if (clocks.values.toList().contains(null)) return 0;

    final List<double> numbersList = List<double>.from(clocks.values.toList());
    if (numbersList.isEmpty) {
      return 0.0; // Return 0 if the list is empty to avoid division by zero
    }
    double sum = numbersList.reduce((value, element) => value + element);
    return sum / numbersList.length;
  }

  CpuCoreInfo getCpuCoreinfo(int index) {
    final clocksList = clocks.entries.toList();
    final loadsList = loads.entries.toList();
    final voltagesList = voltages.entries.toList();
    final powersList = powers.entries.toList();

    final clock = clocksList.length > (index) ? clocksList[index].value : null;
    final load = loadsList.length > (index) ? loadsList[index].value : null;
    final voltage = voltagesList.length > (index) ? voltagesList[index].value : null;
    final power = powersList.length > (index) ? powersList[index].value : null;
    return CpuCoreInfo(clock: clock, load: load, voltage: voltage, power: power);
  }
}

class CpuCoreInfo {
  double? clock;
  double? load;
  double? voltage;
  double? power;
  CpuCoreInfo({
    required this.clock,
    required this.load,
    required this.voltage,
    required this.power,
  });
}

class CpuInfo {
  String name;
  String socket;
  int speed;
  int busSpeed;
  int l2Cache;
  int l3Cache;
  int cores;
  int threads;
  CpuInfo({
    required this.name,
    required this.socket,
    required this.speed,
    required this.busSpeed,
    required this.l2Cache,
    required this.l3Cache,
    required this.cores,
    required this.threads,
  });

  factory CpuInfo.fromMap(Map<String, dynamic> map) {
    return CpuInfo(
      name: map['name'] ?? '',
      socket: map['socket'] ?? '',
      speed: map['speed']?.toInt() ?? 0,
      busSpeed: map['busSpeed']?.toInt() ?? 0,
      l2Cache: map['l2Cache']?.toInt() ?? 0,
      l3Cache: map['l3Cache']?.toInt() ?? 0,
      cores: map['cores']?.toInt() ?? 0,
      threads: map['threads']?.toInt() ?? 0,
    );
  }
  factory CpuInfo.fromJson(String source) => CpuInfo.fromMap(json.decode(source));
}

class Gpu {
  /// name of the gpu
  String name;

  /// core speed in mhz
  double coreSpeed;

  /// memory speed in mhz
  double memorySpeed;
  double fanSpeedPercentage;

  /// core load in percentage
  double corePercentage;

  ///power used by gpu in watts
  double power;

  ///memory used in megabytes
  double dedicatedMemoryUsed;

  ///in celcious
  double temperature;
  double voltage;
  int fps;
  Gpu({
    required this.name,
    required this.coreSpeed,
    required this.memorySpeed,
    required this.fanSpeedPercentage,
    required this.corePercentage,
    required this.power,
    required this.dedicatedMemoryUsed,
    required this.temperature,
    required this.voltage,
    required this.fps,
  });
  factory Gpu.nullData() {
    return Gpu(
      name: "-1",
      coreSpeed: -1,
      memorySpeed: -1,
      fanSpeedPercentage: -1,
      corePercentage: -1,
      power: -1,
      dedicatedMemoryUsed: -1,
      temperature: -1,
      voltage: -1,
      fps: -1,
    );
  }
  factory Gpu.fromMap(Map<String, dynamic> map) {
    return Gpu(
      name: map['name'] ?? '',
      coreSpeed: map['coreSpeed']?.toDouble() ?? 0.0,
      memorySpeed: map['memorySpeed']?.toDouble() ?? 0.0,
      fanSpeedPercentage: map['fanSpeedPercentage']?.toDouble() ?? 0.0,
      corePercentage: map['corePercentage']?.toDouble() ?? 0.0,
      power: map['power']?.toDouble() ?? 0.0,
      dedicatedMemoryUsed: map['dedicatedMemoryUsed']?.toDouble() ?? 0.0,
      temperature: map['temperature']?.toDouble() ?? 0.0,
      voltage: map['voltage']?.toDouble() ?? 0.0,
      fps: (map['fps'] ?? 0).round(),
    );
  }

  factory Gpu.fromJson(String source) => Gpu.fromMap(json.decode(source));

  factory Gpu.max(Gpu oldGpu, Gpu newGpu) {
    return Gpu(
      name: newGpu.name,
      coreSpeed: oldGpu.coreSpeed < newGpu.coreSpeed ? newGpu.coreSpeed : oldGpu.coreSpeed,
      memorySpeed: oldGpu.memorySpeed < newGpu.memorySpeed ? newGpu.memorySpeed : oldGpu.memorySpeed,
      fanSpeedPercentage: oldGpu.fanSpeedPercentage < newGpu.fanSpeedPercentage ? newGpu.fanSpeedPercentage : oldGpu.fanSpeedPercentage,
      corePercentage: oldGpu.corePercentage < newGpu.corePercentage ? newGpu.corePercentage : oldGpu.corePercentage,
      power: oldGpu.power < newGpu.power ? newGpu.power : oldGpu.power,
      dedicatedMemoryUsed: oldGpu.dedicatedMemoryUsed < newGpu.dedicatedMemoryUsed ? newGpu.dedicatedMemoryUsed : oldGpu.dedicatedMemoryUsed,
      temperature: oldGpu.temperature < newGpu.temperature ? newGpu.temperature : oldGpu.temperature,
      voltage: oldGpu.voltage < newGpu.voltage ? newGpu.voltage : oldGpu.voltage,
      fps: oldGpu.fps < newGpu.fps ? newGpu.fps : oldGpu.fps,
    );
  }
}

class Battery {
  ///is the laptop being charged or not.
  bool isCharging;

  ///the amount of charge the battery has left, it's between 0 and 100
  int batteryPercentage;

  ///the remaining time before the battery runs out, in seconds.
  int lifeRemaining;

  ///whether the pc has a battery or not
  bool hasBattery;
  Battery({
    required this.isCharging,
    required this.batteryPercentage,
    required this.lifeRemaining,
    required this.hasBattery,
  });

  factory Battery.fromMap(Map<String, dynamic> map) {
    return Battery(
      isCharging: map['isCharging'] ?? false,
      batteryPercentage: map['life']?.toInt() ?? 0,
      lifeRemaining: map['lifeRemaining']?.toInt() ?? 0,
      hasBattery: map['hasBattery'] ?? false,
    );
  }
  factory Battery.nullData() {
    return Battery(
      isCharging: false,
      batteryPercentage: 0,
      lifeRemaining: 0,
      hasBattery: false,
    );
  }
  factory Battery.fromJson(String source) => Battery.fromMap(json.decode(source));
}

class NetworkSpeed {
  ///in bytes
  final int download;

  ///in bytes
  final int upload;

  NetworkSpeed({
    required this.download,
    required this.upload,
  });

  factory NetworkSpeed.fromMap(Map<String, dynamic> map) {
    return NetworkSpeed(
      download: map['download']?.toInt() ?? 0,
      upload: map['upload']?.toInt() ?? 0,
    );
  }
}

class ComputerData {
  late Map<String, dynamic> rawData;
  late Ram ram;
  late Cpu cpu;
  late List<Gpu> gpus;
  late List<Storage> storages;
  late List<Monitor> monitors;
  late Motherboard motherboard;
  late Battery battery;
  late List<NetworkInterface> networkInterfaces;
  List<TaskmanagerProcess>? taskmanagerProcesses;
  NetworkSpeed? networkSpeed;
  late bool isRunningAsAdminstrator;

  ///the data that's used inside charts will be saved here,
  ///for example if we want to make a chart for gpu loads, we will save the gpu loads of each second into this variable
  late Map<String, List<dynamic>> charts;

  ///this has the processes and their gpu utilization, we use this to auto detect game process.
  Map<int, double>? processesGpuUsage = {};

  ComputerData();

  ComputerData.construct(String data) {
    data = """
{"computerData":{"processesGpuUsage":{},"ramData":{"memoryUsed":8.231449,"memoryAvailable":7.71408463,"memoryUsedPercentage":51,"ramPiecesData":null},"cpuData":{"name":"AMD Ryzen 5 5600X","cpuInfo":null,"temperature":67,"load":12,"power":47,"powers":{"Core #1 (SMU)":2.121441,"Core #2 (SMU)":1.609694,"Core #3 (SMU)":3.38655758,"Core #4 (SMU)":2.3856616,"Core #5 (SMU)":3.9047122,"Core #6 (SMU)":2.739199},"loads":{"CPU Core #1":12.37553,"CPU Core #2":3.16815,"CPU Core #3":4.50701,"CPU Core #4":3.42431,"CPU Core #5":19.17458,"CPU Core #6":17.21715,"CPU Core #7":15.09418,"CPU Core #8":3.9339,"CPU Core #9":24.65328,"CPU Core #10":20.23846,"CPU Core #11":22.27828,"CPU Core #12":4.84061,"CPU Core Max":24.65328},"voltages":{"Core #1 VID":1.3,"Core #2 VID":1.3,"Core #3 VID":1.3,"Core #4 VID":1.3,"Core #5 VID":1.3,"Core #6 VID":1.375,"Core (SVI2 TFN)":1.3,"SoC (SVI2 TFN)":0.9875},"clocks":{"Core #1":4524.99756,"Core #2":4524.99756,"Core #3":4524.99756,"Core #4":4524.99756,"Core #5":4524.99756,"Core #6":4574.99756,"Bus Speed":99.99995}},"gpuData":[{"name":"AMD Radeon RX 6600","coreSpeed":49,"memorySpeed":1740,"fanSpeedPercentage":0,"corePercentage":5,"power":17,"dedicatedMemoryUsed":55104,"voltage":0,"temperature":46,"fps":0}],"motherboardData":{"name":"Gigabyte B450M DS3H-CF","temperature":0},"storagesData":[],"monitorsData":[{"name":"DISPLAY1","height":1080,"width":1920,"isPrimary":true,"bitsPerPixel":32},{"name":"DISPLAY2","height":1280,"width":1024,"isPrimary":false,"bitsPerPixel":32}],"batteryData":{"hasBattery":false,"life":100,"isCharging":true,"lifeRemaining":4294967295},"fpsData":null,"taskmanagerData":{"System":{"pids":[4],"memoryUsage":1.6875,"cpuPercent":0.56666666666666665,"icon":null},"Registry":{"pids":[148],"memoryUsage":50.44921875,"cpuPercent":0.0,"icon":null},"smss.exe":{"pids":[544],"memoryUsage":1.078125,"cpuPercent":0.0,"icon":null},"winlogon.exe":{"pids":[648],"memoryUsage":9.421875,"cpuPercent":0.0,"icon":null},"csrss.exe":{"pids":[732,912],"memoryUsage":12.21875,"cpuPercent":0.091666666666666674,"icon":null},"wininit.exe":{"pids":[904],"memoryUsage":6.18359375,"cpuPercent":0.0,"icon":null},"services.exe":{"pids":[976],"memoryUsage":10.0859375,"cpuPercent":0.0,"icon":null},"lsass.exe":{"pids":[984],"memoryUsage":22.01171875,"cpuPercent":0.0,"icon":null},"fontdrvhost.exe":{"pids":[1084,1092],"memoryUsage":20.609375,"cpuPercent":0.0,"icon":null},"firefox.exe":{"pids":[1464,1640,2496,3120,4084,5288,6472,7272,8128,8840,8964,9652,10320,11656,11912,13132,14600,15612,15768,15796,16856,16872,16880,16892,17540,17948,18712,18860,19928,19968,21372,22236,23280],"memoryUsage":3768.98828125,"cpuPercent":1.6083333333333334,"icon":"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"},"GoogleCrashHandler.exe":{"pids":[1728],"memoryUsage":1.8515625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAAGUlEQVR4nO3BAQ0AAADCoPdPbQ8HFAAANwYJ3QABA5dj1QAAAABJRU5ErkJggg=="},"dwm.exe":{"pids":[1860],"memoryUsage":78.03125,"cpuPercent":0.47500000000000003,"icon":null},"GoogleCrashHandler64.exe":{"pids":[1904],"memoryUsage":1.58203125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAAGUlEQVR4nO3BAQ0AAADCoPdPbQ8HFAAANwYJ3QABA5dj1QAAAABJRU5ErkJggg=="},"AggregatorHost.exe":{"pids":[1916],"memoryUsage":4.5234375,"cpuPercent":0.0,"icon":null},"msedge.exe":{"pids":[1960,2900,11176,11208,11272,11568,11596,11988],"memoryUsage":357.75,"cpuPercent":0.0,"icon":"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"},"sihost.exe":{"pids":[2040],"memoryUsage":24.82421875,"cpuPercent":0.0,"icon":null},"amdfendrsr.exe":{"pids":[2324],"memoryUsage":6.8046875,"cpuPercent":0.0,"icon":null},"atiesrxx.exe":{"pids":[2332],"memoryUsage":6.3671875,"cpuPercent":0.0,"icon":null},"AMDRSServ.exe":{"pids":[2772],"memoryUsage":7.35546875,"cpuPercent":0.0,"icon":null},"atieclxx.exe":{"pids":[2800],"memoryUsage":15.0859375,"cpuPercent":0.0,"icon":null},"MemCompression":{"pids":[2912],"memoryUsage":442.9375,"cpuPercent":0.0,"icon":null},"SpacePop.exe":{"pids":[3212],"memoryUsage":36.51953125,"cpuPercent":0.0,"icon":null},"taskhostw.exe":{"pids":[3452,3588],"memoryUsage":21.6796875,"cpuPercent":0.0,"icon":null},"task_manager.exe":{"pids":[3692,7300,10996,20080,20304,20392,20496,20748,20796,20876],"memoryUsage":263.0390625,"cpuPercent":0.091666666666666674,"icon":"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"},"spoolsv.exe":{"pids":[3828],"memoryUsage":14.859375,"cpuPercent":0.0,"icon":null},"AdskAccessCore.exe":{"pids":[4008],"memoryUsage":68.6484375,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEhElEQVR4nJ2UTWhUVxTHf/e+74kxY3gJAcUh4FRpJNWOARUTF35R3FSwdVehUdBNq13UUkopummFglDBlMaPjYG2aSXUNpHETVMptQh10RFNUoumEQeSMEHffL57u4gzzESTqAceD87l/v/nnPs/f0FFJBIJ/9ixY0c7Ojo+cl1XKqV4kRBCIITgypUrp7q7uz8ZHBx8DGA+ObePHz++c82aNUdaWlq2OY7DixIAaK0xDINdu3Yd6u/vHwR+KZEs6erq+nj9+vWHa2tro1prlFJIKdFavxSRUko3NjYuKeXM9vb2Wt/3d/q+H52cnCQSiSwKJITAtEykkBVJUKFCqdkvm83aQATImABKqXw+n3+uKm3bRhqSW8lb/Hv3LkIInmCwfPlyXm1pQUrpSCk/XbFixU7DMD40F8GtCs/zmJqa4sfeH+i5eJGJiQkMaQAQZALe3LOHz09+gWEY0vO8eE1Njc5ms+6iJEIITNNEGgbXfrtG15kz/Hn9OmEYYpomSqtyl5ViCcMQrXVBCKEXJDFNE9M0GR8f58K5C3z/3bcEQYBhzFavlQIh0GikkOX8UzgLdRAEAUODg5zrPksymcR1XQAMKdm2fTvr1r2GBiKRCCN37qC1JgxDpJRVWPOSWJbF111dnP7qNCoMcV2XXC5H/JU473Z28sbu3TT4Pkorhn8dZqC/n6amprIQnosE4J/RMbJBgOM4mKbJW/vepvPAAWKxGEopkskkZ7/p5ufLl0mlUry9b99TXSxKorRCA4m2Ng4dPkTH1q0opcjn80xPT3P0vfe5ceMGkUgEy7LmXd55SZRSNDU1ceSDo7yzfz8NDQ1kMpnZS6ZJNpshCB7T2NCAaVkEmQyu574YSbFYpPPgQerr6xFSEgRBed5hGFJfX8+Xp05RyBcQQqC0IhqNIoQgnON7C45r2bJlhEqhi8WqB9VaY1k2a9eurcorpSgWizBnbAuShGE475nWmmdZ0aLqEkJg2zau6760CwshypZfRSKllI7jkE6nGRoaYnJyEsMw0FrPznjWIsq50sKVzoQQZdASyejoKLZtMzMzg7l06VKZyWQKY2Njf5w/f755ZGSksXSxNBbHcbBtm3Q6jW3b+L5POp0mCAJ830cpxfT0dNUdz/OwLGu2k7q6uuDq1asnh4eH//I8ry8ajTZWGl0ul2Pv3r1s2rSJEydOsGPHDuLxOBMTE9y/f58NGzYwMzNDb28vDx8+LHdUuZRmT0/PNPATYCcSCbtyvmEYUldXx+rVq6mpqaG9vZ3W1lYuXbrE+Pg4bW1trFy5ktu3by8okkoPeEpphUKBWCxGc3MzUko2btyIUgrP84jFYkxNTTEwMEBrayvxeHxWvs+IueqqMh4pJa7r0tfXRzKZZPPmzaRSKbZs2cK9e/cYGRlh1apV3Lx5k7GxMUzz2RtRKWo7kUj8HolEXp/bulKqrDSlFI7jkMvl0Frjui7FYhGlVJVsDcPg0aNHfz948GB3ZeX5VCr1WSaT+a/y0UrghmGU//l8HsMwsCyLQqFQBp0v/gdo1wC4ZvOPnwAAAABJRU5ErkJggg=="},"mDNSResponder.exe":{"pids":[4340],"memoryUsage":6.0078125,"cpuPercent":0.0,"icon":null},"AppleMobileDeviceService.exe":{"pids":[4352],"memoryUsage":11.3359375,"cpuPercent":0.0,"icon":null},"WsxService.exe":{"pids":[4400],"memoryUsage":7.4765625,"cpuPercent":0.0,"icon":"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"},"SWVisualize.BoostService.exe":{"pids":[4408],"memoryUsage":59.94921875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAAGUlEQVR4nO3BAQ0AAADCoPdPbQ8HFAAANwYJ3QABA5dj1QAAAABJRU5ErkJggg=="},"AdjustService.exe":{"pids":[4416],"memoryUsage":14.15625,"cpuPercent":0.0,"icon":null},"SWVisualize.Queue.Server.exe":{"pids":[4428],"memoryUsage":39.23828125,"cpuPercent":0.0,"icon":null},"EaseUSStartHelper.exe":{"pids":[4444],"memoryUsage":9.0390625,"cpuPercent":0.0,"icon":null},"ensserver.exe":{"pids":[4456],"memoryUsage":18.2578125,"cpuPercent":0.0,"icon":null},"sqlwriter.exe":{"pids":[4488],"memoryUsage":7.00390625,"cpuPercent":0.0,"icon":null},"AUEPDU.exe":{"pids":[4496],"memoryUsage":7.47265625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEJElEQVR4nMWVT0gcVxzHv+/NOPuX1V5MRbFSNaCn6iE9NHpZIlrQHGoXU2j01EJMiKx4kp7abcAFoUcjxIslZtyKZVHBPwgGTwva0woiRkVhVVJ3dnd2dsaZ93owO7j+SQ30zxfmMO/95vt57/e+vAGuUXt7+y1Zlu9Fo9ExRVFSpmny6enpEAAyPT0dMk2TK4qSikajY7Is32tvb791nddFCeFwuDkWiw2ur6+/zmQy7ODggM/OzvJ4PM6Pj4/fDA0N9R0fH7+Jx+N8ZmaGJxIJrqoqW1tbex2LxQbD4XAzAOG8KQGAmpqaisHBwft+v/9LQkhjaWnpxxsbG1hYWMDGxga2t7dRW1uLUCjEOOcGIUQaGBigu7u7qKmpQV1dHdra2lBdXY2jo6ME53xtaWlpNhQK/b61tbVPhoeH73d2dv5SXFz8icfjwdTUFObm5pBIJKCqKjjnEISzhfX09KC7uxujo6MYHx+HIAgwTROEEHi9XpSXl6OtrQ0dHR1QVRWKouxGIpGnYjAYnCkrK/uoqanpB0rpp5qm4eTkBKlUCpIkgRACADBNE4uLi/D5fFheXj5rAyEoKioC5xzJZBKSJCGdTkPTNKTT6e3V1dUfg8HgDMn3bXNzc6Sqquo7Qgji8ThkWcbKygpEUbRBedPT01NwzgEAnHOYponm5mYEAgHU19eDc46dnZ3nt2/f/t4+EwDQdT0iSdJXmUwGDocDyWQS8/PzkGUZqVQKlFLbNA9ljMHn8yEQCKClpQUlJSXQdR1erxeGYfzmcDg6L0Imc7lcZ1dXFyilEAQBnHNks1l71VeJEAK32w1CCCzLAmMMExMTcDqdEYfD8TUAiOc/yJtSSpHL5cAYK2iVy+WyazVNs+GZTAaUUjidTjDGLi2qAJI3sywLD799iMrKynfpodC0LEaej9h1fU/74HK5wTmDKIrY29vDy4mXdlvfCwEAy7Jw587naGxsgK4boJQilVIKIH6/Hz5fMRhjcDgkrK2tY/zX8ZtDAMAwDGhaDoZh2O07r1wuB0lygDEGxhgMw7jOCpex/4L+E8iV7ZIkCaHQTxBEAZwDhOBSYh71PgIhxJ63TAuSJF0Z9yshhBC8/fMtLMsqGPN4PPb74eFhgaEgCHC5XDeHmKaJBw++QUVFBax3Ec7lNLwYe2HXPHn8BE6nC5wzCKKI/f19RCKTHxbhu1/cRUPDZzCMU1BKoSjJAkhrayuKi0vAGIMkFWF9/Q+8ejXxYRHWdf0GEdbAGINlWdB1/Tqr/zFdwNlBU0oLnvM6P0Ypte+4G0MkScKzZz9DLBLtiDLGCmp6H/eCUmrPm6fmzSLMOYeqqhAEwf71XtxZXplM5sp5y7Kuv4UZY3C73ejv73/v1v9OnHO43e5LOwcAZLPZSf4PKpvNTua9/wJhzGn42xxCDgAAAABJRU5ErkJggg=="},"MsMpEng.exe":{"pids":[4528],"memoryUsage":376.05859375,"cpuPercent":0.0,"icon":null},"FNPLicensingService64.exe":{"pids":[4536],"memoryUsage":7.4296875,"cpuPercent":0.0,"icon":"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"},"remotesolverdispatcherservice.exe":{"pids":[4572],"memoryUsage":5.38671875,"cpuPercent":0.0,"icon":null},"AdskLicensingService.exe":{"pids":[4588],"memoryUsage":17.66796875,"cpuPercent":0.0,"icon":null},"FNPLicensingService.exe":{"pids":[4600],"memoryUsage":7.6171875,"cpuPercent":0.0,"icon":"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"},"OfficeClickToRun.exe":{"pids":[4636],"memoryUsage":35.234375,"cpuPercent":0.0,"icon":"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"},"AdskAccessServiceHost.exe":{"pids":[4656],"memoryUsage":18.83984375,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEhElEQVR4nJ2UTWhUVxTHf/e+74kxY3gJAcUh4FRpJNWOARUTF35R3FSwdVehUdBNq13UUkopummFglDBlMaPjYG2aSXUNpHETVMptQh10RFNUoumEQeSMEHffL57u4gzzESTqAceD87l/v/nnPs/f0FFJBIJ/9ixY0c7Ojo+cl1XKqV4kRBCIITgypUrp7q7uz8ZHBx8DGA+ObePHz++c82aNUdaWlq2OY7DixIAaK0xDINdu3Yd6u/vHwR+KZEs6erq+nj9+vWHa2tro1prlFJIKdFavxSRUko3NjYuKeXM9vb2Wt/3d/q+H52cnCQSiSwKJITAtEykkBVJUKFCqdkvm83aQATImABKqXw+n3+uKm3bRhqSW8lb/Hv3LkIInmCwfPlyXm1pQUrpSCk/XbFixU7DMD40F8GtCs/zmJqa4sfeH+i5eJGJiQkMaQAQZALe3LOHz09+gWEY0vO8eE1Njc5ms+6iJEIITNNEGgbXfrtG15kz/Hn9OmEYYpomSqtyl5ViCcMQrXVBCKEXJDFNE9M0GR8f58K5C3z/3bcEQYBhzFavlQIh0GikkOX8UzgLdRAEAUODg5zrPksymcR1XQAMKdm2fTvr1r2GBiKRCCN37qC1JgxDpJRVWPOSWJbF111dnP7qNCoMcV2XXC5H/JU473Z28sbu3TT4Pkorhn8dZqC/n6amprIQnosE4J/RMbJBgOM4mKbJW/vepvPAAWKxGEopkskkZ7/p5ufLl0mlUry9b99TXSxKorRCA4m2Ng4dPkTH1q0opcjn80xPT3P0vfe5ceMGkUgEy7LmXd55SZRSNDU1ceSDo7yzfz8NDQ1kMpnZS6ZJNpshCB7T2NCAaVkEmQyu574YSbFYpPPgQerr6xFSEgRBed5hGFJfX8+Xp05RyBcQQqC0IhqNIoQgnON7C45r2bJlhEqhi8WqB9VaY1k2a9eurcorpSgWizBnbAuShGE475nWmmdZ0aLqEkJg2zau6760CwshypZfRSKllI7jkE6nGRoaYnJyEsMw0FrPznjWIsq50sKVzoQQZdASyejoKLZtMzMzg7l06VKZyWQKY2Njf5w/f755ZGSksXSxNBbHcbBtm3Q6jW3b+L5POp0mCAJ830cpxfT0dNUdz/OwLGu2k7q6uuDq1asnh4eH//I8ry8ajTZWGl0ul2Pv3r1s2rSJEydOsGPHDuLxOBMTE9y/f58NGzYwMzNDb28vDx8+LHdUuZRmT0/PNPATYCcSCbtyvmEYUldXx+rVq6mpqaG9vZ3W1lYuXbrE+Pg4bW1trFy5ktu3by8okkoPeEpphUKBWCxGc3MzUko2btyIUgrP84jFYkxNTTEwMEBrayvxeHxWvs+IueqqMh4pJa7r0tfXRzKZZPPmzaRSKbZs2cK9e/cYGRlh1apV3Lx5k7GxMUzz2RtRKWo7kUj8HolEXp/bulKqrDSlFI7jkMvl0Frjui7FYhGlVJVsDcPg0aNHfz948GB3ZeX5VCr1WSaT+a/y0UrghmGU//l8HsMwsCyLQqFQBp0v/gdo1wC4ZvOPnwAAAABJRU5ErkJggg=="},"sw_d.exe":{"pids":[4732],"memoryUsage":10.33203125,"cpuPercent":0.0,"icon":null},"obs-ffmpeg-mux.exe":{"pids":[4812],"memoryUsage":11.984375,"cpuPercent":0.0,"icon":null},"RuntimeBroker.exe":{"pids":[4928,8168,8368,8780,9704,16232],"memoryUsage":126.6796875,"cpuPercent":0.0,"icon":null},"dllhost.exe":{"pids":[4936,6544,16168],"memoryUsage":31.5390625,"cpuPercent":0.0,"icon":null},"dispatcher.exe":{"pids":[5064],"memoryUsage":5.6484375,"cpuPercent":0.0,"icon":null},"SearchApp.exe":{"pids":[5252],"memoryUsage":264.75,"cpuPercent":0.0,"icon":null},"StartMenuExperienceHost.exe":{"pids":[5496],"memoryUsage":72.07421875,"cpuPercent":0.0,"icon":null},"lmgrd.exe":{"pids":[5540,5864],"memoryUsage":14.0078125,"cpuPercent":0.0,"icon":null},"sldworks_fs.exe":{"pids":[6008],"memoryUsage":64.37890625,"cpuPercent":0.0,"icon":"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"},"SearchIndexer.exe":{"pids":[6152],"memoryUsage":40.28125,"cpuPercent":0.0,"icon":null},"audiodg.exe":{"pids":[6240],"memoryUsage":17.671875,"cpuPercent":0.19166666666666665,"icon":null},"zal-console.exe":{"pids":[6532,7256,7392,8916,10832,11400,12576,14108,19468,19512,19552,19776,20256],"memoryUsage":1474.4921875,"cpuPercent":1.7833333333333337,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAACs0lEQVR4nO2UP4hVRxSHfzPz5tz3x+e9785bsmupBlNEQSSFYMRCSJkijSA20YUQBSUga6qkiAQNsuLGYhU2hXZin0LIok1QRAiISGxMocKyXK7vjb47c+8ZC41slrfJexjBwq8czu9855xigPe8c0RRtBFA6y21b0VRtFEqpXZ1u93LSZIcAJD+T83TJEkOdLvdS0qpXaLT6Xxcq9V+l1JqZv5zMBhc7PV68wAGq5PGmHae59viOP5jeXm5N6R51G63v6rX69NSyg+Z2ZdluVNmWfYXMy9WVXVfCLG+2WzOGmPOYcgJvfdb2u32rPf+oyGCljFmrtlszgoh1ldVdZ+ZF7MseygBPFVK3WPmK9baGSmlIKJpY8zZVaIGER2r1+ufENFRAI1VglkimpZSCmvtDDNfUUrdA/BUAkAI4a73frKqqkfe+9tlWd7UWh9K0/Q0AA0gNsbMKaX2hxCglNpvjJkDEAPQaZqe0lpPl2V561X+sfd+MoRwFwBqANDv9681Go19AGJr7edRFO0VQmwloq/TNLUA1mmtD/49thACWuuDaZp6AD2t9WFmfu69P18UxTUi2qG13tTv938EAPF631ZrTxRFx51zD4hoOxF9OuTu/4pz7oZz7g4RbS6K4idr7eI/JK+YTJLkM631BmbeobX+YlSB9/6qlPK2c+5xnue/AnjyevO1QnEcf09ER4QQDSllc606Zn4WQhg4537O8/y7YTVrSiYmJtY552pCiN1a6wWllFldU1XVsvf+yxDCdSIql5aW+mNJVtLpdL6Joug0ALXSURTFTJZlZ/4rL0eRZFl2oSzL31a+lWW5mGXZ/Cj5kSQA+tbab5n5GQAw83Nr7QkAQ8/zRsRx/MPU1FSI4/jkOLnaOMUhhF+stR8AWBhrujGRePmfjXrm97yjvADjexqgp0QPQAAAAABJRU5ErkJggg=="},"explorer.exe":{"pids":[6540],"memoryUsage":163.36328125,"cpuPercent":0.091666666666666674,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAC6ElEQVR4nO2Uv28cVRDHP/Pe+s6HbMcoWMlKKFJQKEgKFBGBaJBo0gEdVCiSK0r+AwpCh5Q6BQ1VrqBAlNAEJDoXFKaxpUgGgS+XKDp8v3b3zQzF7p3t2DlClDJf6WlX++bNd74z37fwAv8DAvDDF3z4Ws6t1WUytZNBMcBgTP+r29y48xvbz0Sy+w2fv7LKrYPJkwODwMPq1e2Vy5tfXsyz0cKsWUa/P/HtncnW+x9/vZ8BVCNsaDCcnnLAIWSBztnXufL2B1fCeriDF7P6nlB6yca5yBspfAbczgAuvHODuNbi5WF5+pmQsdTuEDKDQW+hiDnWljl3RpcBMoCX1ldhrQ3Z6SS4gyuk0WIFR6EKWvqchFRC8vr5vOAKVruoJqECj+CnWOuZSazOe0higDbreUGbvDMS1VqeG+C4N8U4+H9WDCLNpKR+B6nzqR5VArjipqg5rhViFeaHhIsQBCQIJkuEuEQMgniY7zckCVwwTVgq2S0v8/399zgoI0F8oRoBzIXVlvLRxs9cav8OWYvMQ533kETBA+YKacLd3kW+279K8ALBWWxbxxFM2qz7H1zKt/AQG3cdbZc1g3fFLPHPVFGtaIent/RIAwdF3XJ8ZqITFg714M0Q7Fjt6hElPJ6XiBFF520T7NBA9riFjWZzVoXPV2FtPj3b5d2VLVTaSLOTecGvw7f49uEnLIei/jr7M8yUNNfucPAzIgzXhGmFe0WyyPnsPm+e2YOlDjE2zqwm3CsuoJpwr3CL4KlW4QnsxODHgmegJegIdIpVFRZKzGJNaAWBiCAIjnuBaXkszqsp2AhUwBJYkjnJ7r39R+c3Wqy0AtgB2BQ3wzHcjGBjMh8QrCSIIOa4TxAbH4vDpkQbEFGGPWe/p4+Aepo7f6bug/1BjpR5KSn/qX/tZkcme1aM9zoy2ev+fX0zo8xDmXImVR7KlEcv8+5f1zePxv3Yv3YzI+USqvxBb5Dv/FJ0n9qeLzDDv8cAsGGcUsOEAAAAAElFTkSuQmCC"},"zal.exe":{"pids":[7024,18848],"memoryUsage":178.80078125,"cpuPercent":0.19166666666666665,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAACt0lEQVR4nO2SP0gbURzHf7ViYigWqiHLiZtSiYMYwSsuTloFETRwpRULUocrtEs3hwxOQSEotSZQuSWzOCl5gqKQBBuTHMWjIGiungHjMzG5e5hTLrwuto3Bv9RCoX6WN/y+f94/gHv+RR787fzyoaGhxw0NDc+3t7el2dnZr3eVPDIy0lRXV9ckSdIiuFyuinA47Dk6OvouSZKf5/n2K7wPAaDqbL0QnufbJUnyZ7NZORwOe1wuVwUAAASDwYFMJlNQVTWtaZoeiUQ8DMNUlgaMjo7Wjo+Pu8fGxmpLZwzDVEYiEQ8hRFdVNZ3NZo1QKOT8Jejq6moURTEiCELf3t5eglJKY7GYDwAsxUGBQIDPZDKFpaUlvqTDEovFfJRSmkwmZUEQ+kRR/NLb29tYLDIrirKIEHKsra0FDg8P07lc7lQUxWkAMAEA+Hw+DmO8TymlGOP9mZmZF2deUzwen87lcqcY4/Tq6ipCCDkURVkEADMAQPmZUN/Z2QkqijKwu7v73u12W/1+/2e73c6LophFCH3r7++frK6ufgIAUFNTY3M6nR9VVS3r7Ox8arfbeULI1vDw8Jvm5uYDhmFem0ymEADoAOe/b1U0Gp1aX19PWa1W0t3d/cFisVTpun4KAGA2mytK36F4dnx8rC4sLEykUqlHLMvaWlpa3gGAWuoBADAjhAbz+bw7mUxOG4ZxQm+AYRgniqJ8yufzboTQ4M9rupbW1lYWY3ygaRq5qkDTNIIxPmBZ9tllWWWXDdra2mKEkHqv19uRSCQ2L9IkEolNr9fbQQipdzgc0Rvt/jIEQeghhJw7ESGECILQ80fBpaysrEwWlywvL0/daQEAAMdxNlmWtyilVJblLY7jbHdeAgAwPz//EmOcm5ube3UbX/n1kt/E4/HAxsbG20KhELjd9u75L/kBtNK8FBYk39oAAAAASUVORK5CYII="},"zal-server.exe":{"pids":[7340],"memoryUsage":66.4765625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEYUlEQVR4nJ1WTWhUVxT+zr1vXmKiGWcyiSadGJsqoSDVVmusdhWwu0ILtVDJxoW4KXQhLbTQbXct3VoXUhAR3HQjFERooRVjDLTFkCbGmpRoMklmJjOZ9+a9d39OF5mZjOkkmfYsHryZe853vnO+c+4jNG904v1jJzr27jqZWyg++O3HiYcAuBlHp5lD+wbjB09/cPx8V1/qQlu87dDS/OpMaiBxbez24xuFuczsjtnt8H/78KWj515+o/9SomvvUEtLK0VlC2UtCislLmW90WeTS1fu3Ri7BcD7ryDOsffSZwaHX7ncfaDz7O62Pa2kJExEMJpgrEUQRDDaQgUqyD8v3Hl8f+6bibtTvwDQO4K89uHAkb7XExd7BhMjHYmOpFAuhHYgTAysBYwGjLGIlEEYKBARHEfAK5Rzy09z159NLFz9486fjxqCpFLoOf7x0ZGuw3suxHvbX3WEA4pikMaFtG4dCMEYC20MolBDKwMShFhMghlYW1mbXJlbvTZ+c+z6yoq/UA+SfOfL09/2n2r/qC3hODqyEMaBtFuBGGhjobVFFCoAgCCClAKxFgdRoPT8k8zN21/d/QRATgBAZ39nd8xtHxJodXRkK8LkSg5ba4MEICSBGWAGrLVQkQG1CMeX0Um3Z3c3AAgAYJcJIONnJWy0k+A2CsAMkCAwGJZ5HcwysqUivCAwrrt+UGxkZaAjICgIgGgbAgyuzCBVnkwMay2YgXIUYdX3wADciodA9cVhQABBUUCH1TIxmhlqBkOxgbYWxcCDtgYShKgeBKgkLxnGAGGRQLXgmykRqFquul81a3iqjLKO4JCAkLXQ9eUCIC1IMkqrFn6JQQ1L1ogdwTIjUBEIgCMlpBBwKwXbgHMshASYGIVCiOXFENZuzvdFZptzsGAQEaSQECRqTVkHcSseghEECmGkUchplNY0SGwOtU2PCDBsIUhAyo3dKwCsN0gCmg08LwIzYAxjKVOG0XZLoTXiqK2FtgYOBKqdr6mLJMMvaShl10VAQLGokF8NQf9qzjYDCkaoIzAsXLeuJ0TEQVlJ339xgRpjsbziI1S6TgRb96Seoa9DqUhxDWThUXYp97f/ICiEWjii5k0grJVC5PJ+XcCNYWxAA8IRCL1Qe3lvLDudXa6BAMiNfTf9WX4q/7mX8SZRWRdEADMjkyvBDxWqdKqA9VBU2WHeoj+Zm8x/MX1r5lMA2YaM02+lj8QPd1yM98VH3A43yXZ9Lx3oTiKd6oJRqK16YywMMyKjkF0q5Bb/Wr7+fCpzdf7n+cb3ySZz0qf2n0kd23e5bX/b2diuWKsrHQy+1ItdsVZobWCYYRnwi36wOJu9M33/ydczP83+imZuxk3WPvDuwLnk4cSllnjLULq3i/oSKZAQKBXLvLpUHJ2bWLhy7/v/d8e/YPH++MHet/ef7+xPXhg8dOAQeXZm4Wn22sPb4zcyU4XZnfybAqmeTQ+n3+zpTg7ZgEbHf/h9DE1+d/0DuEc4OFunhrwAAAAASUVORK5CYII="},"SecurityHealthService.exe":{"pids":[7500],"memoryUsage":13.8046875,"cpuPercent":0.0,"icon":null},"NisSrv.exe":{"pids":[7984],"memoryUsage":12.8515625,"cpuPercent":0.0,"icon":null},"SgrmBroker.exe":{"pids":[8156],"memoryUsage":9.02734375,"cpuPercent":0.0,"icon":null},"olk.exe":{"pids":[8700],"memoryUsage":6.578125,"cpuPercent":0.0,"icon":"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"},"ADPClientService.exe":{"pids":[8772],"memoryUsage":14.16015625,"cpuPercent":0.0,"icon":null},"wscript.exe":{"pids":[9308],"memoryUsage":2.8671875,"cpuPercent":0.0,"icon":null},"AdskIdentityManager.exe":{"pids":[9352],"memoryUsage":22.546875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAABq0lEQVR4nO2VrYsCQRjG31nODzCIH7CgQbFoFbtNMBtMFpPVtGCzCBbBaBRMgsWPtYjRKGJa2H/AXVwFkyAyz5W7w1XnXA+E47gHpsz78XuZZ5hhAEAvlvRqwD/kd0LeflKk6zp1u106HA7EGPvaB0Ber5cURSFZluky4Fj7/R6dTgeRSAREJFzT6dRW5xgyn8+Ry+W+bf65VFV9DmIYBqrVKkKhkCPAU5DT6YR+v49kMum4uQhy1/j1ek2tVot6vZ7Q/FgsRoFAgPDxKkmSRG63mzRNI865PfmSaFkWms0motGocEqPx4NKpYLlcgnTNGEYBrbbLUzTRLvdhizLGA6H4uOazWZgjAkBmUwG4/EY5/PZ1kTTNJRKJfj9/seeTCaTu82DwSDq9Tp2u52teLPZoNFoIBwOOzdeVVVbMmMMhUIBi8Xi5mLouo50Ov1z44mIUqkUKYpCxWKRfD7fTXwwGNBqtRJejEvZIJxzcrlcVC6XqVarUTweFxZaliWM4eoftEESiQSNRiPK5/MPp8tms3Q8HkmS7G8s5/xmOIZr7Av0d/6Tf8hTegch5FEdneHalwAAAABJRU5ErkJggg=="},"ctfmon.exe":{"pids":[9368],"memoryUsage":20.25390625,"cpuPercent":0.0,"icon":null},"AdskAccessUIHost.exe":{"pids":[9800,10344,10376,10704],"memoryUsage":207.890625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAFVUlEQVR4nOWVe4xUVx3HP+feO3Nndmf2EdhSmuzCupitVWgIu1INWFtgGmO1tdQsiZqKYEJjKlabWLqpJFYejfH5h02MUVbQmNKCKWJhbdeyVGm3PIKstMtjeczu7Mw+Zmdm53Fn7r3n5x8Lla5YMNG//CYnJycn5/v5nXzPLwf+X9W4YkVsdU/P4Z8+s2X7o0DgynhfqRvsV32rs7MhMTh498rY/Q987qEHl6XHRqJvD1wIV4WrvZpo+NUTAxf8dCZrdb/0wtM93fuPAvpmILM2b97e2tw8r73iObG29uXLFi1qqSkWHLZve5Zdu36FUyqxeHEbq2Ix7rtvFbVzWnhncLD0em/Pc4df2ffLPx88+Pfrlrz83thHf9y1d+veg4e6j584ncnmRfIlkYmsL6nxvDyy9qsCyN2fXCmHXntNvvnEtwWQ1Q+vkfODIzIyUZYziby82H3k7A+e27UJmPsvkMaWlgf2HP6bDI46MjHpylAiJ8PJvCTHi7Ju/QYBpL39Lul/+7LkClq6du6WX+98QU71n5V4IiOJ5JQkklNyZjgvr/fHZf/hk6c2fOPJRwDDugqJnz+/r//4Wy/e3tS02iiDrzWWZQAGdy5u494VMb637YfMbmgglRpl5apPYVom2vPwfB/Xm44iny8QClehlNzRMOcWG9DvyeTO9ru+8Isdu3fNjlRTdl1EBMs0qKmJUKlMryuVMoZhIiL4WtBaADAMg0AgQNH3KYuSA3/4fedTj31lG8DVm9Q+9uR3Nyxc0rY2MZbC0LOoqY6gRfC0JpPNYwcsPN9Hi8J3NcK0uVLTdYoW0JpyucLLB/bv6Ny4/kdXi7c+vGhxx7qNmzrnL2hdaBjgOEUujo0yt+Iyu64OyzDxtKbseoj801ihpmelUIBTLpNKTzCaneL533b1As5ViDGUiJ8ZSyYuKEPhVlxEwNfC8GSaofFRXM/FVMa7710phWkYGIbC9zzS2QwDly5z/MxZTl+Kk3fKfHH9154Aamb2Sd3Gzme+84lV9z+OCJ5bwTQVAkRtm1vr66mLRvG14HoexVKJdC7HRG6KfMnB9X2UUhgKEDCtgNfbvX/zjp99f+u1mWR+suXpTb7nxpd8/J4tNbW1Ye1VMAyDouczkslRchwESE5myBWKVFzvSi4KUylENL4WlDKIVEWshW1LO4DfAJdmdnxVx9pHX3lwzZc+FgqFMRQUCnkuDg6STKZobJrHrFvm4HtXACLX5GSAKApTucrRI4d29h9/8+cnj71xAnCtGRCVHEmVjvb10dTYyGR6jOGhYXytqIpESAwPEQzZRCJRXM9DicIwTHzfJ5dNMzWV5cRbfxnY97uurwPFd1/XDIgEQyHXdX2O9b2B1kJVtJawHcCyLFAQv3iBD3ywlWAwRKVcZnwsxfhoikJ+inAkCqKKgHmt6UyI1p6bs+0Q4UgthmFgmiZaaxAhaNsUCwWGL18iFLJJjSQol8sEbJtQJEq0th7DtNzp+P89xDl97M1na+vrb53Xcsdy162gtc90JyhEhFA4TGYyTaXsYIeridZVY1oBAoEgXqWMUyyMAf57MuD6mv+Zji9va279yBpE8DyPQDBI0A6CFkQ0GrDMAEHbJjMxJtnJdF9mfORgzx/37i4UCv03AwGojX328081ty58PFwdDYhobNtGBAzTJBgMMDk+6lw8N9BdyuWef/XA3l4gfj2jG/2MxtJlK9d9aMnSLXNva2owLQPHcXQxn032Hz3yUiJ+uevcO6dOAqX3M7kRBID5CxbE7vl0x9ZAwPT6+47s+Wvvn/YA527m7H+qZuC2/4Xxf0X/AI7MqkEa73mRAAAAAElFTkSuQmCC"},"ShellExperienceHost.exe":{"pids":[9808],"memoryUsage":50.43359375,"cpuPercent":0.0,"icon":null},"TextInputHost.exe":{"pids":[9856],"memoryUsage":44.91015625,"cpuPercent":0.0,"icon":null},"SecurityHealthSystray.exe":{"pids":[9896],"memoryUsage":8.45703125,"cpuPercent":0.0,"icon":null},"PhoneExperienceHost.exe":{"pids":[9972],"memoryUsage":132.63671875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAADiUlEQVR4nL2Uy25cRRCGv+pz5uZbxmAiEQIINhESUixlhUDsYIHYISHxAOzYsuE1eATEE6BseAKkIJQFF0GMxALkhPg2nsuZM6erikX3jMfGE3uVWpzu07e//vr/bngOIQAbu++9FHY//kC6WzfFXM+mDSy1ZmejAUD10jkw3EKw8fHB+Nf737P38GkJEN7+6MPeW+9/Lev9LVTdzcABd3An/XseMxw/m89znucwxyWIjY+HFPrFeO/htwlkfXtHupv90N0UjxExTQcA4o67IYC7gxqmOXU1XAQHxNI63BEJSGxu0N7eASgBcDM3U6vrsvQpN9/o09ns4NFwNdwcrRscp+i0KMoCEWd8MOLJo0PcQyqie2IjAVQVjXYGQqLus5puL/LynRfp9bvMRpHqeEJTzTg5GoDA9q0b9F/vEwIM9k852tunmgak1QZzkMTI3ciiJRCLEVdFEFyVulIoDW2c0O3QbrfYvtNBgLLbphoqoRCaieLagBVgZdJK50wMsoXOmJgjYjRV5Hh/QjHIzpJsQ0kdH8/AayQE6pMKawy3kMrknoX3rKleAHHDTXCxxfqFoyBluRwOvhDbsstITpTc2hKToArqOElkJBG4cOyl4ZYtbpYSyyDksTMmZrgZklK45vELOmCSDtQ8Jo6bz4lk4S2Xy2VxP66MrJW74+pQLF3WORO9oImbIQ7aREYnNWEakiVXYYTA7HSGRwOXVGZ1YF6u3F+AqC1ub2yU0VGNdK5gFQI2rNFGEwNNrftceD0vvJpipoQgaUO267VKtrCtsfy2+VKCIX8Ny49h8u71QJhb1RePpc9tbw5Z+xLYkqrakBhxM0KIOcmr2MiiTK4GhARgqY8q3kw3gL688O7n98P2rbvF1s4rxBpr95i9eQ/vrmc7r4gQkOExrb0HhBih7J2vgBk2PvxHh09/KeP44Iey1cGGT3+iqbXpbu+MOrfv+Vq/92yQkjD8d7j15M8HoZmd0moX5+voQlFKHB/9OK/JWuJP5O4n77D76Tf0X72NzlaDlB04+utnvvvyM47/3gOKS1YZUM3vyWSxt1yfeKxcmglosxrEDW+mqq3eBJiuXrj8QM4HRo/L3uEfRbsZ4BpXbpSyRRzsl8NqUjyD7+UgQaeV1MORTDqWrvNKlMB0eDprxldh/B9kMvjtUVjb+kpPD19zbCUVFwqtR78zPXl8Fchzif8AVOt0WSu75LAAAAAASUVORK5CYII="},"iTunesHelper.exe":{"pids":[10384],"memoryUsage":13.7890625,"cpuPercent":0.0,"icon":"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"},"RevitAccelerator.exe":{"pids":[10800],"memoryUsage":48.66796875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAD+UlEQVR4nJ2WTUxcVRiGn3POnV+GAplSRAqKKAkJkhKDbTQ2rdqGjT+JbhpXjVoXLoyNLkys2kSridHYRBe6MrFxoZKYFqOk/ixsU4oiWK20KVKgWGAYmKkDw525P8fFnYEBZoD6Jjc55+bkfb/vPd/33SsowJ07OqvD7Ydfjod3v+SKgEBzcxCAtjGvnnwvOXDsNSb70/nXAIGHnvmw85bb2l4wI617e0eqsB0QojRfSUjQTnox+ePzj2UufXoawIhGo+W7Dn5ypLap41BZpLLin7iD1rpA34NbJCshVp8CL3utZaAmsqRb1bS7IlJes7+soqYia86jtbuWTYNPgd9YfpQAywbbKZ6Q1nYAasOAMIQ0tMaxHDtb9LCrIeiDdw9AfdQjVwoS83DuCnzRB1NJMFRhhr6Af+uOozRP7TeTw68YxeMojAiUhI5GaNwG1+ZgdAY6muDhVmith8MnYCHrnfPskkpu2d4sIvVWMDUdkBuJ5IUytrfu6oMnjsPrXd5+393QsBWc1S47FlpblikyelMihVjIwEwC/o55e59aaVUxbGjXarQ1wMG98OROb39xAiaTINcJd9Mi+Qp+pN17AIan4dUvYfoG+NZh2rRd+X44cRbe/NpbKwmJNFhOkX75PyJ5jM/CBz0wMAaN1fDsHqgIFW/WmxIRAkJ+bx0JwnwGPv7Bq7qn7ofnHoRsiaaETdyJEGC70PUL1FZC/1UoC0D3IDSc8nrFtNa3a0MRKcCy4O2TQG5W+ZV3D+9/Cx+d9qwKrMO0ueoSuW5meTJLAULlmrDYoCwlIgRIZSCkWCIv0CmmXQLKI9MFIkJIqQw/mUXN9dEh0uMLaMQSie24uRkm0BqkFLhao7VG54iUFMh8cGhccwakl4PhU0FlZ9PZuYm/en8+298Ui89XS7xS0VojlWBLOEDAr4gnFwn5DdKmjd8vKQ/5EUIghSCVzjCftpB5P40wQngeG6qyLjXya/exod7PLrhNL3b7I9FqXO+gZbvUVUU48vQuzKxDLJEmHDT46vvLPL6nmVhigfvabiVruxz//DcuDMeQSi17n7+TP755JwGcAkIhQ624I9fVBP0Gd2yvZGzyX5rLq5i9sci+nbdzT0sNh97qoaUxylR8gYsjcQxVvO0K366pNAFoNNp1uauhksFL0/zUN86Bzhauz6QYG50jazmk0lnMrIMo8VNgrODMm5iPQArMjM1350bpH4rxQHsdl68lODMwQU/vKMqn+P3KDPFkGp9RengUSgdD9x49r8Lb2nBWfoq1BsfV+AyJ1ho3N6ikFEs/HWuSUAGc1Njg4uSZRwvlTSfx5xuYs1PI1V8hjaEETq6UEZS0phj+A6LNe2sHpcemAAAAAElFTkSuQmCC"},"PenTablet.exe":{"pids":[11036],"memoryUsage":24.83984375,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEG0lEQVR4nL2Wz0tUXRjHP+c6c23m6tyEaRwbzAxBtJUGLkSwRZq46A/QINq4cNVCEGdRi1ERJgwUMQgx3LhQxHYKBW+6ayVKuRh/EkqDlmP+yLlz8WmR3rerLt4XrAPP4p7z3Od7vt/ne+85AAqoA/4B0oBcQqRP6tWd1KcOSFxS8bOROKnP+z8EcBrv1Qk1HSAcDnN0dEQqleLsMAwD0zT58uULFRUVFBQUICLOum3brK6usrS0xPHx8e+vWuoEDYDm5maqqqqIxWJsb287Wbm5uUSjUdbX1xkZGeHVq1ekUim2trZQSiEi6LpOKBTiw4cPvH79GsuyXJt0qF29elVisZi8ePFCQqGQAGKapnR1dUlvb68Eg0EJBAIyODgoN27cOCdNcXGxvHz5UhobG13z2u9oqVSKnp4e9vf3iUajFBYW0tbWhs/nc9gppQDweDznJF1dXeXNmzfcvXvXNa+dTTw4OKC7u5tPnz5RUlLC2toanZ2d7OzsnCt60fj+/Tu6rjubuRAEwOv1AvDjxw8AdF13rYvIOc1P8xoaGlhYWHCZ4hxn0zRpb29H13Wmp6e5f/8+HR0djlwigmEYPHjwgI2NDafxV65coaKigqysLCYnJ101Xe4yTZOOjg50Xaezs5Nv376Rk5NDe3s7eXl5PH36FMuyGBoaIplMkkwm0bRfYti2TSKR4N27dxdK67igqalJent7JS8vz+UOn88nsVhMWlpaxO/3y/Pnz+XmzZv/54P896GgoEBM07ww0e/3SyQSEaWU3L59W/x+/38GccmVnZ2NiFBUVITX62V5eZl0Ou1QDoVCBAIB1tfXyWQyeL1efD4f4XDYceLi4qKr6a6eKKV49uwZkUiEdDqNpmns7u7S19dHMpnk4cOHVFdXk8lksCyL/v5+lFJ0dXVxfHzM0tISkUiEt2/fMjY2dvbXckJJKRkdHZXu7m4xDEN0XZfW1lZ58uSJ3Lt3TwYGBqS4uFgMw5Dm5maJx+Ny584dGR8fl8rKSgGkpKREBgcHpbCw0CWXY2GlFF+/fmVsbIyDgwMApqamePz4MXV1dQSDQR49eoSmaXg8HsLhMNeuXWNhYYG1tTUAlpeX2dvbIxgM8vnzZ4eFA3Lq//Lycubm5hARbt26hW3bbG5ukp2dzcTEBJlMhqKiIjweD1tbW2RlZTlft1LKid+HC0TTNJqamjAMA9u2qaqqYnh4mEQiQTQapba2ls3NTWpqapienubw8JCjoyNXow8PD7Ft++LGa5pGPB5nZmYG0zTx+/3Mzs7y8eNHAPLz86mvr8c0Tebn55mZmSEQCHD9+nVWVlawLAulFGVlZWxsbLC7u3u+8ZqmSTwel9LS0j9xOv66PCilpLS0VHJyci4bIA1/4YyHv3Rb+eP3rp99uZvoz0iqzQAAAABJRU5ErkJggg=="},"iPodService.exe":{"pids":[11080],"memoryUsage":7.98828125,"cpuPercent":0.0,"icon":"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"},"Nexus.exe":{"pids":[11900],"memoryUsage":31.77734375,"cpuPercent":0.091666666666666674,"icon":"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"},"Discord.exe":{"pids":[12032,13040,13064,13412,13444,13624],"memoryUsage":514.8046875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAE6ElEQVR4nK2WXWwUVRTHf/fO7HZn6+5si5UtsF0opdCWAgJFIEhUEpBi6IsmYEQSow8mvgkhEX1SElTejYlfiEF88AETSyAaojahYWsgFgK0tWQpsCUI3e3S3ZadudeH2e7yWTDxJJNJ/nPm/M/XPfcIppCmpz+MV9nzVyLVxlCkcYVVGaszDSvouPlc/tblZDZzvgdldI5kLnSfO/VB8mF2xIPAmpq26MK2Pa8FgjO2h+3GhUIYaO2gtQI0IBBCIoSJ1i6jmb4z47nUt2cS7x24fj0x/EiS1hUfrZwZ2/xxyG5Y6zMtHCc/VbAAmEW90czA71eGftrVe/L97oeStLbtWVc/b/sBqzJaq5WL1u4jCUqGhIGQBvmxa6nB/m+29SZ2/3ofyZLln7bVNW49HAxGa5W6/djG7xUp/eTGrqUu9R/sON2zMwEgAWKxLTOi8Q37HkSgFDgOuOpuY24RV/fgSt0mWDm9NhrfsC8W2zKjRNLQ+tarYbthjdZOWVmDEBCbKejYaLKoWSIAKb3wFzdLOjaaxGYJhPD0J0Vrh7DdsGbuoje3AojmZXvrZs/edMSuXtjsuvmS99OqBW+/4aOp0cBnQjqjSWc0FRUwMQFVEYEdFhQcONfn8tmXBW6MaKT0iAzTIv1P79lk8sd2GQnVrwpH5pcIvAaFVzabLG4x8Pu8iKoigjlxyYyoZE5cErG9CPw+WNxi8HKHiSj+D+A6eeyqBS2RUMsqidTtYpIeL8+NDZLlS8vY40jbUsn8BolTzjhCSpC6XYYijcuVuqNVNaxYKrFD/43EDknalspyKIBSLuHIvDYzaM2Ma1QRhJppgnn1ZYJ0RnPsuEPQgg0v+PD5oFCAo8cL5HKw/nmTiO2dhHn1kpppgptprzYahWXNqjNNnxVEe/SuC9VVgtpomaT7T5cDPzgEgxCPSVqbDc4PeFguB+GQ4MV1JgC1UUl1leD6jWIDaI3ps4LSKeRzCM8TraGyEuxweRBYFVDh9wocCHi4FRAe5odAxR0pCwsqK5n0GYTAKeRzZj5/+ZI/0NKkcdGAz2SSE4A1K00sS1BRAQ1zvAjnzpbseMdPflyzbIlZ0hXC+7/EgSSXv5I0R9P9iappi5pc9/45pTWMZjXLFhsYBncZW9Ri4LiQzepSO98rUhpk0309Jkp0aqVeBzANGExq/uh2WPOMiRAwcVtz+IiDlFA7XRCoEIxPaFLXNFrB6hWentbQ1e0wmNSYRYe00qBEp5nOnj1hjyw4G3mytQXy3BzRfP51ga4TLi+tN4lGBYlTigv9ilAIDOnNrWwWmholz66C02ccfj7mcq5PMTEBhlE+8ens2RMC4LlNv7z71PTVnwghpdYKpTzPfD6wApAf9zpP67tTZhhe4ccnvLYWojjbhERrpa4Nd+36rXP9Pgnw919ffD+aGegSwizm0jOgFNwa896TBiYfITx8LOe9DYPS3BLCZDQz0DXY+9VBKE7hoaFDV4eTR3fkxoZTUvrvKt6DCjrVd+8+GU4NJ4/uGBo6dLVEAnC6Z2fi4sD+bfnccEoafoQw+C8ihIE0/ORzw6mLA/u3TV5YMMUdH7Yb1hqmhft/3/GT4m0re7cFgtO3h+3GlsfbVq7uP5PY/d1jbSt3SnnvcttD9oLl1hOz4qW9a2zoUjbddxIljzxq7/oXugIY82NN20sAAAAASUVORK5CYII="},"Spotify.exe":{"pids":[12228,14104,14264,14540,14552,14828],"memoryUsage":303.30078125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAFf0lEQVR4nJWWXWxcRxXHf2fu3bsfttfrj3j9sTHUcZwPEpLw0LoloYmgSlWkCmgjgoTECyqlEg9tBAghhAQPgFBQUaQQ8QCvLa1KCVKbVhFVRU2dSpBg03zYjmuSjRPX9nrttde7d++dw8NdHJqodjjSvNw7M7//OXPmnBHuxbqb2tq/t681PrApqSkcKRNWR2dX5359vsB0aX6j5bLez6ZnPv1Aw8HcYTXOZ02zt8Ok4+3iGk8D69vF6pwt+ZdEw6GVv+TfKJ0cOff/QTYnu7M/P/Sc+4mmI86mVK8kXfBD1CpotEqMgOegqwHhhyvXg+vLL818/63jXF+d3hDS/M09e1Nf2XIy1p95UFxBfQuq68RCEM+goaU2sThc/tPEM4unRs5/LCTzrb17kk9sedHrz2zbcPOPgfkTxbHyK+NH/xdk1iZtS3Ynv9R3yuvPbNNKGAEEMAKOAbc+HBN9u9NU0WqI158ZSD2+5Tf0t+bugmR/euhYrD8zqKFCyoGkE21WCdFiFZ2toHMVKPkQWPAMpNxoXuw2WP0Qb6Dlgc6fDR77794uQPrZPfc7nU1flZhB51axf5tFL8yjH5RgvoIu1yCoexZ3kLSHZJPQ14jsbEF2ZJDuhghYC8EIJtt0pOk7u18snRgddgGT2t972O1q6FGU8KUp7C8u1CXUPYrXvVKFUg3Nr6B/nwW1EHNhcyPm/nbkkR7MYAcaF9yuhp7UwU8+Wjox+p6bHsxlsHrAeA42CJH+NHKwG+ltRAaakY4EpL0oJKqwGqJFH2bK6NUSerGIji9iX7gKZ26gh3M4P9iDaYsjavc3PtzV6npH+9pMJr5DayHULOZzXZiHO5GUiwpQCaMRKDgCCQdJOFES1CwUquhIAfvqv7Fv5rFDt3BWdqIZD9Oc2J748tYW1+zalJQmr11tPeai6GSJ8O2b6MgC5FdgqX7YjkGbYkhXCtnRjOxri87kkR6cz3dhhj6MhLQnUD9Emr02s2tT0nVdHHHFQ+vpapXw5CX09AfQkoSOBNKWiLKpZqHko/+YQ8/eANcgA2nkUDfm8V5ksCPyuBKAEcQRz3Vx3CAgjAXqIySwCiKYo31wIItsz0BHEkm5kUKraDmIQjS5hL47i741jT3xPvrna5gf78Mc7Fq75hqqHwSErv3X7Kru6piTtmROQwWrmIc6opgvB1CsojfL4EepKU0x2NyA7G6BJ+5Dr69gX5jEnsnfTnOi2qZLfsFeKlZc/7XJebc7fVm2tuS0ZiFu4Moi4e8vo+8voos+VC2E9Q1iDtLswc5mzP5O5EAnznd3Y76xFYkZWA0jSszBFv1LlZcvFtylN/PF1NOf+av1wy8gAiJQDtAFH/lUK9LXiLQmIOFAaGHBR6eWsSPz2LPTkGvAfH0L5sm+SEi9jlELUWFo+e2bBRewK2en3jDtyadiucYerYawPYP7/EPR3XCFj9ZRBQvOSg39ZwH7uzHCV69hHuuNhCiIZ6jlS9Pld6ZeB+za6uwfvng8vi/7HKGtVzWJeofWe8hata0rFcBzokxarkGDFwkQENdQPX/r+VtHXnv2IwVy5ofv/qo2vnBOvEgN9STgzmqvRN9DhdUgoqbrAEA8B3+s+N6tnwwfv6sKM164UT599dv+RHFM4k6k9l5M60ARJO7gTxbHyqcnnma0kL8bAiyeGjlffmX8qH9lYRgHItgGEKnPc8C/snCu/Mepr63bGdcs19qT/eWDx9xcw5NOtmGzxN0oW+7s8TEHrQYEMyv5ML/88syPho8zcduD9SF1i14rvY+qw36Tjm836Xhb9FoJa3bJn7NL1csEOlR+59qZ0onR4XWcvQcbaGxvf2pva3xnNrH27ro4U5n77YUCY8tzGy3/Dxh0c+3LTwtrAAAAAElFTkSuQmCC"},"OneDrive.exe":{"pids":[12304],"memoryUsage":123.67578125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAADUUlEQVR4nO1VTWhcVRT+zr333fvezJs3P5mkiWGatEpduBCDrSBKQQQ3JXYv7a4LfxdWsLhRqIqLgqgla0ExuCoKimBARElUGpTQhW2hVFtbGxPbmcm8mffuvHtc1EyTdJQk6K7f6sC95/vu+c659wJ3sAXQFvebNbEF4P4rEa2efOdBl9pHiJMJEDGYyYEvCxPOZT9+MItf569uX2T4gTHae/iYKNWeQjhUAGdrMiWQNMHx8rfulx/ewtzJz7YuUhofE0+8/jFFQw9BSCCzfbIJUAHQvPYnX/r+qPv6xPubEfFxeHoUo3sDceXMFAXFR5G2uiCpQP9StDRAvLSUnf/qEL6b+mLjsupFB9/dh6j8NKKRSSiq8Mg94DTpgrhNNtXknAcpBZhvF8kSIByuirF9z7vFc3O4MFO/vZJDHx5AZfcUisM1dFPAdW/ZQRJIWlYkbYGVpQ4pP9+3GhLgTqPtli8+js9fml0vMvn2vajd/yUqYzXYdn87SABgIGlZWqk76qYKJCSYQYKYwG1dDklFlUD65ioaV87ahZmTK58cPwXAKXh4DuXaPwsAAP99HXTe41IO1Lne0pwa17WJqVaVGajmAF6tfAQ77h4RD1f3y90Tb9ajg68RXvhmEfnKYF+v1wkxpJIICxr5sg/fczbtJFmSCuWYFG0cDCHBSdxNz8wcIbzyM/d6sI70Vqi0RGnAIIx8mEDe7D8I7Bxskmbx9ZW2ZZ0HiNbOK0kN+/vZc2od2yo5M4QnYIxCccBHoeRDSgIRgZnhHPdOoX0j1Q4vl8apbdablskPCEIADM5SqMFdexTajQb8MIJjgBmerxDkPRTLPvKRBhF6TnIfS5kZRCT80NfKCNVuJt0kTthJbYgIIAGBS6dPQXrwcwqDoyFGx4u4ayxCoWRWW7EpMDOk0qJQKehCJQfjIXU2SV3caKmcpvfCKJ4sjY+XJdtewk1LtgoGM2DygdF+5nQsRH1+dlrEHz0zH2TXXqSkcYNMDhByG+QbQAIiCIVs/7FQDLxXe7Ow89j0AVmtPatKQ/v10M6A3aa+ij4CBLv0W2qXL38aL54/vnjiyMLGV6+y642Z+8yeiSK6fcZ6M1AKnQs/NS++/NhpAK3tkdzB/42/ANSITu5+8GI+AAAAAElFTkSuQmCC"},"Rainmeter.exe":{"pids":[12380],"memoryUsage":45.9375,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEMklEQVR4nK2WW0ybZRjH/9+h5/NX7PmjtNDS0hYKQwaY2RY2onNO5g5sYy6TGy8UMr3TLEbvvDAmJiYmhkRvxZsZ3QUYzIyLuEME4mDMjRkmgw0QtvUAbb/ve73oYgYFAspz+b7P///L8+R5n7zA9kMBgNmOgNpOsj12ooRWm96XJOGr2f4vftuqjt4OhFYYTul9u7rlevNZAOyOQ3TVrX59WfCc326Ghfd1cvXtB3caQms80Q8qvWXmj47H0RT00vpg44fQu7gdg1gSpw+YHOXtRxurUG414PTz1bDabAE+0dGzMxCNxqK0V7zdHParXqjxIpMDAg4TDjdHWdZoPfNM7GT0/0Io1743j3EWR7wrXgMFW0gnBDjybCUiVUE3a3L2xGKxTYdgU4h91wGeUmm7Dz8XRZWTgygVziUCWA1KHN8dgNFW2jGaszb/Z8gK5+wKBEL+/REPFCwNQvBvJRIBYsFSNIT8aqXN995mXhteKB3lvNkdfKs15EaQ55ATVt+LEsBp5Xg5WgEr727V1bXt3zbEWPNSd6nNan6l3g9JWj8nJwAtYQ/CHifLhWLdKKycrUEM/gaP1ll2qKXGB3eJDoK4PoQQQM5Q6GiOQKHUNDpaX9u3ZQhX19au1+o8RxoCECQUNtwGW04kwG6vA9V+n15m8x3EOsuzGGIwGAXC7k3UhhmrUQMiEZCVRyD55YJ8jYIQQK1g8GLUB0miEvamV31rLYvm2xk7U8mq1I2JKjfY3BLSo70Q5kdAq8xgXXHI+BZQaiPwVAsZFoi6S8C7vRV3cyu1ACY2r0Rn5nm+jOM5LfJ3vsfy8GcQZi8jN/kdMpfeRfriO8j/OfDEveCQnboEs4pB0G1HOjkfwZrmFlUiiZRMpVSCoSiQfAYUzQC0DIAMIAT56YsQF0bAGHpBG32QludApWfAtn0DOcuASJTiCYRsCGFBL8zevy+kciIrczQBrAqQBICiAYoCxShAcmkIc8PA/AhIfhna6texJBDMPkxBrlD/BWDV0Be1Kzv24+Ti3Mz4L7fugeICUAY7ASIC5CkdRQM0CyLlwZSEoAh34eaDRxi/dTsppzC81rMIMvf74BQjZr/t+/kabjzIQFvfDVVtDyiZplAREQEiAESCzBWDPvEJllgXvvxpFNnkw/783cFraz3XnX6N1Wsx7+3qi4QisXOH9iDsNILKzCA7PQQxOQ1KpoHcVge2JIzpJMHHF37FD0NXJhdHB048Hhm8uiUIACj4ULk1frKXd5XFjzbXoMFrg9Wog0rGIi9KWEimcP3e3/h6aBzXJ8ZupCYun128cn5gPa9Nfysar9diqj32BpFpOj3eikq3xQS1nEVWEDGzlMLkndvzueVkX+bm1c+XRvvHNvLZ0pfIuueUR9Dowtn04yhAmSlJSrFy7bjeoBqeOv/pH1j1NIvjH/pUVFGf9l02AAAAAElFTkSuQmCC"},"RadeonSoftware.exe":{"pids":[12388],"memoryUsage":121.5078125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAACsklEQVR4nO2VPWgUQRTHf+/N7F3uch9qDpJOrES0UdMIFikERRAFEUQQxMoilUoICGKjWAQVFG38wEosgmiXQsQ0IoKgYKmFkhhjiMmZ3OVyuzsWt3f5us0lSjofLOzO7M7v/d/7z6x8Zrdjg0M3GvAfsu6wcRMOH6iueSGHoiTXDnFUyZ4+Ru7cCcBB2NqA4+8+Mn7+Gh2kWf52U4jgMTv4klRPN9mzR1sCAExQ4QcVLAny2CWg2J6EpVkmeq9SvPMUXGslMu+jwC8CZglbKwEQDGF5jsn+W8yOjVPZtQ0jgqcGI0qiLUl7905sV6GWrSoWQRGKBCjQFmmIhdRAgLXIl1F+PnpGaWqKFIY2EdLZHN6DK9jD+xsl8ZAIBGVCDBKNxYTDRzNZCncvYTZnKb8YZro0jyAkAIsF319ISAQTLWio3VdxaARtitBMlsLtfjKnDuF8H1EhhyWNxcOAKogsUl0DWLQBMdFaTZQ4JJGgcOMi2TNHoiEHYQiEGBQIV9jaqGBQTKRkAdikJ44Q25En1bN3YdCzaC5Ta5IoiEPzOcSYZeVaDKgriWu8CM4PGo/JPTso3L8MfgACoQjfHz/n95sPpA7uA1PTZxcBlIVSruquRik6O0hHLgqBbw8HGR8apjj0GtvZwZbek6iayEmKWfZ9jBIQb+VUCHy994SRCwOYcpkQGOkbwKRTeNu3LinRqhABXDVg4v0nmCmSsh6CIMDEq7eM9t3EzJWxWCwC5QpjvdfZdPwABq95zs1+v2IMpXyKMRMQOEcisqROzWB9H4NpuMY2NmAQu+2an8JBQPtkkS5CJqhSP8htdC1tcr0H8e2NnQlR0iidKNMEOGr21Cjz5TZdLVZ1lwOSKJsQStHJGmfTv4bUQR5CBmUeF5VqpU3/CVIPg5BEcLh1AQD+ADSmuRgmFSUtAAAAAElFTkSuQmCC"},"wgc_renderer_host.exe":{"pids":[13000,13004,13656,14480,15268],"memoryUsage":180.68359375,"cpuPercent":0.0,"icon":null},"Messenger.exe":{"pids":[13104],"memoryUsage":94.76171875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAFT0lEQVR4nJWVW4hdZxmGn/+0DvswUxKLRDShNNILaRKo1AMqaA2KFiuJEpoStYgVBBVvlBYhBkXwIhfF0tipmA411GoSsdUqpr1IgxdpbTGhNmrbMI7VaJjJTDp71uE/erF2ZiYmtfrBywdrs/6H993f9y/B/1Dptm+/jcxswNVgaigdTABh4Zw48NDf3uh98d9+nL/1wBc1KTe6vrPUZhvUIDwYC2WAOPoDxh8ka1tx34MP/F+Q2Y89fPuk6O1Mst2ZS0ETG2JqUCKg8Gjh0NKiswB9D9kISneENDoi7j34yBtCzmx//FMDpR/WUhbLvkaIiBwfLoVHS9dBhMPIlky2aN3ChINi1JCqPeL+Hx5+XchzHzyxo1DyiE+BSECmdBlECY9RDiXsGGLJRIORLbmskUUNwwqodoqpqaNXQE584NTuTMrpkIIOKSEECCKSMUQEtLAo6TBjSCabsZuGXNRkqsFkDQxGHlN/Tjxw/yEACbB53Y1v/WdT323jtXrJTbAcrmHZT7Ic1mrisl6F4YrqMKQOA+owwLY9qNdpquKOtHevBNAA373+Vx8d6nXvmLMtMV3TWRQJQeicSI8WHiUcOnYxGZHhkiFPhpA0IUm8laRSEKuaord+O69c/CxwUPx0W7o2Gvd9Kc0uGz1xTY6CiCIRrUd6R2YcRWnR4z/cyIZcNphU0V8fGW6SpBf+SpG1DLMGJapHkctf1q8ZNveN2bUQAKVJayEJ/Ai27s54y7bI/JnAX6Zbyn6DTxlZNPioKDLF5m/dQJhdYO6Z86AVwgUmy8EuZ8O9uioITkCrIQHp0igkSBZu3A3v+rpAacXGjyjQmj9OZRjVUGrF1q+9iQ239BAycvaev2PyISrWSCLeNjjyoCvAZGCBKFhxEh2sfztsv2d1xKWCm74qSSJn7jnFplt6XLfHAPDqzy6wdF7T7w+QESSBNgp88OjagMuhTZ2LS06ChA/v+M9V7eqdX1mZGQDq84EX9l+klw1oAigRkKKDJDyyLqE2UGdQjbUIbP04vOeTq9H98geQ4hU8AJ7f72lijyYV2FjSxJI2FthQULkeujKg8tW4YoJiCO+9tTvg2C/gNz8Bvwj/+gfc8Q0o+quAZ+6DM48bJoY9dIhoFdHRo6PDI/HJCV0ZVF5C5SFKGNXwpT2w6Tp44gk49GPoK8gG8PzvIXwPbv4QbHkfvHISXv0T+FziYoEVAS0cSlpMdMy7mtZVQacBL78Gj8Yeu2yEoOC3z8JL5+DYk5APoI0QAxgFp0/Biyfh5vfDzHHQNQz6YFuDSjk6FqjomNSSBTs3PXPx7MsC4BN3pTtVwVQb0FGA8xAs9HPQAUyALEDmIA+QO1BLMJRQeigtFBbKEOjJJQZqxJtzH2y4cNe7n77pRxLgsQ1ML0iONQNYzsD2IE1ClXcDUWfQGGhNt09WQxqA0+BkJy/BIwkxQ4g+M/X84V8//dhDML4g2SeilRwaKXydr05ZbaDJuoNb3UGc6uTXdK+6mIMURFFw0bb+2cWTB/axL166PVZqyzfTDm84kiLI1EWVe8guReI6lXZVvXHvW+g7GHgoRbVzx8n+yvdEroWc/o44OjJ8phmMXYzlVBfRiotxPGEspbsuFbPL8Om1gMvXdlxVzrzKQI4nSuXgDYQKfOieBQkyAy0gExACT0nJ775wQuy92rJeAVnOMboAI4AlLhjLPt1CWJz9fDHcuIXURTl37s/HVX7D0TzA7DJT08dFc9Xr4GqQus9xszg6HFV+ItPmyZfuFi8CXH/bIz9f19u4IVjwHk7NPDhz9vT+86938Nr6N9d/k+VoxfjbAAAAAElFTkSuQmCC"},"CrashpadHandlerWindows.exe":{"pids":[13176],"memoryUsage":7.97265625,"cpuPercent":0.0,"icon":null},"wgc.exe":{"pids":[14120],"memoryUsage":61.578125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAFeUlEQVR4nL2WbUxTVxzGn3vbgtKWllcxmjiCqzLqC1NnlE3nhkKWKPNluslgvi6Z6FATl20fli2ZyT5sHzQx2T4Yl2y6kSUoZBsTtUajcYnVKEKBqqNVFCr0Ftrbll5677MPBUTEl33Zk5zkJOec/+//ds69wP8g4TnWLK8XF8/ZuGaNfUZ+fpbRbNaHQ6H4bbe76+eaGrfD4XAB6AWgAeB/hadXV1dvaWlp+eu2x+ORAgGFo+SXJOUfT4e3qanp1J7q6u0AMp/h9CPSFxQULDhz+syJUCQSJUmqGjVvJyN/nKF87AQjfzqoeTvJuEaSlKORqMPhqLfb7fOfByCWlJSUuFyu6yTJoEz52HF2r9rEu7OL2b1yE7tXb+P9N97hnRmvsbu0nPKxWjIYIkk2NzffKC0tXQFA/0TA/PnzF7TcuNFCkkr7bfoqPqY3axY9afm8t2gVY66b1FSV8S4fI43n+GDzXnrSC+ir2EWl/fYwqHVBYeGi8VInAMhsbGysJ0ml1c2u0nJ2pM6gJ8POzoJl7Pv2e2rhyEhN4r0Bdq/bTm/mLHZY8tlVWk7F5SZJnjp58ncA2WMhhqqqqqqQLMcYCvNB+U52mG30ZM3igw92j3iphsKM9/qpBWV2r00AvJML6Z1cSI9lJn3lO8mQzKAsK7t27fpobDRTnE6ngyTlo8cTh3MKGfj6ANVwovZadIA9Oz6j//Nv6P9kP71Zs+nNmUvvpLn05hQm5lmzKR89TpK8cuXKGQCTAUAEgOLiYntaRvpMxFXINXWgpiG1egusn1ZBTJkAAAgeOoLwr/WIHG9AuKYOEEVAI8S0VMCgS/hMQq6pB+Iq0jIyZi5dunTeCKSsrMxmtVoz0d2DgYuXYXrvbVj3fAjodAAApbkNoR9/g6DTQfP3gTEFIAG9DtYv9mLi8iXgoAoY9Ig5rwO+HlgtlqzVq1e/OAwRpk2bNiXdmmYYaG6DwZaH1N1bgeSkkVyGaxug+XoAnZgYggAODsJYtgLGtW/BsnMLRGNKYvNgHANtt5BmtRry8vKyAQgiANFgMBgBQIvFYKpYA8P03BGA1h+Ecq0ZjKuAMFRHVUXyy3ZY9u2AkGRA0px8THzzVXBwEBAEaKEwAECn05mRcAtUFCUKAEn2mTCVr32k7eLeTqj3fIA+kTqQEExGmCrWQRj2XhRhqlgLITkJ1DSIFhMAIBqNxgBQBACXy9UXCATi+rxpEFNNj0C03gA0qQ/CcBSCAMphBH/4Cep9X8LYyXPo238QoikFMOiRPGM6AsH+uNvt9g9DtIaGhluSJAXGXh4AYExJFHpUqoTkJJg3bUDS3JcSeyIRKDdaofr7MOGVuRCyM+Hv9fc1NjbeAqCJAHD+/Pm2rq6ujnEhogAOtSdjCsSMdFi/2gfz9o0Pow2FAQgQBBGmd8sAvQ49Pt/Ns2fPNgNDLQzgzuHDh0+FQqH4WIjOZIRoSYWQkgLThlXI/uUQzJvXP4wMgOrrASMRTFyxBMaVyxGUZfXIkSONADyjbekBFNbV1V3kGKm9EqPn/mb8XvfYpRH5Nu5k1xvrqbTeJEnW19dfAjAP47zGqTab7X2n09n5RGvjSIsOUPryO8aaWkmSV69evWuz2SoAGMdLvwAgc+HChXudTued56YoChkdGH6vvEVFRdUAJo0HGA2alJubu622tvZyf3//4PNwgrI8WFtbezk3N3crgJxRtX4qKBvAssrKyoMOh6Opra1NkiQpPtqwJEnx9vZ26fTp082VlZUHACwdOvcY4GkffuNQ2NMXL15sLyoqemHq1Kk5ZrNZH41GBzwej//ChQveS5cuXQPgBtADIPokr5+l5CHgxKEhIvH7MwAgAiAI4LHWH61/AeWTrs+9EDztAAAAAElFTkSuQmCC"},"wargamingerrormonitor.exe":{"pids":[14152],"memoryUsage":11.8671875,"cpuPercent":0.0,"icon":"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"},"TranslucentTB.exe":{"pids":[15216],"memoryUsage":47.47265625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEvElEQVR4nM2VW2xUVRSG/3XOmZkzt3ZmepkWSqNRKKBcFBMTsSCRSKLE+CBKjL4ZEyHghYjhxRhfeDAYghijUfFBwMTEkvhgSTSihouEIOFSSAkFilPSdqb0Np2Zs/dey4czQ0sHMz4Z13nZ++y9znfWXv9eC/gPjGaMw5sO/fEygsGYYQYDYAYYgAGq5+YuaxYAWChpb/KXFx/9BkABAJwKwXXdJgQCu91kY0Rr4zsCMAKwVMYEDQIJIOKvWTINMiKAbYNyQ1Ou6x4uFov9d0DguqRYJjk/GdHawAggFQh8EMCwqAAprwHwBwIQCBAH2grBY3uiWCRT2XIbIiIWkx123ChIGxD8vwV8Qqmg0BTow2N1B8EQCACCgCEgCLSEUORG5LkF1yQRGulsm9vz++XMHZCSbeeGrlzcT3agWRkDmY5AmKg+0r6oU4IcIvLAEgTAlSAgACwqImJfR8S5iqYGk5i3df7eweeat3687eiJmYkHgHAZzDPeCYDUU9+dPd6eGGjrjO+DFsf/uAhEmEWEiIQshyDiY0MRB71nBn86daDnJWcWpPD26gWNrdGGF+oibr1hLZaIKAmGuo2KKhFUnqBrYzgzeeTrnSd3JFKhSCIdvnd555xn2+bXryNLQsWCh3R77Mk1m5bNmw3BuoUdHfMbkrvuScZdTxsIM5QdwTEL8ExFcwKQIF4XuH7uaOZExfeHLy4c3HV4fXeqOdxZKirEkkGybQlasyG5fFErrRUzw7CB1goFT0Exw4iUU80QYRjWs92nwjFrVMCwHUL25uTotSsjE1WRDGftM6VGLNcltjUU+nKjW+5viW0xt2UrtzWlWCwAIQBYsb7VXrQkvTI/5j0cjNhgsAz/NbHv55PF3irIG93dJXSjrzLPbN94jgRQZUVUcqK1hlbqqTf3PP49EUw4bqda2mMrQnHHzY+Xpi6dyu75dNvJ9wGoKshsI1G2MEP7coJ/v21ozYglg+mlq9JPgwRiBJ6nwcwwxpTqG534xh0Pdny78/zZmhClAGMMDAPElUgYRECpoErDmcKA8oxyo3a8riHUSgRE4oHkfUtTm6PJwJpXPnjg+arEV5uBiEBL5fL4ECdIYGO6RnunlvWfGnjkVubWoq5PLi65ej53SGvNnqeRbossjkYD22tGAmb/CAQwEFQkLGAYkqkP3z02MWP32Okfb25+r2vlKidkpzyP0b647pmaEDY+RJcrLlckDICIZ1cM5HKFQbJIgRjMgmid3VgTYthAjA+xxY9EwAARIGJhuv7RhrfaHLc+8ao2JkVMsBzBwNV8tYTvEks5J4JA+aAAgTEGnqfWvv7RQweIyLJsOKlWd0GyJbTQCRBVSueNnsn9tY9LGRhTzokAROJDlUEsEZy7dHXzBsDvYoYZbARk+2Unczl/OBiwPq8NEZDfLwAWBpECEfn9hgjGTBd8EcByBGPZUq6/Z/yzoRt6b9fuS4M1IUf6MhcSSeqe6JAntGlye8fXQshAdLFAmd9+FVKajVGTo2pkfERlxrLFP+csjh//ctv5oTIdVer4BwvGvjrdL8l0WmkG2w5MdnBQXlveDsCr5fwvEg8AUFwsvCNj2UY2GoAD8fJZ+CXt/2F/A69pwgxiK61OAAAAAElFTkSuQmCC"},"CCXProcess.exe":{"pids":[15708],"memoryUsage":2.82421875,"cpuPercent":0.0,"icon":"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"},"WINWORD.EXE":{"pids":[15728],"memoryUsage":175.10546875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAADIElEQVR4nL2WvW8cRRiHn5nZ3fOdfXu+ONKdFdvgryhIji1HlmgACwKigChFhISUAqQUhApR0FJAmb8gJRU0NAiJKgoNEkiW+BJEYEiiOIk/yFq27/Z293ZnhuKS4ghr1heJV5pmftL7zPt7Ne8M/A8h8oQzH197yZ9eWgAJmMGyS5dw45fAydOHm7Mfev7YqtV6MAAAgvLxSXIhbqXm6jjCpPETQMCp+PkQKzBCCBA5jlpbCGKNzoeYpK0xKabbX4lFAAJVKnNIS/tCjJ375FPHn5z458m8ilpUjvL79y2eekB9+gSV8ZOFAACO50+9mRpFkhkqJYUSkGSWMIgpewIlBVHXkGnLSLlEHO5g0pSwXS1smeymmoUpj3debVAbMkRxzOmpEpdfm6Q27JJklrPLx3n39SmE7PXIGnukJZNMszI/ypVLp1ia8bHW8vbLJ7hy6RRn5mpIIXjv/FN8cGGm6MEfr8SRkptbHfbDjJV5n5lmhZV5H4AXl47RqHvURzyu/7SLZTCKVBI2g5idvYSlaZ+nGxXmxodpR70KZ8crNOseP9866FUiQEhxpOU4SnJ7O2Zzt8vybJXVxTp3H8Rc+zHgleUxLjzX5FjV5YebLawFk2qivQ6m1C7ceEcIaEUZ65shL5yu89bZCT7/ZourX23wxvNNzj/bIGil3A1ihBToribrdshUGwraJwEcR/DbRogxlmrFYW19nz/ud7i1HTE64nBjI6ST6N7VG8CuHkTC7/dCpBTcCyLW1vdREr78bgeA29sdwkjnTpj/tAtAScmvd1q8f/UGu+2U+0GCqwRffLtDK8r4/s8DMmNQKncKHRqiefG6FdLBWIgSjRSCoZJEWEumDXFq8ByB50iEdEm21gCBO/YMRXvipAd3Pns0u8pub9NqyNqbi+jULz1MlCLAGrrBOtZ66KT4ncl12Zs597WUahXb/yoKNYQzOocqNwpDck0u1U4qpAKb9QsWpFt9eL6CduUJsjohpXSxJn1cFLIwACEPeRl1kgrPB+v9m1oMgMAke/kQHf31kVSVBXiCj4RUZMluMHiCI8Tf6yxaSSuCIasAAAAASUVORK5CYII="},"node.exe":{"pids":[15732],"memoryUsage":43.88671875,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAEYUlEQVR4nJ1WTWhUVxT+zr1vXmKiGWcyiSadGJsqoSDVVmusdhWwu0ILtVDJxoW4KXQhLbTQbXct3VoXUhAR3HQjFERooRVjDLTFkCbGmpRoMklmJjOZ9+a9d39OF5mZjOkkmfYsHryZe853vnO+c+4jNG904v1jJzr27jqZWyg++O3HiYcAuBlHp5lD+wbjB09/cPx8V1/qQlu87dDS/OpMaiBxbez24xuFuczsjtnt8H/78KWj515+o/9SomvvUEtLK0VlC2UtCislLmW90WeTS1fu3Ri7BcD7ryDOsffSZwaHX7ncfaDz7O62Pa2kJExEMJpgrEUQRDDaQgUqyD8v3Hl8f+6bibtTvwDQO4K89uHAkb7XExd7BhMjHYmOpFAuhHYgTAysBYwGjLGIlEEYKBARHEfAK5Rzy09z159NLFz9486fjxqCpFLoOf7x0ZGuw3suxHvbX3WEA4pikMaFtG4dCMEYC20MolBDKwMShFhMghlYW1mbXJlbvTZ+c+z6yoq/UA+SfOfL09/2n2r/qC3hODqyEMaBtFuBGGhjobVFFCoAgCCClAKxFgdRoPT8k8zN21/d/QRATgBAZ39nd8xtHxJodXRkK8LkSg5ba4MEICSBGWAGrLVQkQG1CMeX0Um3Z3c3AAgAYJcJIONnJWy0k+A2CsAMkCAwGJZ5HcwysqUivCAwrrt+UGxkZaAjICgIgGgbAgyuzCBVnkwMay2YgXIUYdX3wADciodA9cVhQABBUUCH1TIxmhlqBkOxgbYWxcCDtgYShKgeBKgkLxnGAGGRQLXgmykRqFquul81a3iqjLKO4JCAkLXQ9eUCIC1IMkqrFn6JQQ1L1ogdwTIjUBEIgCMlpBBwKwXbgHMshASYGIVCiOXFENZuzvdFZptzsGAQEaSQECRqTVkHcSseghEECmGkUchplNY0SGwOtU2PCDBsIUhAyo3dKwCsN0gCmg08LwIzYAxjKVOG0XZLoTXiqK2FtgYOBKqdr6mLJMMvaShl10VAQLGokF8NQf9qzjYDCkaoIzAsXLeuJ0TEQVlJ339xgRpjsbziI1S6TgRb96Seoa9DqUhxDWThUXYp97f/ICiEWjii5k0grJVC5PJ+XcCNYWxAA8IRCL1Qe3lvLDudXa6BAMiNfTf9WX4q/7mX8SZRWRdEADMjkyvBDxWqdKqA9VBU2WHeoj+Zm8x/MX1r5lMA2YaM02+lj8QPd1yM98VH3A43yXZ9Lx3oTiKd6oJRqK16YywMMyKjkF0q5Bb/Wr7+fCpzdf7n+cb3ySZz0qf2n0kd23e5bX/b2diuWKsrHQy+1ItdsVZobWCYYRnwi36wOJu9M33/ydczP83+imZuxk3WPvDuwLnk4cSllnjLULq3i/oSKZAQKBXLvLpUHJ2bWLhy7/v/d8e/YPH++MHet/ef7+xPXhg8dOAQeXZm4Wn22sPb4zcyU4XZnfybAqmeTQ+n3+zpTg7ZgEbHf/h9DE1+d/0DuEc4OFunhrwAAAAASUVORK5CYII="},"CPUMetricsServer.exe":{"pids":[15892],"memoryUsage":2.34765625,"cpuPercent":0.0,"icon":null},"msedgewebview2.exe":{"pids":[16676,17288,17368,17768,17924,17964,19208,19364],"memoryUsage":290.3203125,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAADS0lEQVR4nO2Vy3IcRRBFz82q7tbIGmy0YMsOfoAlCzb8BFt/Anv8JV6y5BMIL+wAgoeDhx8EtsN6ISQb6zkaTb8qWVRrRmMIbK8hIzo6sirr3pu3M7rg/3iD0MqHn34W3/3gOn0H7kDKOz68ceQOyec5zrxWfnndF29BIFD/8eNNrX3yea7yAewChAQOWjq8ANPLoJcFXeSD0JjOZ5cWND+4rJAF4FzQy+o1dMa8xsl1+ujOvoMj+sGqHqlD9MNaC94hWqQO6DBa8BZoMTWIJu9TA+2Q10gN8oa4/v47+ePgQA90A0kGZg7QIOXcBhCoCTKEEOQzoUM4pn4QMCOmdvCSfiDpkfqhk5QtuHiUhm7TIMpRcMwcKSGSp6n33uLNrMhWEYivMYHLIbJqgXBvT/ruaBcOno+K85OSbiY8GW0bJAq3snhNEoGZEHjXJNWHXff7wyl7WynOTqrQ+xV1jHCizBRkoGAyE9aUryaxaKgnne6f63DztN+8fxYOniliI1RUWDWyWAa3etrb9ASbHNTtyVHozqZVqmdg/0ZiIgg/3p2knZ9fsPvoTMeHivHKVcLaCooFoYiuyYvedzbF0Z9eHx9HLK5SrIAV2MoI7B/skoSZUb846u59vRv2ns40mZhZdY1ivUJFgULEmmnPw7ueDvbM69ooVrHVdQgFKADCLYDZMolFo5/N0tbdHX79ajdM61KqxorjMh+OEbzzsP2g8Y0HpfcuYpXBFSAEXCFPBQZmgBYkIcoPNp77ozubvv14GsLqVexKhWIEywChm3Z6fNd9f6tUsSqqlbxncRi5DJqfRUQE5iltfLPBg9sbms5Ks/HbGTzErMpEbCZtuHdLfjYprBznzixkS8TfgJdI+rpJD289So9/2I99OcbWLtTZ4KERmrM2/PKlMZkEG70FlgmyLa+O+N0X99jbOI+MrqFYgg1+XhC0sy7cvx2YTEwrY2QRl70W+Jxkb6c3RmsohMHTISTUtx6efItOD82qtcG+NyMAiFSri9a19M+g2PvNw7PtaNUYQpknSMOHnddfXrPswlIOkSe3bvDex9dJ7VAw7HvXh6c/mUIpJ98V+ToRjvL9IeHyxVQp4VyesJJu+/ubb9z6fzv+AslupPi8HMpIAAAAAElFTkSuQmCC"},"AdobeIPCBroker.exe":{"pids":[16788],"memoryUsage":8.34765625,"cpuPercent":0.0,"icon":"iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAFQUlEQVR4nJWUz28dVxXHP+femedn106cxo2Cm9QQ4gSwS6BCLRCx6KKlVbfQTVf9E/oHsGMDYoPEim66YsGmCKFKCFQkfog2kBInsVWrjk1Sh9h5cZ6f7ffezNx7z2Ex45cWpWo4o9FczYzu935/nCPffvGHj7/80vcWzp46bsNBcFm7Te6c5FlGnuciIpK12+Qikue5AJiZFUVBMDMLwWKMVGYWhxHzarlz/ddefXUJSIBlhQ/P3Q/6zpNz851jU5M4kTxvtVzmvW/luc+8z7I892OtlrTH23jnCCFQlCVlWaUQgibVVIUqxphSjInhcHgTeA6IgGR3t+4ceW95laHLpo4/8YSKiPPOi3dOnBfxzuGcV+ecOBFBBDMjqZqqoilJMvOa1KkmS6oURfnUKz/6yduDvf03//TzH7+debOxGCM373Xb95IgIiAOoy5xDicOBARABFXFzGrpVHENsJlhqpimsfGjj7806O5eBn6bAYgp3jnLnAOQicxxpJXhnEMEagIyAml8wQzKUNEZVojzYKAISbFYlRKqwgOtTBUa2qgqVYj27NycvLhwdrShc0J91evD9wL0Dvq8c/k6V7Z3yfMMTcnUzIwklioP+AwSmhKpuUOoODEzwxfPnKEIESdC5n0DVLNqhANgVpXp6Wnkj3/mg60uAiQzENBU/5MBoIqqkmIkpcTO3j6DssLMiGZ0dvcYhgpByDKPiGskUzAQ3+K7FxbpHFxivXuACGIiKNqAJDBNaIqkFBGMDzdu2ZVTJ+WZ+TPsD4e89e7fuNs7YHpqgs2dLt7XZ7PmcKpKiInFE9OcVmN9p2feiWiMNUii9kJDRGOgKgPzJ2fEypIrN/5tZ2dPStE/YL+7gwsF+/e7jWS1aIepGpYlp58+R97KWf3PNpK3GIGQtPZDIylGQlVybPoo31o4z/vXV+TDm5v2+vefl35RIID3HkYBf7A0M45NTfHL3/0BjZEkgqb0wBNTxULEYsSZsfbxbfrPXOAb5+dZWl2T3/9jyYKpAOQ+OwwXZoaamZmBGu3csdXpIKqiIYKO5AJLTcJixFJia+uOXbq2zMVvfl3Ozj3Fu6sbsl8Ejh+ZZG3zdsOGw+YTVWVYVrywOM+JqcdsY/OOZa1MTEfGPwBIIVIMC55d+Jqcnpnm70vXbfHcl0VSpHuvQxwcUOztjzzBaiCAoiiZHG8z3h4jhQrnIFahAdFUpyRFNARSqFCMr56bp7i2ItdWP7LXnr8ooTHRN/E9tEMAExAzfJbx/gdLmEY0CIyYQN3tMaIpkDv46+UrfOfpBRa/co6VtTX5zV/es25/iHOOPPMjJmYP0qVmjItx995dUJUUA5pqEJeacaIporFCTFld37Bf/OrXttPb49Tsk+wlZOByGT86LR91D2S9N5AbvYGs7/blxu6BrHX3ZXn7vpycnZW5EzNUZWEaI7Fh7+p01UxSqO9MhH9eXeanb75l3d4ej2We/u59OtvbZFWBFANcMcCVQ3xVkIeKVig5OjFBnrdIVUSrAPHQE7T2JEY0RKwJfuaES1evU4VgP3j5Bbl4/gxq9Vh/WAlCGQIbH28ilrBYD16ATDE5ND6l0KSlnrm5c1xdWeVf15YPQ/TQsk80ZyvL8CKSUiClqgYZdnZujY1PLY1PTl4IZWlmxv+e9dNz97OA6oqhbIamA60bOCv7vfXO2srP2pOTb1ia/BLWtOmnUB4C8RnUrPkmPnOpDHtAEmAK+AIwCxwD/Occ+lGrB9wCbgt1wtrARPP8PGUetQLQB4af3PBRpP9/6lBP+y+G9WAm6i47bQAAAABJRU5ErkJggg=="},"Taskmgr.exe":{"pids":[17300],"memoryUsage":53.921875,"cpuPercent":0.091666666666666674,"icon":null},"ai.exe":{"pids":[18048],"memoryUsage":17.83203125,"cpuPercent":0.0,"icon":null},"FileCoAuth.exe":{"pids":[18128],"memoryUsage":19.0625,"cpuPercent":0.0,"icon":null},"cncmd.exe":{"pids":[18236],"memoryUsage":0.9296875,"cpuPercent":0.0,"icon":null},"cmd.exe":{"pids":[18308],"memoryUsage":1.1484375,"cpuPercent":0.0,"icon":null},"AMDRSSrcExt.exe":{"pids":[18888],"memoryUsage":8.65234375,"cpuPercent":0.0,"icon":null},"amdow.exe":{"pids":[18972],"memoryUsage":1.109375,"cpuPercent":0.0,"icon":null},"UserOOBEBroker.exe":{"pids":[21412],"memoryUsage":9.7890625,"cpuPercent":0.0,"icon":null},"obs64.exe":{"pids":[22032],"memoryUsage":308.15234375,"cpuPercent":0.65833333333333333,"icon":"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"},"SDXHelper.exe":{"pids":[22336],"memoryUsage":21.3203125,"cpuPercent":0.0,"icon":null}},"isAdminstrator":true,"networkInterfaces":[{"name":"Ethernet","description":"Realtek PCIe GbE Family Controller","status":"Up","id":"{5086B0D1-0C15-4067-8C3D-BBA986779FC6}","bytesSent":144782490,"bytesReceived":277001103,"isPrimary":true},{"name":"Bluetooth Network Connection","description":"Bluetooth Device (Personal Area Network)","status":"Down","id":"{52CB9306-EC27-4329-BF6F-A0C85394DB0F}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Loopback Pseudo-Interface 1","description":"Software Loopback Interface 1","status":"Up","id":"{9AE817B5-ADA1-11EE-8F82-806E6F6E6963}","bytesSent":0,"bytesReceived":0,"isPrimary":false}],"primaryNetworkSpeed":{"download":112918,"upload":9228}},"charts":{"gpuLoad":[0.0,0.0,0.0,0.0,0.0,0.0,15.0,0.0,0.0,2.0,11.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,76.0,11.0,1.0,11.0,11.0,11.0,0.0,0.0,3.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"gpuTemperature":[46.0,47.0,47.0,47.0,47.0,47.0,45.0,45.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0,44.0],"gpuPower":[32.0,33.0,33.0,32.0,33.0,33.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,18.0,17.0,17.0,17.0,18.0,18.0,17.0,17.0,17.0,17.0,17.0,18.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,17.0,19.0,18.0,17.0,17.0,17.0,19.0,17.0,18.0,18.0,18.0,17.0,17.0,17.0,17.0,17.0,18.0,18.0],"cpuLoad":[40.0,40.0,33.0,28.0,27.0,32.0,36.0,32.0,28.0,27.0,24.0,25.0,24.0,23.0,28.0,26.0,32.0,25.0,28.0,34.0,40.0,46.0,42.0,85.0,87.0,90.0,53.0,31.0,35.0,41.0,36.0,42.0,33.0,37.0,46.0,58.0,35.0,29.0,30.0,26.0,24.0,27.0,26.0,26.0,30.0,26.0,25.0,24.0,28.0,33.0,30.0,36.0,38.0,41.0,47.0,28.0,27.0,25.0,25.0,40.0],"cpuTemperature":[59.0,59.0,59.0,59.0,59.0,58.0,59.0,58.0,58.0,58.0,58.0,58.0,58.0,58.0,58.0,58.0,58.0,57.0,57.0,58.0,58.0,59.0,59.0,60.0,61.0,61.0,61.0,62.0,61.0,61.0,61.0,62.0,62.0,62.0,62.0,63.0,62.0,62.0,63.0,63.0,62.0,62.0,62.0,61.0,61.0,61.0,60.0,60.0,60.0,60.0,59.0,59.0,59.0,59.0,60.0,60.0,59.0,59.0,59.0,59.0],"ramPercentage":[83,83,83,83,83,83,83,83,82,82,82,82,82,82,82,82,82,75,74,75,75,76,78,80,81,82,82,82,84,86,87,82,83,82,83,83,84,84,84,83,83,83,83,83,83,83,83,83,83,83,83,83,84,85,85,85,85,85,85,85],"networkDownload":[0.0008535385131835938,0.0008840560913085938,0.0008840560913085938,0.031821250915527344,0.004817962646484375,0.22439193725585938,0.22620201110839844,0.008440971374511719,0.008550643920898438,0.0035734176635742188,0.0035467147827148438,0.0033626556396484375,0.0008087158203125,0.0008087158203125,0.008632659912109375,0.009138107299804688,0.005096435546875,0.007914543151855469,0.007994651794433594,0.004723548889160156,0.26020145416259766,0.27307891845703125,0.10526084899902344,0.7745761871337891,0.04332447052001953,0.0054111480712890625,0.0054111480712890625,0.0011959075927734375,0.0061397552490234375,0.012890815734863281,0.009558677673339844,1.821925163269043,1.8225908279418945,0.00930023193359375,0.22333431243896484,0.22333431243896484,0.0,0.0006618499755859375,0.0007696151733398438,0.0007696151733398438,0.026775360107421875,0.06626319885253906,0.08298301696777344,0.08085823059082031,0.29531383514404297,0.25989818572998047,0.25989818572998047,0.0,0.003528594970703125,0.05320549011230469,0.4700746536254883,0.4528799057006836,0.09303760528564453,0.6626214981079102,1.3438539505004883,0.7765035629272461,0.049775123596191406,0.049775123596191406,0.0036020278930664062,0.017278671264648438],"networkUpload":[0.0097198486328125,0.009886741638183594,0.009886741638183594,0.009754180908203125,0.008761405944824219,0.019733428955078125,0.02032470703125,0.04044914245605469,0.039923667907714844,0.015285491943359375,0.015125274658203125,0.008319854736328125,0.00910186767578125,0.00910186767578125,0.004847526550292969,0.049714088439941406,0.036041259765625,0.012986183166503906,0.009778976440429688,0.008967399597167969,0.013369560241699219,0.03366279602050781,0.039183616638183594,0.028082847595214844,0.003956794738769531,0.002960205078125,0.002960205078125,0.00299835205078125,0.0044727325439453125,0.0059566497802734375,0.016800880432128906,0.06907463073730469,0.06229686737060547,0.008917808532714844,0.006305694580078125,0.006305694580078125,0.0,0.0007495880126953125,0.00038814544677734375,0.00038814544677734375,6.266390800476074,21.593141555786133,31.775513648986816,33.58159160614014,28.895753860473633,11.763664245605469,11.763664245605469,0.0,0.0046234130859375,0.014148712158203125,0.03253173828125,0.026192665100097656,0.020264625549316406,0.0386962890625,0.11277580261230469,0.0977935791015625,0.011799812316894531,0.011799812316894531,0.0016374588012695312,0.0032863616943359375]},"taskmanagerData":[{"pids":[4],"name":"System","memoryUsage":0.0234375,"cpuPercent":0.0875},{"pids":[172],"name":"Registry","memoryUsage":40.55859375,"cpuPercent":0.0},{"pids":[544],"name":"smss.exe","memoryUsage":0.2265625,"cpuPercent":0.0},{"pids":[680,1028],"name":"fontdrvhost.exe","memoryUsage":4.99609375,"cpuPercent":0.0},{"pids":[724,844],"name":"csrss.exe","memoryUsage":5.8515625,"cpuPercent":0.0},{"pids":[852],"name":"wininit.exe","memoryUsage":1.1796875,"cpuPercent":0.0},{"pids":[948],"name":"winlogon.exe","memoryUsage":4.97265625,"cpuPercent":0.0},{"pids":[964,12448],"name":"task_manager.exe","memoryUsage":53.3828125,"cpuPercent":0.08125},{"pids":[992],"name":"services.exe","memoryUsage":7.06640625,"cpuPercent":0.0},{"pids":[1000],"name":"lsass.exe","memoryUsage":13.83984375,"cpuPercent":0.0},{"pids":[1084],"name":"WUDFHost.exe","memoryUsage":3.30078125,"cpuPercent":0.0},{"pids":[1268],"name":"dwm.exe","memoryUsage":66.58203125,"cpuPercent":0.25625},{"pids":[1456],"name":"RTSS.exe","memoryUsage":2.4921875,"cpuPercent":0.0},{"pids":[1472,3808,7216,10288,13120,15936,18576],"name":"msedge.exe","memoryUsage":366.01953125,"cpuPercent":0.0},{"pids":[1672,7348,8404,8548,10628,13544,15440,16472],"name":"RuntimeBroker.exe","memoryUsage":93.21875,"cpuPercent":0.0},{"pids":[1684],"name":"ServiceHub.IndexingService.exe","memoryUsage":45.66796875,"cpuPercent":0.0},{"pids":[1780,2920,8368,12036,14396,14400,14668,15712],"name":"steamwebhelper.exe","memoryUsage":351.8359375,"cpuPercent":0.0},{"pids":[2092,3912,7256,8336,8464,12936,15832,17436,17912],"name":"Code.exe","memoryUsage":1016.11328125,"cpuPercent":0.42500000000000004},{"pids":[2128],"name":"helperservice.exe","memoryUsage":0.32421875,"cpuPercent":0.0},{"pids":[2216],"name":"atiesrxx.exe","memoryUsage":1.81640625,"cpuPercent":0.0},{"pids":[2224],"name":"amdfendrsr.exe","memoryUsage":1.79296875,"cpuPercent":0.0},{"pids":[2472],"name":"atieclxx.exe","memoryUsage":7.1171875,"cpuPercent":0.0},{"pids":[2604],"name":"MemCompression","memoryUsage":425.015625,"cpuPercent":0.0},{"pids":[2724,2728,3980,5852,6272,7664,8516,10592,10760,11028,11832,12196,12488,13000,16672],"name":"firefox.exe","memoryUsage":3064.0625,"cpuPercent":3.04375},{"pids":[2952],"name":"Video.UI.exe","memoryUsage":3.6171875,"cpuPercent":0.0},{"pids":[3268],"name":"spoolsv.exe","memoryUsage":5.04296875,"cpuPercent":0.0},{"pids":[3300],"name":"PresentMonService.exe","memoryUsage":1.4296875,"cpuPercent":0.0},{"pids":[3316],"name":"vmnat.exe","memoryUsage":2.08984375,"cpuPercent":0.0},{"pids":[3332],"name":"vmware-usbarbitrator64.exe","memoryUsage":3.16015625,"cpuPercent":0.0},{"pids":[3364],"name":"Microsoft.ServiceHub.Controller.exe","memoryUsage":62.44140625,"cpuPercent":0.0},{"pids":[3408],"name":"WindscribeService.exe","memoryUsage":1.28515625,"cpuPercent":0.0},{"pids":[3556],"name":"TunnelBear.Maintenance.exe","memoryUsage":9.4296875,"cpuPercent":0.0},{"pids":[3752],"name":"MSIAfterburner.exe","memoryUsage":6.8203125,"cpuPercent":0.0875},{"pids":[3784,13492,17544],"name":"taskhostw.exe","memoryUsage":39.7734375,"cpuPercent":0.0},{"pids":[4072],"name":"vmware-authd.exe","memoryUsage":1.78125,"cpuPercent":0.0},{"pids":[4128],"name":"MsMpEng.exe","memoryUsage":257.45703125,"cpuPercent":0.0},{"pids":[4260],"name":"dasHost.exe","memoryUsage":11.171875,"cpuPercent":0.0},{"pids":[5320],"name":"EncoderServer64.exe","memoryUsage":0.71875,"cpuPercent":0.0},{"pids":[5588,6188,7196,12340,19892,20192],"name":"dart.exe","memoryUsage":2207.81640625,"cpuPercent":0.0875},{"pids":[5956],"name":"BraveCrashHandler64.exe","memoryUsage":0.25390625,"cpuPercent":0.0},{"pids":[6128],"name":"ServiceHub.Host.dotnet.x64.exe","memoryUsage":80.35546875,"cpuPercent":0.0},{"pids":[6168,18564],"name":"WmiPrvSE.exe","memoryUsage":37.109375,"cpuPercent":0.3375},{"pids":[6312,9388,13484,17668],"name":"powershell.exe","memoryUsage":80.1328125,"cpuPercent":0.0},{"pids":[6340],"name":"sihost.exe","memoryUsage":21.83203125,"cpuPercent":0.0},{"pids":[6484],"name":"gamingservicesnet.exe","memoryUsage":1.02734375,"cpuPercent":0.0},{"pids":[6492],"name":"gamingservices.exe","memoryUsage":20.1015625,"cpuPercent":0.0},{"pids":[6516],"name":"SearchIndexer.exe","memoryUsage":48.23046875,"cpuPercent":0.0},{"pids":[6556],"name":"ServiceHub.Host.AnyCPU.exe","memoryUsage":106.31640625,"cpuPercent":0.0},{"pids":[6780],"name":"RTSSHooksLoader64.exe","memoryUsage":0.80078125,"cpuPercent":0.0},{"pids":[6884],"name":"ShellExperienceHost.exe","memoryUsage":40.45703125,"cpuPercent":0.0},{"pids":[6940],"name":"ctfmon.exe","memoryUsage":20.14453125,"cpuPercent":0.0},{"pids":[6984,7136],"name":"explorer.exe","memoryUsage":227.82421875,"cpuPercent":0.0875},{"pids":[7028],"name":"AMDRSSrcExt.exe","memoryUsage":105.23828125,"cpuPercent":0.0},{"pids":[8100],"name":"ApplicationFrameHost.exe","memoryUsage":15.265625,"cpuPercent":0.0},{"pids":[8124],"name":"Microsoft.Notes.exe","memoryUsage":46.09765625,"cpuPercent":0.0},{"pids":[8300],"name":"StartMenuExperienceHost.exe","memoryUsage":54.6171875,"cpuPercent":0.0},{"pids":[8448,10892,11324,13472,16256,18364],"name":"cmd.exe","memoryUsage":24.734375,"cpuPercent":0.0},{"pids":[8476],"name":"SearchFilterHost.exe","memoryUsage":7.4140625,"cpuPercent":0.0},{"pids":[8512],"name":"SystemSettingsBroker.exe","memoryUsage":6.0703125,"cpuPercent":0.0},{"pids":[8560],"name":"amdow.exe","memoryUsage":1.22265625,"cpuPercent":0.0},{"pids":[8956],"name":"NisSrv.exe","memoryUsage":7.6953125,"cpuPercent":0.0},{"pids":[8992],"name":"SearchApp.exe","memoryUsage":74.7421875,"cpuPercent":0.0},{"pids":[9068],"name":"ServiceHub.VSDetouredHost.exe","memoryUsage":85.44140625,"cpuPercent":0.0},{"pids":[9188],"name":"steamservice.exe","memoryUsage":2.5390625,"cpuPercent":0.0},{"pids":[9764,13236,14260,15412,16796,17272],"name":"Discord.exe","memoryUsage":445.44921875,"cpuPercent":0.0},{"pids":[10012],"name":"PerfWatson2.exe","memoryUsage":65.59765625,"cpuPercent":0.0},{"pids":[10820],"name":"SystemSettings.exe","memoryUsage":0.54296875,"cpuPercent":0.0},{"pids":[10936],"name":"BraveCrashHandler.exe","memoryUsage":0.95703125,"cpuPercent":0.0},{"pids":[10988],"name":"UserOOBEBroker.exe","memoryUsage":4.44140625,"cpuPercent":0.0},{"pids":[11492],"name":"dllhost.exe","memoryUsage":9.32421875,"cpuPercent":0.0},{"pids":[12040],"name":"cncmd.exe","memoryUsage":0.90234375,"cpuPercent":0.0},{"pids":[12500],"name":"RadeonSoftware.exe","memoryUsage":44.3984375,"cpuPercent":0.0},{"pids":[12720],"name":"TextInputHost.exe","memoryUsage":65.76953125,"cpuPercent":0.0},{"pids":[13172],"name":"CompPkgSrv.exe","memoryUsage":1.4375,"cpuPercent":0.0},{"pids":[13536,17628],"name":"adb.exe","memoryUsage":12.21484375,"cpuPercent":0.0},{"pids":[14124],"name":"SearchProtocolHost.exe","memoryUsage":13.4921875,"cpuPercent":0.0},{"pids":[14208],"name":"advinst.exe","memoryUsage":110.296875,"cpuPercent":0.0},{"pids":[14348],"name":"audiodg.exe","memoryUsage":10.45703125,"cpuPercent":0.25625},{"pids":[14448],"name":"java.exe","memoryUsage":1273.734375,"cpuPercent":0.0},{"pids":[14516],"name":"AMDRSServ.exe","memoryUsage":23.96484375,"cpuPercent":0.0},{"pids":[14684],"name":"ServiceHub.SettingsHost.exe","memoryUsage":78.27734375,"cpuPercent":0.0},{"pids":[14980],"name":"Taskmgr.exe","memoryUsage":41.35546875,"cpuPercent":0.0875},{"pids":[15444],"name":"devenv.exe","memoryUsage":803.45703125,"cpuPercent":0.0},{"pids":[15552],"name":"WOMicClient.exe","memoryUsage":2.6953125,"cpuPercent":0.0},{"pids":[15656],"name":"ServiceHub.Host.netfx.x86.exe","memoryUsage":62.7265625,"cpuPercent":0.0},{"pids":[15696],"name":"zal.exe","memoryUsage":83.421875,"cpuPercent":0.0},{"pids":[15796],"name":"SecurityHealthService.exe","memoryUsage":2.890625,"cpuPercent":0.0},{"pids":[15948],"name":"ServiceHub.RoslynCodeAnalysisService.exe","memoryUsage":243.90234375,"cpuPercent":0.0},{"pids":[16016],"name":"CalculatorApp.exe","memoryUsage":1.30078125,"cpuPercent":0.0},{"pids":[16208],"name":"LockApp.exe","memoryUsage":22.078125,"cpuPercent":0.0},{"pids":[16628],"name":"XboxPcAppFT.exe","memoryUsage":4.17578125,"cpuPercent":0.0},{"pids":[16700],"name":"ServiceHub.ThreadedWaitDialog.exe","memoryUsage":90.6484375,"cpuPercent":0.0},{"pids":[16712],"name":"ServiceHub.IntellicodeModelService.exe","memoryUsage":568.05859375,"cpuPercent":0.0},{"pids":[16840],"name":"steam.exe","memoryUsage":46.26171875,"cpuPercent":0.0},{"pids":[17168],"name":"ServiceHub.TestWindowStoreHost.exe","memoryUsage":68.5,"cpuPercent":0.0},{"pids":[17208],"name":"ServiceHub.IdentityHost.exe","memoryUsage":64.99609375,"cpuPercent":0.0},{"pids":[17256],"name":"SgrmBroker.exe","memoryUsage":5.32421875,"cpuPercent":0.0},{"pids":[19832],"name":"zal-console.exe","memoryUsage":115.06640625,"cpuPercent":0.83125},{"pids":[20132],"name":"zal-server.exe","memoryUsage":29.49609375,"cpuPercent":0.08125}]}
""";
    var parsedData;
    try {
      parsedData = jsonDecode(data.replaceAll("'", '"'));
    } catch (c) {
      print(c);
    }

    rawData = parsedData;
    charts = parsedData.containsKey("charts") ? Map<String, List<dynamic>>.from(parsedData['charts']) : {};
    final computerData = parsedData['computerData'];
    isRunningAsAdminstrator = computerData['isAdminstrator'];
    processesGpuUsage = computerData["processesGpuUsage"] == null
        ? null
        : Map<String, double>.from(computerData["processesGpuUsage"]).map((key, value) => MapEntry(int.parse(key), value));
    if (computerData['ramData'] != null) {
      ram = Ram.fromMap(computerData['ramData']);
    } else {
      ram = Ram.nullData();
    }
    if (computerData['cpuData'] != null) {
      cpu = Cpu.fromMap(computerData['cpuData']);
    } else {
      cpu = Cpu.nullData();
    }

    if (computerData['gpuData'] != null) {
      gpus = List<Gpu>.from(List<Map<String, dynamic>>.from(computerData['gpuData']).map((e) => Gpu.fromMap(e)).toList());
    } else {
      gpus = [Gpu.nullData()];
    }
    if (computerData['motherboardData'] != null) {
      motherboard = Motherboard.fromMap(computerData['motherboardData']);
    } else {
      motherboard = Motherboard.nullData();
    }
    if (computerData['batteryData'] != null) {
      battery = Battery.fromMap(computerData['batteryData']);
    } else {
      battery = Battery.nullData();
    }
    //battery = Battery(isCharging: true, batteryPercentage: 60, lifeRemaining: 94, hasBattery: true);
    if (computerData['storagesData'] != null) {
      storages = List<Map<String, dynamic>>.from(computerData['storagesData']).map((e) => Storage.fromMap(e)).toList();
    } else {
      storages = [Storage.nullData()];
    }
    storages.sort((a, b) => a.diskNumber.compareTo(b.diskNumber));
    if (computerData['monitorsData'] != null) {
      monitors = List<Map<String, dynamic>>.from(computerData['monitorsData']).map((e) => Monitor.fromMap(e)).toList();
    } else {
      monitors = [Monitor.nullData()];
    }
    if (computerData['primaryNetworkSpeed'] != null) networkSpeed = NetworkSpeed.fromMap(computerData["primaryNetworkSpeed"]);
    if (parsedData.containsKey("taskmanagerData") && parsedData['taskmanagerData'] != null) {
      taskmanagerProcesses = List<Map<String, dynamic>>.from(parsedData['taskmanagerData']).map((e) => TaskmanagerProcess.fromMap(e)).toList();
    }
    if (computerData.containsKey("networkInterfaces")) {
      networkInterfaces = List<Map<String, dynamic>>.from(computerData['networkInterfaces']).map((e) => NetworkInterface.fromMap(e)).toList();
    }
  }
}

///we use this class to store the computer specs
class ComputerSpecs {
  String motherboardName;
  String ramSize;
  List<String> gpusName;
  String cpuName;

  List<String> storages;
  List<String> monitors;
  ComputerSpecs({
    required this.motherboardName,
    required this.ramSize,
    required this.gpusName,
    required this.cpuName,
    required this.storages,
    required this.monitors,
  });
  factory ComputerSpecs.fromComputerData(ComputerData data) {
    return ComputerSpecs(
      motherboardName: data.motherboard.name,
      ramSize: "${(data.ram.memoryAvailable + data.ram.memoryUsed).toStringAsFixed(2)}GB",
      gpusName: data.gpus.map((e) => e.name).toList(),
      cpuName: data.cpu.name,
      storages: data.storages.map((e) => '${(e.totalSize / 1024 / 1024 / 1024).round()} GB ${e.type}').toList(),
      monitors: data.monitors.map((e) => '${e.width} x ${e.height}${e.primary ? ' primary' : ''}').toList(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'motherboardName': motherboardName});
    result.addAll({'ramSize': ramSize});
    result.addAll({'gpusName': gpusName});
    result.addAll({'cpuName': cpuName});
    result.addAll({'storages': storages});
    result.addAll({'monitors': monitors});

    return result;
  }

  factory ComputerSpecs.fromMap(Map<String, dynamic> map) {
    return ComputerSpecs(
      motherboardName: map['motherboardName'] ?? '',
      ramSize: map['ramSize'] ?? '',
      gpusName: List<String>.from(map['gpusName']),
      cpuName: map['cpuName'] ?? '',
      storages: List<String>.from(map['storages']),
      monitors: List<String>.from(map['monitors']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ComputerSpecs.fromJson(String source) => ComputerSpecs.fromMap(json.decode(source));
}

class Storage {
  final int diskNumber;
  final int totalSize;
  final int freeSpace;
  final int temperature;
  final int readRate;
  final int writeRate;
  final String type;
  final List<Partition>? partitions;
  final Map<String, dynamic> info;
  final List<SmartAttribute> smartAttributes;
  Storage({
    required this.diskNumber,
    required this.totalSize,
    required this.freeSpace,
    required this.temperature,
    required this.readRate,
    required this.writeRate,
    required this.type,
    required this.partitions,
    required this.info,
    required this.smartAttributes,
  });
  String getDisplayName() {
    return "${truncateString(partitions?.firstOrNull?.label ?? type, 10)} | ${totalSize.toSize(decimals: 0)}";
  }

  factory Storage.fromMap(Map<String, dynamic> map) {
    List<Partition>? partitions;
    if (map.containsKey("partitions") && map['partitions'] != null) {
      partitions = List<Partition>.from(map['partitions']?.map((x) => Partition.fromMap(x)))..sort((b, a) => a.size.compareTo(b.size));
    }
    return Storage(
      diskNumber: map['diskNumber']?.toInt() ?? 0,
      totalSize: map['totalSize']?.toInt() ?? 0,
      freeSpace: map['freeSpace']?.toInt() ?? 0,
      temperature: map['temperature']?.toInt() ?? 0,
      readRate: map['readRate']?.toInt() ?? 0,
      writeRate: map['writeRate']?.toInt() ?? 0,
      type: map['type'] ?? '',
      partitions: partitions,
      smartAttributes: List<Map<String, dynamic>>.from(map['smartAttributes']).map((e) => SmartAttribute.fromMap(e)).toList(),
      info: map["info"],
    );
  }
  factory Storage.nullData() {
    return Storage(
      diskNumber: -1,
      totalSize: -1,
      freeSpace: -1,
      temperature: -1,
      readRate: -1,
      writeRate: -1,
      type: "HDD",
      partitions: null,
      smartAttributes: [],
      info: {},
    );
  }
  factory Storage.fromJson(String source) => Storage.fromMap(json.decode(source));
}

class Partition {
  final String driveLetter;
  final String label;
  final int size;
  final int freeSpace;
  Partition({
    required this.driveLetter,
    required this.label,
    required this.size,
    required this.freeSpace,
  });

  factory Partition.fromMap(Map<String, dynamic> map) {
    return Partition(
      driveLetter: map['driveLetter'] ?? '',
      label: map['label'] ?? '',
      size: map['size']?.toInt() ?? 0,
      freeSpace: map['freeSpace']?.toInt() ?? 0,
    );
  }

  factory Partition.fromJson(String source) => Partition.fromMap(json.decode(source));
}

class Motherboard {
  String name;
  double temperature;
  Motherboard({
    required this.name,
    required this.temperature,
  });

  factory Motherboard.fromMap(Map<String, dynamic> map) {
    return Motherboard(
      name: map['name'] ?? '',
      temperature: map['temperature']?.toDouble() ?? 0.0,
    );
  }
  factory Motherboard.nullData() {
    return Motherboard(
      name: '-1',
      temperature: -1,
    );
  }
  factory Motherboard.fromJson(String source) => Motherboard.fromMap(json.decode(source));
}

class TaskmanagerProcess {
  ///this contains the list of processes,
  ///sometimes a program runs multiple processes,
  ///for example, firefox has more than 8 processes when you use it, we combine all the processes and get a sum of the usage for that program.
  List<int> pids;
  String name;

  ///in megabytes
  double memoryUsage;
  double cpuPercent;
  Uint8List? icon;

  TaskmanagerProcess({
    required this.pids,
    required this.name,
    required this.memoryUsage,
    required this.cpuPercent,
    this.icon,
  });

  factory TaskmanagerProcess.fromMap(Map<String, dynamic> data) {
    Uint8List? icon;
    if (data['icon'] != null) {
      icon = base64Decode(data['icon']);
    }
    return TaskmanagerProcess(
      pids: List<int>.from(data['pids'] ?? []),
      name: data['name'] ?? '',
      memoryUsage: data['memoryUsage']?.toDouble() ?? 0.0,
      cpuPercent: data['cpuPercent']?.toDouble() ?? 0.0,
      icon: icon,
      //networkUsage: (data['networkReadRate'] + data['networkWriteRate'])?.toDouble() ?? 0.0,
      //diskUsage: (data['diskReadRate'] + data['diskWriteRate'])?.toDouble() ?? 0.0,
    );
  }
}

class NetworkInterface {
  final String name;
  final String description;
  final bool isEnabled;
  final String id;
  final int bytesSent;
  final int bytesReceived;
  final bool isPrimary;
  NetworkInterface({
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.id,
    required this.bytesSent,
    required this.bytesReceived,
    required this.isPrimary,
  });

  factory NetworkInterface.fromMap(Map<String, dynamic> map) {
    return NetworkInterface(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isEnabled: (map['status'] ?? "Down") != "Down",
      id: map['id'] ?? '',
      bytesSent: map['bytesSent']?.toInt() ?? 0,
      bytesReceived: map['bytesReceived']?.toInt() ?? 0,
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  factory NetworkInterface.fromJson(String source) => NetworkInterface.fromMap(json.decode(source));
}

class Monitor {
  String name;
  bool primary;
  int height;
  int width;
  int bitsPerPixel;
  Monitor({
    required this.name,
    required this.primary,
    required this.height,
    required this.width,
    required this.bitsPerPixel,
  });

  factory Monitor.fromMap(Map<String, dynamic> map) {
    return Monitor(
      name: map['name'] ?? '',
      primary: map['primary'] ?? false,
      height: map['height']?.toInt() ?? 0,
      width: map['width']?.toInt() ?? 0,
      bitsPerPixel: map['bitsPerPixel']?.toInt() ?? 0,
    );
  }
  factory Monitor.nullData() {
    return Monitor(
      name: '-1',
      primary: false,
      height: -1,
      width: -1,
      bitsPerPixel: -1,
    );
  }
  factory Monitor.fromJson(String source) => Monitor.fromMap(json.decode(source));
}

class Ram {
  ///in gigabytes
  final double memoryUsed;

  ///in gigabytes
  final double memoryAvailable;
  final int memoryUsedPercentage;
  final List<RamPiece> ramPieces;
  Ram({
    required this.memoryUsed,
    required this.memoryAvailable,
    required this.memoryUsedPercentage,
    required this.ramPieces,
  });

  factory Ram.fromMap(Map<String, dynamic> map) {
    return Ram(
      memoryUsed: map['memoryUsed'] ?? 0,
      memoryAvailable: map['memoryAvailable'] ?? 0,
      memoryUsedPercentage: map['memoryUsedPercentage']?.toInt() ?? 0,
      ramPieces: map['ramPiecesData'] != null ? List<RamPiece>.from(map['ramPiecesData']?.map((x) => RamPiece.fromMap(x))) : [],
    );
  }

  factory Ram.nullData() {
    return Ram(
      memoryUsed: -1,
      memoryAvailable: -1,
      memoryUsedPercentage: -1,
      ramPieces: [],
    );
  }
  factory Ram.fromJson(String source) => Ram.fromMap(json.decode(source));
}

class RamPiece {
  final int capacity;
  final String manufacturer;
  final String partNumber;
  final int clockSpeed;
  RamPiece({
    required this.capacity,
    required this.manufacturer,
    required this.partNumber,
    required this.clockSpeed,
  });

  factory RamPiece.fromMap(Map<String, dynamic> map) {
    return RamPiece(
      capacity: map['capacity']?.toInt() ?? 0,
      manufacturer: map['manufacturer'] ?? '',
      partNumber: map['partNumber'] ?? '',
      clockSpeed: map['speed']?.toInt() ?? 0,
    );
  }

  factory RamPiece.fromJson(String source) => RamPiece.fromMap(json.decode(source));
}

class SmartAttribute {
  final String attributeName;
  final int id;
  final int? currentValue;
  final int? worstValue;
  final int? threshold;
  final int rawValue;
  SmartAttribute({
    required this.attributeName,
    required this.id,
    required this.currentValue,
    required this.worstValue,
    required this.threshold,
    required this.rawValue,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'attributeName': attributeName});
    result.addAll({'id': id});
    result.addAll({'currentValue': currentValue});
    result.addAll({'worstValue': worstValue});
    result.addAll({'threshold': threshold});
    result.addAll({'rawValue': rawValue});

    return result;
  }

  factory SmartAttribute.fromMap(Map<String, dynamic> map) {
    return SmartAttribute(
      attributeName: map['attributeName'] ?? '',
      id: int.tryParse(map['id']) ?? 0,
      currentValue: map['currentValue']?.toInt(),
      worstValue: map['worstValue']?.toInt(),
      threshold: map['threshold']?.toInt(),
      rawValue: map['rawValue']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SmartAttribute.fromJson(String source) => SmartAttribute.fromMap(json.decode(source));
}

class DataIsNullException implements Exception {
  DataIsNullException();
}

class ComputerOfflineException implements Exception {
  ComputerOfflineException();
}

class NotConnectedToSocketException implements Exception {
  NotConnectedToSocketException();
}

class ErrorParsingComputerData implements Exception {
  final String data;
  final Object error;
  ErrorParsingComputerData(this.data, this.error);
}

class TooEarlyToReturnError implements Exception {
  TooEarlyToReturnError();
}
