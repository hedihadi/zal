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
            var cpuInfo = new cpuInfo {
                socket = (string)cpu["SocketDesignation"],
                name = (string)cpu["Name"],
                speed = (uint)cpu["MaxClockSpeed"],
                busSpeed = (uint)cpu["ExtClock"],
                l2Cache = (uint)cpu["L2CacheSize"] * (ulong)1024,
                l3Cache = (uint)cpu["L3CacheSize"] * (ulong)1024,
                cores = (uint)cpu["NumberOfCores"],
                threads = (uint)cpu["NumberOfLogicalProcessors"],
            };

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
