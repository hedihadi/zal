using LibreHardwareMonitor.Hardware;
using System.Collections.Generic;
using System.Linq;

namespace Zal.Constants.Models
{
    public class cpuData
    {
        public string name;
        public cpuInfo? cpuInfo;
        public uint temperature;
        public uint load;
        public ulong power;
        public Dictionary<string, dynamic> powers = [];
        public Dictionary<string, dynamic> loads = [];
        public Dictionary<string, dynamic> voltages = [];
        public Dictionary<string, dynamic> clocks = [];

        public cpuData(IHardware hardware, cpuInfo? cpuInfo)
        {
            this.cpuInfo = cpuInfo;
            name = hardware.Name;

            foreach (var sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Power)
                {
                    if (sensor.Name.Contains("Package"))
                    {
                        power = (ulong)sensor.Value;
                    }
                    else
                    {
                        powers[sensor.Name] = sensor.Value;
                    }
                }
                else if (sensor.SensorType == SensorType.Load)
                {
                    if (sensor.Name == "CPU Total")
                    {
                        load = (uint)sensor.Value;
                    }
                    else
                    {
                        loads[sensor.Name] = sensor.Value;
                    }
                }
                else if (sensor.SensorType == SensorType.Voltage)
                {
                    voltages[sensor.Name] = sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Clock)
                {
                    clocks[sensor.Name] = sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Temperature && sensor.Name.Contains("(Tctl/Tdie)"))
                {
                    temperature = (uint)sensor.Value;
                }
                else
                {
                    var foundSensor = hardware.Sensors.FirstOrDefault(s => s.SensorType == SensorType.Temperature && s.Name.Contains("(Tctl/Tdie)"));
                    foundSensor ??= hardware.Sensors.FirstOrDefault(s => s.SensorType == SensorType.Temperature && s.Name.Contains("Average"));

                    foundSensor ??= hardware.Sensors.FirstOrDefault(s => s.SensorType == SensorType.Temperature && s.Name.Contains("Core #1"));

                    if (foundSensor != null)
                    {
                        temperature = (uint)foundSensor.Value;
                    }
                }
            }
        }
    }
}
