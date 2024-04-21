using LibreHardwareMonitor.Hardware;

namespace Zal.Constants.Models
{
    public class gpuData
    {
        public string name { get; set; }
        public ulong coreSpeed { get; set; }
        public ulong memorySpeed { get; set; }
        public uint fanSpeedPercentage { get; set; }
        public uint corePercentage { get; set; }
        public uint power { get; set; }
        public ulong dedicatedMemoryUsed { get; set; }
        public uint voltage { get; set; }
        public uint temperature { get; set; }
        public int fps { get; set; }

        public gpuData(IHardware? hardware)
        {
            name = $"{hardware?.Name}";
            if (hardware == null)
            {
                return;
            }

            foreach (var sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Clock && sensor.Name == "GPU Core")
                {
                    coreSpeed = (ulong)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Clock && sensor.Name == "GPU Memory")
                {
                    memorySpeed = (ulong)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Control && sensor.Name == "GPU Fan")
                {
                    fanSpeedPercentage = (uint)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Load && sensor.Name == "GPU Core")
                {
                    corePercentage = (uint)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Power && sensor.Name == "GPU Package")
                {
                    power = (uint)sensor.Value;
                }

                if (sensor.SensorType == SensorType.SmallData && sensor.Name == "D3D Dedicated Memory Used")
                {
                    dedicatedMemoryUsed = (ulong)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Voltage)
                {
                    voltage = (uint)sensor.Value;
                }

                if (sensor.Name.Contains("FPS"))
                {
                    fps = (int)sensor.Value;
                }

                if (sensor.SensorType == SensorType.Temperature)
                {
                    temperature = (uint)sensor.Value;
                }
            }
        }
    }
}
