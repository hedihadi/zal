using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

namespace Zal.HelperFunctions
{
    public class ProcessesGetter
    {
        private readonly SocketIOClient.SocketIO client = new SocketIOClient.SocketIO($"http://localhost:6511/");
        private readonly Dictionary<string, TaskCompletionSource<string>> taskCompletionSources = new Dictionary<string, TaskCompletionSource<string>>();
        public Dictionary<string, object> data = new Dictionary<string, object>();

        //this list contains the names of processes that we've already loaded and sent to the phone.
        //this is to save network bandwidth as icons are quite large (i think about 5-10kb each),
        //so we cache the icons in the mobile app, and when the app disconnects, we reset this list
        //so that we send icons to the app once again when app reconnects.
        private readonly List<string> loadedIcons = new List<string>();

        public ProcessesGetter()
        {
            client.On("process_icon", async response =>
            {
                var data = response.GetValue<Dictionary<string, string?>>();
                var process = data["process"];
                var icon = data["icon"];
                if (taskCompletionSources.TryGetValue(process, out var tcs))
                {
                    tcs.SetResult(icon);
                    taskCompletionSources.Remove(process);
                }
            });
            client.ConnectAsync();
        }

        public void resetSentIcons()
        {
            loadedIcons.Clear();
        }

        public async Task<string?> getFileIcon(string filepath)
        {
            var tcs = new TaskCompletionSource<string?>();
            taskCompletionSources[filepath] = tcs;
            client.EmitAsync("get_process_icon", filepath);
            var timeoutTask = Task.Delay(2000); // Timeout after 2 seconds
            var completedTask = await Task.WhenAny(tcs.Task, timeoutTask);

            if (completedTask == timeoutTask)
            {
                // Timeout occurred
                return null;
            }
            else
            {
                return await tcs.Task;
            }
        }

        public async Task update()
        {
            Dictionary<string, object> result = new Dictionary<string, object>();
            var allProcesses = Process.GetProcesses();
            foreach (var process in allProcesses)
            {
                string processName = process.ProcessName;
                long ramUsageBytes = process.WorkingSet64;
                Dictionary<string, object> processData = new Dictionary<string, object>();
                if (result.ContainsKey(processName))
                {
                    processData = (Dictionary<string, object>)result[processName];
                    processData["memoryUsage"] = (long)processData["memoryUsage"] + ramUsageBytes / (1024 * 1024);
                    processData["pids"] = ((List<int>)processData["pids"]).Concat(new[] { (int)process.Id }).ToList();
                    result[processName] = processData;
                }
                else
                {
                    processData["memoryUsage"] = (long)ramUsageBytes / (1024 * 1024);
                    processData["pids"] = new List<int> { process.Id };
                    processData["cpuPercent"] = 0.0;

                    //get the process icon
                    try
                    {
                        //i've disabled icon loading until further insight.
                        //when the app connects to this program, we have to confidently reset the loadedIcons variable to make sure
                        //the app receives the process icons.
                        if (false)
                            //if (loadedIcons.Contains(processName) == false)
                        {
                            var filepath = process.MainModule.FileName;
                            var icon = await getFileIcon(filepath);
                            if (icon != null)
                            {
                                processData["icon"] = icon;
                                loadedIcons.Add(processName);
                            }
                        }
                    }
                    catch (Exception c)
                    {
                        // loadedIcons.Add(processName);
                    }

                    result[processName] = processData;
                }
            }

            data = result;
        }
    }
}
