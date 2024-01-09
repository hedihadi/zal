using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using Zal;

namespace ZalConsole.HelperFunctions.SpecificFunctions
{
     class GpuUtilizationGetter
    {
        //this function is based on this https://github.com/GameTechDev/PresentMon/issues/189
        //and some modifications to make the data to be parsed easier from c# side.
        public static Dictionary<int,double> getProcessesGpuUsage()
        {
            Dictionary<int,double > result= new Dictionary<int,double>();   
          var rawData=  getRawDataFromPowershell();
           foreach(var process in rawData)
            {
                var splittedData=process.Split(',');
                int pid = int.Parse(splittedData[0].Split('_')[1]);
                double usage = double.Parse(splittedData[1]);
                if(usage!=0)
                {
                    result[pid]= usage;
                }
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
