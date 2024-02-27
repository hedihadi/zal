using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Zal.HelperFunctions;
using ZalConsole;
using SocketIOClient;
using Newtonsoft.Json.Linq;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Windows.Forms;
using System.Collections.ObjectModel;
using System.Xml.Linq;
using System.Management.Automation;
using Microsoft.PowerShell.Commands;
using ZalConsole.HelperFunctions.SpecificFunctions;
using Zal;
using System.Diagnostics;
using Zal.HelperFunctions.SpecificFunctions;
using ZalConsole.HelperFunctions;
using Zal.Constants.Models;
using System.IO;
using Newtonsoft.Json;
using System.Management.Automation.Host;

namespace ZalConsole
{
    internal class ZalConsole
    {
       
        static async Task Main(string[] args)
        {

            



            Logger.ResetLog();
            if (args.Length != 0)
            {
                if (args[0] == "1")
                {
                    restartAsAdmin();
                }

            }
            computerDataGetter? computerDataGetter=null;
            
            SocketIOClient.SocketIO client = new SocketIOClient.SocketIO($"http://localhost:3000/");
            var runningProgramsTracker = new RunningProgramsTracker(client);
            FpsDataGetter? fpsDataGetter = new FpsDataGetter();
            FilesGetter fileGetter = new FilesGetter(client);

            try
            {
                 computerDataGetter = new computerDataGetter(client);
            }
            catch (Exception c)
            {
                Logger.LogError("error initializing computerDataGetter", c);
            }
            client.On("start_fps", async response =>
            {

                var pid = int.Parse(response.GetValue<String>());
                _ = Task.Run(async () =>
                {
                    fpsDataGetter.startPresentmon(pid);
                    fpsDataGetter.sendFpsData += (sender, fpsData) =>
                    {
                        var data = Newtonsoft.Json.JsonConvert.SerializeObject(fpsData);
                        client.EmitAsync("fps_data", data);
                    };
                });
               
            });
            client.On("stop_fps", response =>
            {
                fpsDataGetter.stopPresentmon();
              
            });

            var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(computerDataGetter.getcomputerData());
            client.On("get_process_icon", async response =>
            {
                var name = response.GetValue<String>();
                string? processPath = ProcesspathGetter.load(name);
                if(processPath != null)
                {
                  var icon=GlobalClass.Instance.getFileIcon(processPath);
                    if (icon == "") return;
                    
                    var data = JsonConvert.SerializeObject(new Dictionary<string, string>() { { "name", name }, { "icon", icon } });
                     await client.EmitAsync("process_icon",data);

                }
            });
            client.On("launch_app", async response =>
            {
                var name = response.GetValue<String>();
                string? processPath = ProcesspathGetter.load(name);
                if (processPath != null)
                {
                    System.Diagnostics.Process.Start(processPath);
                    await client.EmitAsync("information_text", $"{name} launched!");

                }
                else
                {
                    await client.EmitAsync("information_text", "failed to run application, you may have cleared temp folder.");
                }
            });
            client.On("get_gpu_processes", async response =>
            {
                try
                {
                    var gpuProcesses = GpuUtilizationGetter.getProcessesGpuUsage();
                    var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(gpuProcesses);
                    await client.EmitAsync("gpu_processes", serializedData);
                }
                catch (Exception ex)
                {
                    await client.EmitAsync("information_text", ex.ToString());
                }
               
            });
            client.On("get_data", async response =>
            {
                if (computerDataGetter != null) {

                    try
                    {
                        var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(computerDataGetter.getcomputerData());
                        //System.Diagnostics.Debug.WriteLine($"computer_data {serializedData}");
                        //Console.WriteLine($"computer_data {serializedData}");
                        // Do something with the serialized data, for example, send it back to the client
                        await client.EmitAsync("computer_data", serializedData);
                    }
                    catch (Exception c)
                    {
                        Logger.LogError("error getting computerData", c);
                    }
                   
                }
                

            });
            client.On("restart_admin", async response =>
            {
                restartAsAdmin();
            });
            client.On("change_primary_network", async response =>
            {
                var primary = response.GetValue<String>();
                Settings.Default.primaryNetwork = primary;
                Settings.Default.Save();
                Settings.Default.Upgrade();
                
            });
            client.OnConnected += async (sender, e) =>
            {
                Console.WriteLine("connected");
            };
            client.On("client_disconnected", async response =>
            {
                //kill every program we've run
                foreach (var process in Process.GetProcessesByName("task_manager"))
                {
                    process.Kill();
                }
                foreach (var process in Process.GetProcessesByName("zal-server"))
                {
                    process.Kill();
                }
                Environment.Exit(0);
            });
            
            client.OnError += async (sender, e) =>
            {
                Console.WriteLine($"err {e}");
            };

            //var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(computerDataGetter.getcomputerData());
            //Console.WriteLine($"{serializedData}");
            Console.WriteLine("Connecting...");
            while (true)
            {
                try
                {
                    await client.ConnectAsync();
                    break;
                }
                catch (Exception ex)
                {

                }
            }
            while (true)
            {

                Thread.Sleep(1000);

            }

        }
        private static void restartAsAdmin()
        {
            string selfPath = Process.GetCurrentProcess().MainModule.FileName;

            var proc = new Process
            {
                StartInfo =
                                {
                                      FileName = selfPath,
                                       UseShellExecute = true,
                                        Verb = "runas"
                                }
            };

            try
            {
                var result = proc.Start();
                Environment.Exit(0);
            }
            catch
            {

            }
            
        }

    }
}
