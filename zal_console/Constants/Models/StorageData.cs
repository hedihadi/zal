using LibreHardwareMonitor.Hardware;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Zal.HelperFunctions.SpecificFunctions;

namespace Zal.Constants.Models
{
  public class storageData
    {
        public int diskNumber { get; set; }
        public long totalSize { get; set; }
        public ulong freeSpace { get; set; }
        public ulong temperature { get;set; }
        public ulong? readRate { get; set; }
        public ulong? writeRate { get; set; }
        //whether it's hdd, ssd, or external storage
        public string type { get; set; }
        public List<partitionInfo> partitions { get; } = new List<partitionInfo>();
        public Dictionary<String,dynamic> info= new Dictionary<String,dynamic>();
        public List<smartAttribute> smartAttributes = new List<smartAttribute>();
         public storageData(IHardware hardware, List<crystalDiskData>? crystalDiskDatas)
        {
            this.type = "External";
            crystalDiskData? crystalDiskData=null;
            if (crystalDiskDatas != null)
            {
                foreach (crystalDiskData _crystalDiskData in crystalDiskDatas)
                {
                    if (_crystalDiskData.info["model"] == hardware.Name)
                    {
                        crystalDiskData = _crystalDiskData;
                        this.info= crystalDiskData.info;
                        this.smartAttributes=crystalDiskData.smartAttributes;
                        //if the disk has "Current Pending Sector Count" variable, it means this is hdd, it's SSD otherwise. this might not be accurate, further testing required.
                        var currentPendingSectorCount = crystalDiskData.smartAttributes.Where(smartAttribute => smartAttribute.attributeName == "SSD Life Left");
                        if (crystalDiskData.isNvme)
                        {
                            this.type = "NVMe";
                        }
                        else if (currentPendingSectorCount.Count()==0)
                        {
                            this.type = "HDD";
                        }
                        else
                        {
                            this.type = "SSD";
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
                        this.temperature = (ulong)sensor.Value;
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
                            this.readRate = ulong.Parse(sensor.Value.ToString());
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
                        this.writeRate = (ulong)sensor.Value;
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
                this.totalSize = diskInfo.totalSize;
                this.freeSpace = diskInfo.freeSpace;
                this.partitions = diskInfo.partitions;
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
        set => _label = value?.Replace("'", "").Replace("\"","");
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