using System;
using System.IO;
using System.Management;
using System.Text.RegularExpressions;
using Zal.Constants.Models;
using ZalConsole.HelperFunctions;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class diskInfoGetter
    {
        public static diskInfo GetdiskInfo(int diskNumber, crystalDiskData? crystalDiskData)
        {
            foreach (ManagementObject disk in GlobalClass.Instance.getWin32DiskDrives())
            {
                //iterate until we get the disk number we want
                var diskIndex = Convert.ToInt32(disk["Index"]);
                if (diskIndex != diskNumber) continue;

                var diskInfo = new diskInfo();
                diskInfo.diskNumber = Convert.ToInt32(disk["Index"]);
                diskInfo.totalSize = Convert.ToInt64(disk["Size"]);

                foreach (ManagementObject partition in GlobalClass.Instance.getWin32DiskPartitions(diskNumber))
                {

                    var partitionInfo = new partitionInfo();
                    if (crystalDiskData != null)
                    {

                        partitionInfo.driveLetter = GetDriveLetter(partition);
                        var driveInfo = GetDriveByLetter(partitionInfo.driveLetter);
                        if (driveInfo != null)
                        {
                            partitionInfo.freeSpace = driveInfo.TotalFreeSpace;
                            partitionInfo.label = driveInfo.VolumeLabel;
                        }
                    }
                    else
                    {

                    }

                    partitionInfo.size = Convert.ToInt64(partition["Size"]);
                    diskInfo.partitions.Add(partitionInfo);
                }

                diskInfo.freeSpace = GetFreeSpaceForDisk(diskNumber);
                return diskInfo;
            }

            return null;
        }

        //this is a fallback function in case crystalDiskData is not available
        private static string GetDriveLetter(ManagementObject partition)
        {
            using (ManagementObjectSearcher searcher = new ManagementObjectSearcher($"ASSOCIATORS OF {{Win32_DiskPartition.DeviceID='{partition["DeviceID"]}'}} WHERE AssocClass=Win32_LogicalDiskToPartition"))
            {
                foreach (ManagementObject logicalDisk in searcher.Get())
                {

                    return logicalDisk["DeviceID"].ToString().Replace(":", "");
                }
            }

            return "";
        }

        private static DriveInfo? GetDriveByLetter(string driveName)
        {
            foreach (var drive in DriveInfo.GetDrives())
            {
                var pattern = "[^a-zA-Z]";
                var replacement = "";
                var regex = new Regex(pattern);
                var driveLetter = regex.Replace(drive.Name, replacement);
                if (driveLetter == driveName)
                {
                    return drive;

                }
            }

            return null;
        }

        private static ulong GetFreeSpaceForDisk(int diskNumber)
        {

            var managementObjectDisks = GlobalClass.Instance.getWin32DiskPartitionsForFreeDiskSpace();
            foreach (ManagementObject disk in managementObjectDisks)
            {
                var index = Convert.ToInt32(disk["Index"]);
                if (index == diskNumber)
                {
                    ManagementObjectSearcher partitionSearcher = new ManagementObjectSearcher($"ASSOCIATORS OF {{Win32_DiskDrive.DeviceID='{disk["DeviceID"]}'}} WHERE AssocClass=Win32_DiskDriveToDiskPartition");

                    ulong totalFreeSpace = 0;

                    foreach (ManagementObject partition in partitionSearcher.Get())
                    {
                        ManagementObjectSearcher logicalDiskSearcher = new ManagementObjectSearcher($"ASSOCIATORS OF {{Win32_DiskPartition.DeviceID='{partition["DeviceID"]}'}} WHERE AssocClass=Win32_LogicalDiskToPartition");

                        foreach (ManagementObject logicalDisk in logicalDiskSearcher.Get())
                        {
                            totalFreeSpace += Convert.ToUInt64(logicalDisk["FreeSpace"]);
                        }
                    }

                    return totalFreeSpace;
                }
            }

            return 0;
        }
    }
}
