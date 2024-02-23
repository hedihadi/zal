using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using Zal;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Runtime.InteropServices;
using Zal.HelperFunctions.SpecificFunctions;

namespace ZalConsole.HelperFunctions.SpecificFunctions
{
    class GpuUtilizationGetter
    {
        //this function is based on this https://github.com/GameTechDev/PresentMon/issues/189
        //and some modifications to make the data to be parsed easier from c# side.
        public static Dictionary<String, Dictionary<string, dynamic>> getProcessesGpuUsage()
        {
            Dictionary<String, Dictionary<string, dynamic>> result = new Dictionary<String, Dictionary<string, dynamic>>();
            var rawData = getRawDataFromPowershell();
            var processInfos = GlobalClass.Instance.getProcessInfos();
            foreach (var process in rawData)
            {
                Dictionary<String, dynamic> data = new Dictionary<String, dynamic>();
                var splittedData = process.Split(',');
                int pid = int.Parse(splittedData[0].Split('_')[1]);

                double usage = double.Parse(splittedData[1]);
                if (usage == 0) continue;

                var p = Process.GetProcessById(pid);
                try
                {
                    var icon = GlobalClass.Instance.getFileIcon(p.MainModule.FileName);
                    data["icon"] = icon;
                }
                catch { }

                data["pid"] = pid;
                data["name"] = p.ProcessName;
                data["usage"] = usage;
                
                var foundProcessInfo = processInfos.Where((a) => a.name == p.ProcessName).ToList().FirstOrDefault();
                if (foundProcessInfo != null)
                {

                    if (foundProcessInfo.isBlacklisted == true) continue;

                    if (foundProcessInfo.displayName != null) { data["name"] = foundProcessInfo.displayName; }
                }
                ProcesspathGetter.save(p.ProcessName, p.MainModule.FileName);
                 result[p.ProcessName] = data;
            }
            return result;
        }
        private static List<String> getRawDataFromPowershell()
        {
            List<String> result = new List<String>();
            using (PowerShell PowerShellInstance = PowerShell.Create())
            {
                // Add the PowerShell script
                string script = "$counter = Get-Counter '\\GPU Engine(*engtype_3D)\\Utilization Percentage';" +
                                "foreach ($sample in $counter.CounterSamples) {" +
                                "$sample.InstanceName + ',' + $sample.CookedValue" +
                                "}";
                PowerShellInstance.AddScript(script);

                // Invoke execution on the PowerShell object
                Collection<PSObject> PSOutput = PowerShellInstance.Invoke();

                // Check for errors
                if (PowerShellInstance.Streams.Error.Count > 0)
                {
                    foreach (ErrorRecord error in PowerShellInstance.Streams.Error)
                    {
                        Logger.Log($"error in powershell output: {error}");
                    }
                }
                else
                {
                    // Output the results
                    foreach (PSObject outputItem in PSOutput)
                    {
                        result.Add(outputItem.ToString());
                    }
                }
            }
            return result;
        }


    }
}