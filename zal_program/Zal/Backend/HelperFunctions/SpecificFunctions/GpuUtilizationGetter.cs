using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Management.Automation;
using ZalConsole.Constants.Models;
using Zal;
using Zal.HelperFunctions.SpecificFunctions;

namespace ZalConsole.HelperFunctions.SpecificFunctions
{
    internal class GpuUtilizationGetter
    {
        //this function is based on this https://github.com/GameTechDev/PresentMon/issues/189
        //and some modifications to make the data to be parsed easier from c# side.
        public static Dictionary<string, Dictionary<string, dynamic>> getProcessesGpuUsage(bool skipBlackListedProcesses = true)
        {
            Dictionary<string, Dictionary<string, dynamic>> result = new Dictionary<string, Dictionary<string, dynamic>>();
            var rawData = getRawDataFromPowershell();
            var processInfos = GlobalClass.Instance.getProcessInfos();
            foreach (var process in rawData)
            {
                Dictionary<string, dynamic> data = new Dictionary<string, dynamic>();
                var splittedData = process.Split(',');
                var pid = int.Parse(splittedData[0].Split('_')[1]);

                double usage = 1;
                try
                {
                    usage = double.Parse(splittedData[1]);
                }
                catch
                {
                }

                if (usage == 0) continue;

                var p = Process.GetProcessById(pid);
                try
                {
                    var file = p.MainModule.FileName;
                    var icon = GlobalClass.Instance.getFileIcon(file);
                    data["icon"] = icon;
                }
                catch (Exception c)
                {
                    Console.WriteLine(c.Message);
                }

                data["pid"] = pid;
                data["name"] = p.ProcessName;
                data["usage"] = usage;
                ProcessInfo foundProcessInfo;
                try
                {
                    foundProcessInfo = processInfos.Where((a) => a.name == p.ProcessName).ToList().FirstOrDefault();
                }
                catch
                {
                    foundProcessInfo = null;
                }

                if (foundProcessInfo != null)
                {
                    if (skipBlackListedProcesses)
                    {
                        if (foundProcessInfo.isBlacklisted == true) continue;
                    }

                    if (foundProcessInfo.displayName != null)
                    {
                        data["name"] = foundProcessInfo.displayName;
                    }
                }

                try
                {
                    ProcesspathGetter.save(p.ProcessName, p.MainModule.FileName);
                }
                catch
                {
                }

                result[p.ProcessName] = data;
            }

            return result;
        }

        private static List<string> getRawDataFromPowershell()
        {
            List<string> result = new List<string>();
            using (var PowerShellInstance = PowerShell.Create())
            {
                // Add the PowerShell script
                var script = "$counter = Get-Counter '\\GPU Engine(*engtype_3D)\\Utilization Percentage';" +
                             "foreach ($sample in $counter.CounterSamples) {" +
                             "$sample.InstanceName + ',' + $sample.CookedValue" +
                             "}";
                PowerShellInstance.AddScript(script);

                // Invoke execution on the PowerShell object
                Collection<PSObject> PSOutput = PowerShellInstance.Invoke();

                // Check for errors
                if (PowerShellInstance.Streams.Error.Count > 0)
                {
                    Logger.Log($"error in powershell output: ```{PowerShellInstance.Streams.Error[0].Exception}```,```{PowerShellInstance.Streams.Error[0].ErrorDetails},{PowerShellInstance.Streams.Error[0].ScriptStackTrace}```, data: ```{Newtonsoft.Json.JsonConvert.SerializeObject(PSOutput.ToArray().Select(e => e.ToString()).ToList())}```");
                }
                else
                {
                    // Output the results
                    foreach (var outputItem in PSOutput)
                    {
                        result.Add(outputItem.ToString());
                    }
                }
            }

            return result;
        }
    }
}
