using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Zal;
using Zal.Constants.Models;
using Zal.Functions;
using Zal.MajorFunctions;

namespace Zal.Functions.MajorFunctions
{
    /// <summary>
    /// this class is responsible for getting computerdata, collect charts and send them to mobile & the server.
    /// </summary>
    public class DataManager
    {
        //if this is true, the loop will run every 1 second. if false, the loop will run every 5 seconds.
        private bool isMobileConnected = false;
        private readonly EventHandler<computerData> computerDataReceived;
        private readonly ChartsDataManager chartsDataManager = new ChartsDataManager();
        public DataManager(EventHandler<computerData> computerDataReceived)
        {
            this.computerDataReceived = computerDataReceived;
            startLoop();
        }
        public void setMobileConnectionState(bool state)
        {
            isMobileConnected = state;
            sendDataToMobile();
        }
        private async Task startLoop()
        {
            await Task.Delay(2000);
            while (true)
            {
                System.Diagnostics.Debug.WriteLine($"mobile conneciton:{isMobileConnected}");

                if (isMobileConnected)
                {
                    sendDataToMobile();
                }

                //wait before getting data again.
                await Task.Delay(900);
            }
        }
        private async Task<computerData?> getComputerDataAsync()
        {
            try
            {
                var data = await FrontendGlobalClass.Instance.backend?.getComputerDataAsync();
                if (data != null)
                {
                    computerDataReceived.Invoke(null, data);
                }

                return data;
            }

            catch (Exception e)
            {
                Logger.LogError("error getting computerdata", e);
            }
            return null;
        }
        public async Task<Dictionary<string, object>?> getBackendData()
        {
            var data = new Dictionary<string, object>();
            var computerData = await getComputerDataAsync();
            data["computerData"] = computerData;
            if (computerData != null)
            {
                data["charts"] = await chartsDataManager.updateAsync(computerData);

                //this whole thing is just to replace the gpus with only the primary gpu
                var serializedComputerData = Newtonsoft.Json.JsonConvert.SerializeObject(computerData);
                var dictionaryComputerData = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(serializedComputerData);
                dictionaryComputerData["gpuData"] = await ChartsDataManager.getPrimaryGpu(computerData);
                dictionaryComputerData["availableGpus"] = computerData.gpuData.Select(gpu => gpu.name).ToList();
                data["computerData"] = dictionaryComputerData;
            }
            return data;
        }
        private async Task sendDataToMobile()
        {
            var data = await getBackendData();
            var compressedData = CompressGzip(Newtonsoft.Json.JsonConvert.SerializeObject(data));
            FrontendGlobalClass.Instance.localSocket?.sendMessage("pc_data", compressedData);
        }
        static string CompressGzip(string text)
        {
            byte[] enCodedJson = Encoding.UTF8.GetBytes(text);

            using (MemoryStream memoryStream = new MemoryStream())
            {
                using (GZipStream gzipStream = new GZipStream(memoryStream, CompressionMode.Compress))
                {
                    gzipStream.Write(enCodedJson, 0, enCodedJson.Length);
                }

                byte[] gZipJson = memoryStream.ToArray();
                string base64Json = Convert.ToBase64String(gZipJson);
                return base64Json;
            }
        }
    }
}

class ChartsDataManager
{
    private readonly Dictionary<string, List<object>> data = new Dictionary<string, List<object>>();

    public ChartsDataManager()
    {
    }

    public async Task<Dictionary<string, List<object>>> updateAsync(computerData computerData)
    {
        var primaryGpu = await getPrimaryGpu(computerData);
        var empty = new List<object>();
        if (primaryGpu != null)
        {
            data["gpuLoad"] = addElementToList(data.GetValueOrDefault("gpuLoad", []), primaryGpu.corePercentage);
            data["gpuTemperature"] = addElementToList(data.GetValueOrDefault("gpuTemperature", []), primaryGpu.temperature);
            data["gpuPower"] = addElementToList(data.GetValueOrDefault("gpuPower", []), primaryGpu.power);
        }

        if (computerData.cpuData != null)
        {
            data["cpuLoad"] = addElementToList(data.GetValueOrDefault("cpuLoad", []), computerData.cpuData.load);
            data["cpuTemperature"] = addElementToList(data.GetValueOrDefault("cpuTemperature", []), computerData.cpuData.temperature);
        }

        if (computerData.ramData != null)
        {
            data["ramPercentage"] = addElementToList(data.GetValueOrDefault("ramPercentage", []), computerData.ramData.memoryUsedPercentage);
        }

        if (computerData.primaryNetworkSpeed != null)
        {
            data["networkDownload"] = addElementToList(data.GetValueOrDefault("networkDownload", []), computerData.primaryNetworkSpeed.download / 1024 / 1024);
        }

        return data;
    }

    public static async Task<gpuData?> getPrimaryGpu(computerData computerData)
    {
        var primaryGpuName = (string?)LocalDatabase.Instance.readKey("primaryGpu");
        gpuData? primaryGpu = null;
        //Logger.Log($"fetching primary gpu object from name {primaryGpuName}");
        foreach (var gpu in computerData.gpuData)
        {
            if (gpu.name == primaryGpuName)
            {
                return gpu;
            }
        }

        Logger.Log($"failed to find gpu object by name {primaryGpuName}, will try to get first gpu");
        if (computerData.gpuData.Count != 0)
        {
            return computerData.gpuData.First();
        }
        else
        {
            Logger.Log("available gpu is 0, will return no gpu");
            return null;
        }
    }

    private static List<object> addElementToList(List<object>? oldList, object element)
    {
        var maxElements = 60;

        var newList = oldList ?? [];
        newList.Add(element);
        if (newList.Count > maxElements)
        {
            newList.RemoveAt(0);
        }

        return newList;
    }
}