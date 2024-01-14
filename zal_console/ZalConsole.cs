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
            try
            {
                 computerDataGetter = new computerDataGetter(client);
            }
            catch (Exception c)
            {
                Logger.LogError("error initializing computerDataGetter", c);
            }

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


            // The rest of your code

            // While loop example (uncomment if needed)
            // while (true)
            // {
            //     Console.WriteLine(a.getcomputerData());
            //     Thread.Sleep(1000);
            // }
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
