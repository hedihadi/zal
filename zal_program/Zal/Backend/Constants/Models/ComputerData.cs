using System.Collections.Generic;

namespace Zal.Constants.Models
{
    public class computerData
    {
        public ramData? ramData { get; set; }
        public cpuData? cpuData { get; set; }
        public List<gpuData> gpuData { get; set; }
        public motherboardData? motherboardData { get; set; }
        public List<storageData>? storagesData { get; set; }
        public List<monitorData>? monitorsData { get; set; }
        public batteryData? batteryData { get; set; }
        public fpsData? fpsData { get; set; }
        public Dictionary<string, dynamic>? taskmanagerData { get; set; }
        public bool isAdminstrator { get; set; }
        public Dictionary<int, double> processesGpuUsage;
        public List<networkInterfaceData> networkInterfaces { get; set; }
        public networkSpeed primaryNetworkSpeed { get; set; }

        public computerData()
        {
            gpuData = new List<gpuData>();
            storagesData = new List<storageData>();
        }
    }
}
