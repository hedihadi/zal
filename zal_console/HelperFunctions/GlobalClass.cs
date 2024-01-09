using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Text;
using System.Threading.Tasks;

namespace ZalConsole.HelperFunctions
{
    public class GlobalClass
    {
        private ManagementObjectCollection? win32DiskDrives;
        private ManagementObjectCollection? win32DiskPartitions;
        private ManagementObjectCollection? win32DiskPartitionsForFreeDiskSpace;
        private static GlobalClass instance;
        private GlobalClass()
        {
            // Initialization code here
        }
        public static GlobalClass Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new GlobalClass();
                }
                return instance;
            }
        }
       public ManagementObjectCollection getWin32DiskDrives()
        {
            if(win32DiskDrives == null)
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive");
                win32DiskDrives = searcher.Get();
                Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromSeconds(60));
                    win32DiskDrives = null;
                });
            }
            return win32DiskDrives;


        }
        public List<ManagementObject> getWin32DiskPartitions(int diskNumber)
        {
            if (win32DiskPartitions == null)
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskPartition");
                win32DiskPartitions = searcher.Get();
                Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromSeconds(60));
                    win32DiskPartitions = null;
                });
            }

            // Filter the partitions based on the specified disk number
            List<ManagementObject> filteredPartitions = new List<ManagementObject>();
            foreach (ManagementObject partition in win32DiskPartitions)
            {
                // Adjust the property name based on the actual property for the disk number
                int currentDiskNumber = Convert.ToInt32(partition["DiskIndex"]);

                if (currentDiskNumber == diskNumber)
                {
                    filteredPartitions.Add(partition);
                }
            }

            return filteredPartitions;
        }
        public ManagementObjectCollection getWin32DiskPartitionsForFreeDiskSpace()
        {
            if (win32DiskPartitionsForFreeDiskSpace == null)
            {
                ManagementScope scope = new ManagementScope(@"\\.\root\cimv2");
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive");
                scope.Connect();
                searcher.Scope = scope;
                win32DiskPartitionsForFreeDiskSpace = searcher.Get();

                 Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromSeconds(60));
                    win32DiskPartitionsForFreeDiskSpace = null;
                });
            }
            return win32DiskPartitionsForFreeDiskSpace;


        }
    }
   
}
