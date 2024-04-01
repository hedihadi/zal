using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ZalConsole.HelperFunctions.SpecificFunctions;
using Zal.Constants.Models;
using Zal.HelperFunctions;

namespace Zal
{
    public class Backend
    {
        computerDataGetter computerDataGetter = null;
        public event EventHandler<string> fpsDataReceived;
        FpsDataGetter fpsDataGetter = new FpsDataGetter();
        public Backend()
        {
            try
            {
                computerDataGetter = new computerDataGetter();
            }
            catch (Exception c)
            {
                Logger.LogError("error initializing computerDataGetter", c);
            }
        }
        public async Task<computerData> getComputerDataAsync()
        {
            return await computerDataGetter.getcomputerDataAsync();
        }
        public Dictionary<String, Dictionary<string, dynamic>> getGpuProcesses()
        {
            var gpuProcesses = GpuUtilizationGetter.getProcessesGpuUsage();
            return gpuProcesses;
        }
        public void startFps(int pid)
        {
            _ = Task.Run(async () =>
            {
                fpsDataGetter.startPresentmon(pid);
                fpsDataGetter.sendFpsData += (sender, fpsData) =>
                {
                    var data = Newtonsoft.Json.JsonConvert.SerializeObject(fpsData);
                    fpsDataReceived.Invoke(this, data);
                };
            });
        }
        public void stopFps()
        {
            fpsDataGetter.stopPresentmon();
        }
    }
}
