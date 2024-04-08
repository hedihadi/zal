using LibreHardwareMonitor.Hardware;
using System.Collections.Generic;

namespace Zal.Constants.Models
{
    public class ramData
    {
        public float memoryUsed;
        public float memoryAvailable;
        public uint memoryUsedPercentage;
        public List<ramPieceData>? ramPiecesData;
        public ramData(IHardware hardware, List<ramPieceData>? ramPiecesData) {
            this.ramPiecesData = ramPiecesData;
            foreach (ISensor sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Data && sensor.Name == "Memory Used")
                {
                    this.memoryUsed = (float)sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Data && sensor.Name == "Memory Available")
                {
                   this.memoryAvailable = (float)sensor.Value;
                }
                else if (sensor.SensorType == SensorType.Load && sensor.Name == "Memory")
                {
                    this.memoryUsedPercentage = (uint)sensor.Value;
                }
            }
        
        }
    }
}
