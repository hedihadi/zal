using System.Linq;
using System.Management;
using Zal.Constants.Models;

namespace Zal.HelperFunctions.SpecificcomputerDataFunctions
{
    internal class cpuInfoGetter
    {
        public static cpuInfo getcpuInfo()
        {

            var cpu =
                        new ManagementObjectSearcher("select * from Win32_Processor")
                                    .Get()
                                    .Cast<ManagementObject>()
                                    .First();
            cpuInfo cpuInfo = new cpuInfo();
            cpuInfo.socket = (string)cpu["SocketDesignation"];
            cpuInfo.name = (string)cpu["Name"];
            cpuInfo.speed = (uint)cpu["MaxClockSpeed"];
            cpuInfo.busSpeed = (uint)cpu["ExtClock"];
            cpuInfo.l2Cache = (uint)cpu["L2CacheSize"] * (ulong)1024;
            cpuInfo.l3Cache = (uint)cpu["L3CacheSize"] * (ulong)1024;
            cpuInfo.cores = (uint)cpu["NumberOfCores"];
            cpuInfo.threads = (uint)cpu["NumberOfLogicalProcessors"];

            cpuInfo.name =
               cpuInfo.name
              .Replace("(TM)", "™")
              .Replace("(tm)", "™")
              .Replace("(R)", "®")
              .Replace("(r)", "®")
              .Replace("(C)", "©")
              .Replace("(c)", "©")
              .Replace("    ", " ")
              .Replace("  ", " ");
            return cpuInfo;
        }
    }
}
