using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Zal.Functions.MajorFunctions;
using Zal.HelperFunctions.SpecificFunctions;
using ZalConsole.HelperFunctions.SpecificFunctions;

namespace ZalConsole.HelperFunctions
{
    public class RunningProgramsTracker
    {
        private readonly Timer timer1;
        private readonly List<string> runningProcesses = [];

        public RunningProgramsTracker()
        {
            runAsync();
        }

        private async Task runAsync()
        {
            while (true)
            {
                //wait for 5 mintues
                await Task.Delay(300000);
                try
                {
                    //this list contains the processes that has kept running in the last [interval] seconds, we send them to the database.
                    var processesThatStillRunning = new List<string>();
                    var currentRunningProcesses = getRunningProcesses();
                    //check which processes are still running
                    foreach (var currentRunningProcess in currentRunningProcesses)
                    {
                        if (runningProcesses.Contains(currentRunningProcess))
                        {
                            processesThatStillRunning.Add(currentRunningProcess);
                        }
                        else
                        {
                            //if the list doesn't contain this process, that means this process is new, let's add it.
                            runningProcesses.Add(currentRunningProcess);
                        }
                    }

                    //remove the processes
                    foreach (var runningProcess in runningProcesses)
                    {
                        if (!currentRunningProcesses.Contains(runningProcess))
                        {
                            try
                            {
                                runningProcess.Remove(currentRunningProcesses.IndexOf(runningProcess));
                            }
                            catch
                            {
                            }
                        }
                    }

                    if (processesThatStillRunning.Count != 0)
                    {
                        var response = await ApiManager.SendDataToDatabase("program-times", new Dictionary<string, object>()
                        {
                            { "programs", processesThatStillRunning }
                        });
                        Console.WriteLine(response);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }

        private string loadJson()
        {
            var directory = getJsonPath();
            using (var fs = File.OpenText(Path.Combine(directory, "processes.json")))
            {
                return fs.ReadToEnd();
            }
        }

        private string getJsonPath()
        {
            var directory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Zal");
            Directory.CreateDirectory(directory);
            return directory;
        }

        private List<string> getRunningProcesses()
        {
            var result = new List<string>();
            var processes = Process.GetProcesses();
            // Iterate through each process
            var gpuProcesses = GpuUtilizationGetter.getProcessesGpuUsage(skipBlackListedProcesses: false);
            var processInfos = GlobalClass.Instance.getProcessInfos();
            foreach (var gpuProcess in gpuProcesses)
            {
                result.Add(gpuProcess.Value["name"]);
            }

            foreach (var process in processes)
            {
                // Check if the process has a main window title
                if (!string.IsNullOrEmpty(process.MainWindowTitle))
                {
                    try
                    {
                        var fileVersionInfo = FileVersionInfo.GetVersionInfo(process.MainModule.FileName);
                        var fileDescription = fileVersionInfo.FileDescription;
                        if (fileDescription == "")
                        {
                            continue;
                        }

                        var foundProcessInfo = processInfos.Where((a) => a.name == fileDescription).ToList().FirstOrDefault();
                        if (foundProcessInfo != null && foundProcessInfo.isBlacklisted)
                        {
                            continue;
                        }

                        ProcesspathGetter.save(fileDescription, process.MainModule.FileName);
                        result.Add(fileDescription);
                    }
                    catch
                    {
                        continue;
                    }
                }
            }

            return result;
        }
    }
}
