using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.HelperFunctions;
using ZalConsole.HelperFunctions.SpecificFunctions;

namespace Zal
{
    public class BackendManager
    {
        private readonly computerDataGetter computerDataGetter;
        public event EventHandler<string> fpsDataReceived;
        private readonly FpsDataGetter fpsDataGetter = new();

        public BackendManager()
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

        public string getEntireComputerData()
        {
            return computerDataGetter.getEntireComputerData();
        }

        public Dictionary<string, Dictionary<string, dynamic>> getGpuProcesses()
        {
            var gpuProcesses = GpuUtilizationGetter.getProcessesGpuUsage();
            return gpuProcesses;
        }

        public void startFps(int pid, bool logFps)
        {
            _ = Task.Run(async () =>
            {
                Logger.Log($"starting presentmon (fps getter), pid:{pid},logging:{logFps}");
                fpsDataGetter.startPresentmon(pid, logFps);
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
