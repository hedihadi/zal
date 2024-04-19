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
        public Dictionary<string, dynamic> powers = new Dictionary<string, dynamic>();
        public Dictionary<string, dynamic> loads = new Dictionary<string, dynamic>();
        public Dictionary<string, dynamic> voltages = new Dictionary<string, dynamic>();
        public Dictionary<string, dynamic> clocks = new Dictionary<string, dynamic>();

        public cpuData(IHardware hardware, cpuInfo? cpuInfo)
        {
            this.cpuInfo = cpuInfo;
            name = hardware.Name;

            foreach (ISensor sensor in hardware.Sensors)
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
                    if (foundSensor == null)
                    {
                        foundSensor = hardware.Sensors.FirstOrDefault(s => s.SensorType == SensorType.Temperature && s.Name.Contains("Average"));
                    }

                    if (foundSensor == null)
                    {
                        foundSensor = hardware.Sensors.FirstOrDefault(s => s.SensorType == SensorType.Temperature && s.Name.Contains("Core #1"));
                    }

                    if (foundSensor != null)
                    {
                        temperature = (uint)foundSensor.Value;
                    }
                }
            }
        }
    }
}
