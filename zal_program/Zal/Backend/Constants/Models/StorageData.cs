using LibreHardwareMonitor.Hardware;
using System;
using System.Collections.Generic;
using System.Linq;
using Zal.HelperFunctions.SpecificFunctions;

namespace Zal.Constants.Models
{
    public class storageData
    {
        public int diskNumber { get; set; }
        public long totalSize { get; set; }
        public ulong freeSpace { get; set; }
        public ulong temperature { get; set; }
        public double? readRate { get; set; }
        public ulong? writeRate { get; set; }
        //whether it's hdd, ssd, or external storage
        public string type { get; set; }
        public List<partitionInfo> partitions { get; } = new List<partitionInfo>();
        public Dictionary<string, dynamic> info = new Dictionary<string, dynamic>();
        public List<smartAttribute> smartAttributes = new List<smartAttribute>();
        public storageData(IHardware hardware, List<crystalDiskData>? crystalDiskDatas)
        {
            type = "External";
            crystalDiskData? crystalDiskData = null;
            if (crystalDiskDatas != null)
            {
                foreach (var _crystalDiskData in crystalDiskDatas)
                {
                    if (_crystalDiskData.info["model"] == hardware.Name)
                    {
                        crystalDiskData = _crystalDiskData;
                        info = crystalDiskData.info;
                        smartAttributes = crystalDiskData.smartAttributes;
                        //if the disk has "Current Pending Sector Count" variable, it means this is hdd, it's SSD otherwise. this might not be accurate, further testing required.
                        var currentPendingSectorCount = crystalDiskData.smartAttributes.Where(smartAttribute => smartAttribute.attributeName == "SSD Life Left");
                        if (crystalDiskData.isNvme)
                        {
                            type = "NVMe";
                        }
                        else if (currentPendingSectorCount.Count() == 0)
                        {
                            type = "HDD";
                        }
                        else
                        {
                            type = "SSD";
                        }
                    }
                }
            }

            foreach (ISensor sensor in hardware.Sensors)
            {
                if (sensor.SensorType == SensorType.Temperature)
                {
                    try
                    {
                        temperature = (ulong)sensor.Value;
                    }
                    catch (Exception ex)
                    {

                    }
                }
                else if (sensor.SensorType == SensorType.Throughput && sensor.Name == "Read Rate")
                {
                    try
                    {
                        var value = sensor.Value.ToString();
                        if (value != null)
                        {
                            readRate = ulong.Parse(sensor.Value.ToString().Split('.')[0]);
                        }

                    }
                    catch (Exception ex)
                    {

                    }

                }
                else if (sensor.SensorType == SensorType.Throughput && sensor.Name == "Write Rate")
                {
                    try
                    {
                        writeRate = (ulong)sensor.Value;
                    }
                    catch (Exception ex)
                    {

                    }
                }
            }
            var diskNumber = int.Parse(hardware.Identifier.ToString().Substring(hardware.Identifier.ToString().Length - 1));

            try
            {
                var diskInfo = diskInfoGetter.GetdiskInfo(diskNumber, crystalDiskData);

                this.diskNumber = diskNumber;
                totalSize = diskInfo.totalSize;
                freeSpace = diskInfo.freeSpace;
                partitions = diskInfo.partitions;
            }

            catch (Exception ex)
            {
                Logger.LogError("error calling GetdiskInfo", ex);
            }
        }
    }
}
public class partitionInfo
{
    private string _label;
    public string driveLetter { get; set; }
    public string label
    {
        get => _label;
        set => _label = value?.Replace("'", "").Replace("\"", "");
    }
    public long size { get; set; }
    public long freeSpace { get; set; }
}

public class diskInfo
{
    public int diskNumber { get; set; }
    public long totalSize { get; set; }
    public ulong freeSpace { get; set; }
    public List<partitionInfo> partitions { get; } = new List<partitionInfo>();
}
