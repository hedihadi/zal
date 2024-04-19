using System.Collections.Generic;
using System.Management;
using Zal.Constants.Models;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class ramPieceDataGetter
    {
         public static List<ramPieceData> GetRamPiecesData()
        {
            var data = new List<ramPieceData>();
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PhysicalMemory");
            foreach (ManagementObject obj in searcher.Get())
            {
                var ramData = new ramPieceData
                {
                    capacity = (ulong)obj["Capacity"],
                    manufacturer = (string)obj["Manufacturer"],
                    partNumber = (string)obj["PartNumber"],
                    speed = (uint)obj["Speed"],
                };
                data.Add(ramData);
            }
            return data;
        }
    }
}
