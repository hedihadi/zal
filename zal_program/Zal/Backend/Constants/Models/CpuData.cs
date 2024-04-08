using LibreHardwareMonitor.Hardware;
using System.Collections.Generic;
using System.Linq;

namespace Zal.Constants.Models
{
  public  class cpuData
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

        public cpuData(IHardware hardware, cpuInfo? cpuInfo) { 
        
            this.cpuInfo = cpuInfo;
            this.name = hardware.Name;

            foreach (ISensor sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Power)
                {
                    if (sensor.Name.Contains("Package"))
                    {
                        this.power = (ulong)sensor.Value;
                    }
                    else
                    {
                        this.powers[sensor.Name] = sensor.Value;
                    }
                }
                else if (sensor.SensorType == SensorType.Load)
                {
                    if (sensor.Name == "CPU Total")
                    {
                        this.load = (uint)sensor.Value;
                    }
                    else
                    {
                       this.loads[sensor.Name] = sensor.Value;
                    }
                }
                else if (sensor.SensorType == SensorType.Voltage)
                {
                    this.voltages[sensor.Name] = sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Clock)
                {
                   this.clocks[sensor.Name] = sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Temperature && sensor.Name.Contains("(Tctl/Tdie)"))
                {
                    this.temperature = (uint)sensor.Value;
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
                        this.temperature = (uint)foundSensor.Value;
                    }

                }
            }
        }
    }
}
