import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  CpuInfo cpuInfo;
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
      cpuInfo: CpuInfo.fromMap(map['cpuInfo']),
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
  late Map<String, dynamic> parsedData;
  Map<String, dynamic>? taskmanagerData;
  late Ram ram;
  late Cpu cpu;
  late List<Gpu> gpus;
  late List<Storage> storages;
  late List<Monitor> monitors;
  late Motherboard motherboard;
  late Battery battery;
  late List<NetworkInterface> networkInterfaces;
  NetworkSpeed? networkSpeed;
  late bool isRunningAsAdminstrator;

  ///the data that's used inside charts will be saved here,
  ///for example if we want to make a chart for gpu loads, we will save the gpu loads of each second into this variable
  Map<String, List<double>> chartData = {};

  ///this has the processes and their gpu utilization, we use this to auto detect game process.
  Map<int, double>? processesGpuUsage = {};

  ComputerData();

  ComputerData.construct(String data, AsyncNotifierProviderRef ref) {
    //data =
    //    '{"processesGpuUsage":{},"ramData":{"memoryUsed":4.744507,"memoryAvailable":3.18727875,"memoryUsedPercentage":59,"ramPiecesData":[{"capacity":4294967296,"manufacturer":"Samsung","partNumber":"M471B5173QH0-YK0  ","speed":1333},{"capacity":4294967296,"manufacturer":"Kingston","partNumber":null,"speed":1333}]},"cpuData":{"name":"Intel Core i5-4210U","cpuInfo":{"name":"Intel® Core™ i5-4210U CPU @ 1.70GHz","socket":"U3E1","speed":2401,"busSpeed":100,"l2Cache":262144,"l3Cache":3145728,"cores":2,"threads":4},"temperature":60,"load":44,"power":9,"powers":{"CPU Cores":4.75216866,"CPU Memory":1.69255},"loads":{"CPU Core #1 Thread #1":47.82439,"CPU Core #1 Thread #2":41.88408,"CPU Core #2 Thread #1":45.97194,"CPU Core #2 Thread #2":41.80186,"CPU Core Max":47.82439},"voltages":{"CPU Core":0.8239746,"CPU Core #1":0.8220215,"CPU Core #2":0.8239746},"clocks":{"CPU Core #1":2394.459,"CPU Core #2":2394.459,"Bus Speed":99.76913}},"gpuData":[{"name":"NVIDIA GeForce 840M","coreSpeed":135,"memorySpeed":405,"fanSpeedPercentage":0,"corePercentage":0,"power":0,"dedicatedMemoryUsed":0,"voltage":0,"temperature":43},{"name":"Intel(R) HD Graphics Family","coreSpeed":0,"memorySpeed":0,"fanSpeedPercentage":0,"corePercentage":0,"power":0,"dedicatedMemoryUsed":0,"voltage":0,"temperature":0}],"motherboardData":{"name":"HP 2281","temperature":0},"storagesData":[{"info":{"model":"MTFDDAK256MAM-1K12","queueDepth":"32","transferMode":[" SATA/600 "," SATA/600"],"powerOnHours":19086,"powerOnCount":3643,"healthPercentage":92,"healthText":"Good","features":["S.M.A.R.T."," APM"," NCQ"," TRIM"," GPL"],"driveLetters":["C","D"]},"smartAttributes":[{"id":"01","currentValue":100,"worstValue":100,"threshold":50,"rawValue":0,"attributeName":"Raw Read Error Rate"},{"id":"05","currentValue":100,"worstValue":100,"threshold":10,"rawValue":0,"attributeName":"Reallocated NAND Block Count"},{"id":"09","currentValue":100,"worstValue":100,"threshold":0,"rawValue":19086,"attributeName":"Power On Hours Count"},{"id":"0C","currentValue":100,"worstValue":100,"threshold":0,"rawValue":3643,"attributeName":"Power Cycle Count"},{"id":"AA","currentValue":100,"worstValue":100,"threshold":10,"rawValue":0,"attributeName":"Vendor Specific"},{"id":"AB","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Program Fail Count"},{"id":"AC","currentValue":100,"worstValue":100,"threshold":0,"rawValue":138,"attributeName":"Erase Fail Count"},{"id":"AD","currentValue":92,"worstValue":92,"threshold":10,"rawValue":246,"attributeName":"Average Block Erase Count"},{"id":"AE","currentValue":100,"worstValue":100,"threshold":0,"rawValue":186,"attributeName":"Unexpected Power Loss Count"},{"id":"B5","currentValue":100,"worstValue":100,"threshold":0,"rawValue":30687685120854,"attributeName":"Non-4K Aligned Access"},{"id":"B7","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"SATA interface Downshift"},{"id":"B8","currentValue":100,"worstValue":100,"threshold":97,"rawValue":0,"attributeName":"Error Correction Count"},{"id":"BB","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Reported Uncorrectable Errors"},{"id":"BC","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Vendor Specific"},{"id":"BD","currentValue":100,"worstValue":100,"threshold":0,"rawValue":85,"attributeName":"Vendor Specific"},{"id":"C3","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Vendor Specific"},{"id":"C4","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Reallocation Event Count"},{"id":"C5","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Current Pending ECC Count"},{"id":"C6","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"SMART Offline Scan Uncorrectable Error Count"},{"id":"C7","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"UDMA CRC Error Count"},{"id":"CA","currentValue":92,"worstValue":92,"threshold":0,"rawValue":8,"attributeName":"Lifetime Remaining"},{"id":"CE","currentValue":100,"worstValue":100,"threshold":0,"rawValue":0,"attributeName":"Write Error Rate"}],"diskNumber":0,"totalSize":0,"freeSpace":0,"temperature":0,"readRate":0,"writeRate":0,"type":"HDD","partitions":[]}],"monitorsData":[{"name":"DISPLAY1","height":768,"width":1366,"isPrimary":true,"bitsPerPixel":32}],"batteryData":{"hasBattery":true,"life":100,"isCharging":true,"lifeRemaining":4294967295},"fpsData":null,"taskmanagerData":null,"isAdminstrator":true,"networkInterfaces":[{"name":"Wi-Fi","description":"Realtek RTL8723BE 802.11 bgn Wi-Fi Adapter","status":"Up","id":"{045A3097-E563-4758-8C77-93DB990BDA22}","bytesSent":8508832,"bytesReceived":173966653,"isPrimary":true},{"name":"Teredo Tunneling Pseudo-Interface","description":"Microsoft Teredo Tunneling Adapter","status":"Up","id":"{93123211-9629-4E04-82F0-EA2E4F221468}","bytesSent":13800,"bytesReceived":456,"isPrimary":false},{"name":"Ethernet","description":"Realtek PCIe FE Family Controller","status":"Down","id":"{6933284B-AF29-482A-9597-80C62EF8DBAD}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Local Area Connection 2","description":"Windscribe Windtun420","status":"Down","id":"{F83AD26A-AC2E-4B62-A24D-441FC16017BD}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Local Area Connection","description":"Windscribe VPN","status":"Down","id":"{9ED8A1D4-DE15-4735-B6A4-8A3A3A0267DB}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Local Area Connection* 1","description":"Microsoft Wi-Fi Direct Virtual Adapter","status":"Down","id":"{7051CD0F-4153-466A-BE90-E240040B36AA}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Local Area Connection* 2","description":"Microsoft Wi-Fi Direct Virtual Adapter #2","status":"Down","id":"{42DBD90B-815C-4482-BD2A-652DF624B551}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Bluetooth Network Connection","description":"Bluetooth Device (Personal Area Network)","status":"Down","id":"{75F3AD8D-18B5-4CF5-BB30-FEF60233DFFB}","bytesSent":0,"bytesReceived":0,"isPrimary":false},{"name":"Loopback Pseudo-Interface 1","description":"Software Loopback Interface 1","status":"Up","id":"{881F2DA6-9E80-11ED-A41A-806E6F6E6963}","bytesSent":0,"bytesReceived":0,"isPrimary":false}],"primaryNetworkSpeed":{"download":549,"upload":2506}}';
    final localParsedData = jsonDecode(data.replaceAll("'", '"'));
    taskmanagerData = localParsedData['taskmanagerData'];
    parsedData = Map<String, dynamic>.from(localParsedData);
    parsedData.remove('taskmanagerData');
    isRunningAsAdminstrator = parsedData['isAdminstrator'];
    processesGpuUsage = parsedData["processesGpuUsage"] == null
        ? null
        : Map<String, double>.from(parsedData["processesGpuUsage"]).map((key, value) => MapEntry(int.parse(key), value));
    if (parsedData['ramData'] != null) {
      ram = Ram.fromMap(parsedData['ramData']);
    } else {
      ram = Ram.nullData();
    }
    if (parsedData['cpuData'] != null) {
      cpu = Cpu.fromMap(parsedData['cpuData']);
    } else {
      cpu = Cpu.nullData();
    }

    if (parsedData['gpuData'] != null) {
      gpus = List<Gpu>.from(List<Map<String, dynamic>>.from(parsedData['gpuData']).map((e) => Gpu.fromMap(e)).toList());
    } else {
      gpus = [Gpu.nullData()];
    }
    if (parsedData['motherboardData'] != null) {
      motherboard = Motherboard.fromMap(parsedData['motherboardData']);
    } else {
      motherboard = Motherboard.nullData();
    }
    if (parsedData['batteryData'] != null) {
      battery = Battery.fromMap(parsedData['batteryData']);
    } else {
      battery = Battery.nullData();
    }
    if (parsedData['storagesData'] != null) {
      storages = List<Map<String, dynamic>>.from(parsedData['storagesData']).map((e) => Storage.fromMap(e)).toList();
    } else {
      storages = [Storage.nullData()];
    }
    storages.sort((a, b) => a.diskNumber.compareTo(b.diskNumber));
    if (parsedData['monitorsData'] != null) {
      monitors = List<Map<String, dynamic>>.from(parsedData['monitorsData']).map((e) => Monitor.fromMap(e)).toList();
    } else {
      monitors = [Monitor.nullData()];
    }
    if (parsedData['primaryNetworkSpeed'] != null) networkSpeed = NetworkSpeed.fromMap(parsedData["primaryNetworkSpeed"]);

    if (parsedData.containsKey("networkInterfaces")) {
      networkInterfaces = List<Map<String, dynamic>>.from(parsedData['networkInterfaces']).map((e) => NetworkInterface.fromMap(e)).toList();
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
      ramSize: "${((data.ram.memoryAvailable ?? 0) + (data.ram.memoryUsed ?? 0)).toStringAsFixed(2)}GB",
      gpusName: data.gpus.map((e) => e.name).toList() ?? [],
      cpuName: data.cpu.name,
      storages: data.storages.map((e) => '${(e.totalSize / 1024 / 1024 / 1024).round()} GB ${e.type}').toList() ?? [],
      monitors: data.monitors.map((e) => '${e.width} x ${e.height}${e.primary ? ' primary' : ''}').toList() ?? [],
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

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'pids': pids});
    result.addAll({'name': name});
    result.addAll({'memoryUsage': memoryUsage});
    result.addAll({'cpuPercent': cpuPercent});
    if (icon != null) {
      result.addAll({'icon': base64Encode(icon!)});
    }

    return result;
  }

  factory TaskmanagerProcess.fromMap(String name, Map<String, dynamic> data, {bool addIcon = true}) {
    Uint8List? icon;
    if (data['icon'] != null && addIcon != false) {
      icon = base64Decode(data['icon']);
    }
    return TaskmanagerProcess(
      pids: List<int>.from(data['pids'] ?? []),
      name: name,
      memoryUsage: data['memoryUsage']?.toDouble() ?? 0.0,
      cpuPercent: data['cpuPercent']?.toDouble() ?? 0.0,
      icon: icon,
      //networkUsage: (data['networkReadRate'] + data['networkWriteRate'])?.toDouble() ?? 0.0,
      //diskUsage: (data['diskReadRate'] + data['diskWriteRate'])?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());
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
  final double memoryUsed;
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
      ramPieces: List<RamPiece>.from(map['ramPiecesData']?.map((x) => RamPiece.fromMap(x))),
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
      clockSpeed: map['clockSpeed']?.toInt() ?? 0,
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
