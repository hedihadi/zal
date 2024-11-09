using LibreHardwareMonitor.Hardware;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.HelperFunctions.SpecificcomputerDataFunctions;
using Zal.HelperFunctions.SpecificFunctions;
using ZalConsole.HelperFunctions;
using ZalConsole.HelperFunctions.SpecificFunctions;

namespace Zal.HelperFunctions
{
    public class computerDataGetter
    {
        private readonly cpuInfo? cpuInfo;
        private readonly List<crystalDiskData>? crystalDiskDatas;
        private readonly List<ramPieceData>? ramPiecesData;
        //this variable holds the network speed that the user has chosen as primary.
        private readonly networkSpeed primarynetworkSpeed = new(download: 0, upload: 0);

        private readonly NetworkSpeedGetter networkSpeedGetter = new();
        //disabled fps feature because it's buggy
        //public fpsDataGetter fpsDataGetter;
        //this variable holds the processes and how much % gpu they use. we use this data to determine which process is a game. and get the fps data from it.
        private readonly Dictionary<int, double> processesGpuUsage = [];
        private readonly Computer computer = new()
        {
            IsCpuEnabled = true,
            IsGpuEnabled = true,
            IsMemoryEnabled = true,
            IsMotherboardEnabled = true,
            IsControllerEnabled = true,
            IsNetworkEnabled = true,
            IsStorageEnabled = true
        };

        public computerDataGetter()
        {
            //fpsDataGetter = new fpsDataGetter(client);
            uint attempts = 0;
            while (attempts != 5)
            {
                try
                {
                    computer.Open();
                    break;
                }
                catch (Exception)
                {
                    attempts++;
                }
            }

            if (attempts == 5)
            {
                Logger.Log("error running computer.open, attempted 5 times and failed");
            }

            computer.Accept(new UpdateVisitor());

            //below code is run only once during the lifetime of this program. this is to reduce load.
            try
            {
                cpuInfo = cpuInfoGetter.getcpuInfo();
            }
            catch (Exception ex)
            {
                Logger.LogError("error getting cpuInfo", ex);
            }

            try
            {
                ramPiecesData = ramPieceDataGetter.GetRamPiecesData();
            }
            catch (Exception ex)
            {
                Logger.LogError("error getting ramPiecesData", ex);
            }

            try
            {
                crystalDiskDatas = CrystaldiskInfoGetter.getcrystalDiskData();
            }
            catch (Exception ex)
            {
                Logger.LogError("error getting crystalDiskData", ex);
            }
        }

        public string getEntireComputerData()
        {
            var computerData = new computerData();
            computer.Accept(new UpdateVisitor());
            var result = new Dictionary<string, object>();
            foreach (var hardware in computer.Hardware)
            {
                var data = new Dictionary<string, object>
                {
                    ["type"] = hardware.HardwareType.ToString()
                };
                foreach (var sensor in hardware.Sensors)
                {
                    var sensorData = new Dictionary<string, object>
                    {
                        ["type"] = sensor.SensorType.ToString(),
                        ["value"] = sensor.Value.ToString(),
                    };
                    data[sensor.Name] = sensorData;
                }

                result.Add(hardware.Name, data);
            }

            var stringifiedData = Newtonsoft.Json.JsonConvert.SerializeObject(result);
            return stringifiedData;
        }

        public async Task<computerData> getcomputerDataAsync()
        {
            var computerData = new computerData();
            computer.Accept(new UpdateVisitor());
            GlobalClass.Instance.processesGetter.update();
            computerData.isAdminstrator = IsAdminstratorChecker.IsAdministrator();
            computerData.taskmanagerData = GlobalClass.Instance.processesGetter.data;
            if (computer.Hardware.Count == 0)
            {
                Logger.Log("warning getting computer data, computerHardware count is 0");
            }

            foreach (var hardware in computer.Hardware)
            {
                //Console.WriteLine($"name:{hardware.Name},type:{hardware.HardwareType}");
                var gpuTypes = new HardwareType[] { HardwareType.GpuNvidia, HardwareType.GpuIntel, HardwareType.GpuAmd };
                if (hardware.HardwareType == HardwareType.Cpu)
                {
                    try
                    {
                        computerData.cpuData = new cpuData(hardware, cpuInfo);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogError("error parsing cpuData", ex);
                    }
                }
                else if (hardware.HardwareType.ToString().ToLower().Contains("gpu"))
                //else if (gpuTypes.Contains(hardware.HardwareType))
                {
                    try
                    {
                        //Console.WriteLine($"gpu found:{hardware.Name}");
                        var gpu = new gpuData(hardware);
                        computerData.gpuData.Add(gpu);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogError("error parsing gpuData", ex);
                    }
                }
                else if (hardware.HardwareType == HardwareType.Memory)
                {
                    try
                    {
                        computerData.ramData = new ramData(hardware, ramPiecesData);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogError("error parsing ramData", ex);
                    }
                }
                else if (hardware.HardwareType == HardwareType.Motherboard)
                {
                    try
                    {
                        computerData.motherboardData = new motherboardData(hardware);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogError("error parsing motherboardData", ex);
                    }
                }

                else if (hardware.HardwareType == HardwareType.Storage)
                {
                    try
                    {
                        var storage = new storageData(hardware, crystalDiskDatas);
                        computerData.storagesData.Add(storage);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogError("error parsing storageData", ex, dataToPrint: crystalDiskDatas);
                    }
                }
            }

            try
            {
                var monitorsData = monitorDataGetter.getmonitorData();
                computerData.monitorsData = monitorsData;
            }
            catch (Exception ex)
            {
                Logger.LogError("error parsing monitorData", ex);
            }

            try
            {
                var batteryData = batteryDataGetter.getbatteryData();
                computerData.batteryData = batteryData;
            }
            catch (Exception ex)
            {
                Logger.LogError("error parsing batteryData", ex);
            }

            try
            {
                computerData.processesGpuUsage = processesGpuUsage;
            }
            catch (Exception ex)
            {
                Logger.LogError("error parsing processesGpuUsage", ex);
            }

            try
            {
                computerData.primaryNetworkSpeed = networkSpeedGetter.primaryNetworkSpeed;
            }
            catch (Exception ex)
            {
                Logger.LogError("error getting primary network speed", ex);
            }

            try
            {
                computerData.networkInterfaces = networkSpeedGetter.networkInterfaceDatas;
            }
            catch (Exception ex)
            {
                Logger.LogError("error getting primary network speed", ex);
            }

            return computerData;
        }
    }
}

internal class UpdateVisitor : IVisitor
{
    public void VisitComputer(IComputer computer)
    {
        computer.Traverse(this);
    }

    public void VisitHardware(IHardware hardware)
    {
        var attempts = 0;
        while (attempts < 5)
        {
            try
            {
                hardware.Update();
                break;
            }
            catch
            {
                attempts++;
            }
        }

        foreach (var subHardware in hardware.SubHardware)
        {
            subHardware.Accept(this);
        }
    }

    public void VisitSensor(ISensor sensor)
    {
        Console.WriteLine(sensor);
    }

    public void VisitParameter(IParameter parameter)
    {
    }
}
