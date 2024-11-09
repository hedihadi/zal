using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Management;
using System.Threading.Tasks;
using Zal;
using Zal.HelperFunctions;
using ZalConsole.Constants.Models;

namespace ZalConsole.HelperFunctions
{
    public class GlobalClass
    {
        private ManagementObjectCollection? win32DiskDrives;
        private ManagementObjectCollection? win32DiskPartitions;
        private ManagementObjectCollection? win32DiskPartitionsForFreeDiskSpace;
        public ProcessesGetter processesGetter = new();
        private static GlobalClass instance;
        private List<ProcessInfo>? processInfos;

        private GlobalClass()
        {
            // Initialization code here
        }

        public bool saveTextToDocumentFolder(string filename, string data)
        {
            var directory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Zal");
            Directory.CreateDirectory(directory);
            var filePath = Path.Combine(directory, filename);
            try
            {
                using (var writer = new StreamWriter(filePath))
                {
                    writer.Write(data);
                }

                return true;
            }
            catch (Exception ex)
            {
                Logger.LogError($"error writing to {filePath}", ex);
                return false;
            }
        }

        public async Task<string?> readTextFromDocumentFolder(string filename)
        {
            var directory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Zal");
            var filePath = Path.Combine(directory, filename);

            try
            {
                if (!File.Exists(filePath))
                {
                    // Create the directory if it doesn't exist
                    Directory.CreateDirectory(directory);

                    // Create the file
                    File.Create(filePath).Close(); // Close the file stream immediately after creating it
                }

                using (var reader = new StreamReader(filePath))
                {
                    var data = await reader.ReadToEndAsync();
                    return data;
                }
            }
            catch (FileNotFoundException)
            {
                // File not found
                return null;
            }
            catch (IOException c)
            {
                // Error reading file, try to delete the file
                try
                {
                    File.Delete(filePath);
                }
                catch (Exception e)
                {
                    Logger.LogError($"failed to read {filePath} and failed to delete it", e);
                }

                return null;
            }
            catch (UnauthorizedAccessException)
            {
                // Access denied
                return null;
            }
            catch (Exception)
            {
                // Any other unexpected error
                return null;
            }
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

        public string getFilepathFromResources(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources", fileName);
        }

        public string extractZipFromResourcesAndGetFilepathWithinTheExtract(string zipFileName, string filenameWithinTheExtract)
        {
            var zipFilepath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources", zipFileName);
            var zipFileNameWithoutDotZip = zipFilepath.Replace(".zip", "");
            try
            {
                System.IO.Compression.ZipFile.ExtractToDirectory(zipFilepath, zipFileNameWithoutDotZip);
            }
            catch (IOException c)
            {

            }
            catch (Exception c)
            {
                Logger.LogError("failed to extract zip from resources folder", c);
            }

            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources", zipFileNameWithoutDotZip, filenameWithinTheExtract);
        }

        ///return icon of a file in base64
        public string getFileIcon(string fileName)
        {
            var filePath = extractZipFromResourcesAndGetFilepathWithinTheExtract("get_process_icon.zip", "get_process_icon.exe");

            var process = new Process();
            process.StartInfo.FileName = filePath;
            process.StartInfo.Arguments = $"\"{fileName}\"";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.CreateNoWindow = true;
            process.Start();
            //* Read the output (or the error)
            var output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            output = output.Replace("\r\n", "");
            return output;
        }

        public ManagementObjectCollection getWin32DiskDrives()
        {
            if (win32DiskDrives == null)
            {
                var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive");
                win32DiskDrives = searcher.Get();
                Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromSeconds(60));
                    win32DiskDrives = null;
                });
            }

            return win32DiskDrives;


        }

        public List<ProcessInfo> getProcessInfos()
        {
            if (processInfos == null)
            {
                var jsonFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources\\Processes.json");

                // Check if the file exists
                if (File.Exists(jsonFilePath))
                {
                    // Read the contents of the JSON file
                    var jsonContent = File.ReadAllText(jsonFilePath);
                    processInfos = Newtonsoft.Json.JsonConvert.DeserializeObject<List<ProcessInfo>>(jsonContent);
                }
            }

            return processInfos;
        }

        public List<ManagementObject> getWin32DiskPartitions(int diskNumber)
        {
            if (win32DiskPartitions == null)
            {
                var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskPartition");
                win32DiskPartitions = searcher.Get();
                Task.Run(async () =>
                {
                    await Task.Delay(TimeSpan.FromSeconds(60));
                    win32DiskPartitions = null;
                });
            }

            // Filter the partitions based on the specified disk number
            var filteredPartitions = new List<ManagementObject>();
            foreach (ManagementObject partition in win32DiskPartitions)
            {
                // Adjust the property name based on the actual property for the disk number
                var currentDiskNumber = Convert.ToInt32(partition["DiskIndex"]);

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
                var scope = new ManagementScope(@"\\.\root\cimv2");
                var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive");
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
