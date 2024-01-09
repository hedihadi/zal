using LibreHardwareMonitor.Hardware;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Zal.Constants.Models
{
   public class gpuData
    {
        public string name {  get; set; }
        public ulong coreSpeed { get; set; }
        public ulong memorySpeed { get; set; }
        public uint fanSpeedPercentage { get; set; }
        public uint corePercentage { get; set; }
        public uint power { get; set; }
        public ulong dedicatedMemoryUsed { get; set; }
        public uint voltage { get; set; }
        public uint temperature { get; set; }
        public gpuData(IHardware hardware)
        {
             
            this.name = hardware.Name;

            foreach (ISensor sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Clock && sensor.Name == "GPU Core")
                {
                    this.coreSpeed = (ulong)sensor.Value;
                }
                if (sensor.SensorType == SensorType.Clock && sensor.Name == "GPU Memory")
                {
                    this.memorySpeed = (ulong)sensor.Value;
                }
                if (sensor.SensorType == SensorType.Control && sensor.Name == "GPU Fan")
                {
                    this.fanSpeedPercentage = (uint)sensor.Value;
                }
                if (sensor.SensorType == SensorType.Load && sensor.Name == "GPU Core")
                {
                    this.corePercentage = (uint)sensor.Value;
                }
                if (sensor.SensorType == SensorType.Power && sensor.Name == "GPU Package")
                {
                    this.power = (uint)sensor.Value;
                }
                if (sensor.SensorType == SensorType.SmallData && sensor.Name == "D3D Dedicated Memory Used")
                {
                    this.dedicatedMemoryUsed = (ulong)sensor.Value;
                }
                if (sensor.SensorType == SensorType.Voltage)
                {
                    this.voltage = (uint)sensor.Value;


                }
                if (sensor.SensorType == SensorType.Temperature)
                {
                    this.temperature = (uint)sensor.Value;
                }
            }
        }
    }
}
