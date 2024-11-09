using Newtonsoft.Json;
using SocketIOClient;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Zal.Functions.Models;
using Zal.HelperFunctions.SpecificFunctions;
using Zal.MajorFunctions;
using ZalConsole.HelperFunctions;

namespace Zal.Functions.MajorFunctions
{
    public class LocalSocket
    {
        public event EventHandler<SocketConnectionState> connectionStateChanged;
        public SocketIOClient.SocketIO socketio;
        public bool isConnected;
        public bool isMobileConnected;
        private Process? serverProcess;
        public LocalSocket(
            EventHandler<SocketConnectionState> stateChanged
            )
        {
            connectionStateChanged = stateChanged;
            setupSocketio();
        }
        public async void restartSocketio()
        {
            await setupSocketio();
        }
        private async Task killSocketProcess()
        {
            foreach (var process in Process.GetProcessesByName("server"))
            {
                process.Kill();
            }
        }
        private async Task setupSocketio()
        {
            await killSocketProcess();
            //run the server
            var port = LocalDatabase.Instance.readKey("port")?.ToString() ?? "4920";
            var pcName = (string?)LocalDatabase.Instance.readKey("pcName");
            if (pcName == null)
            {
                try
                {
                    pcName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
                }
                catch
                {
                    pcName = "Default Computer";
                }
            }
            pcName = string.Concat(pcName.Where(char.IsLetterOrDigit));
            var filePath = GlobalClass.Instance.getFilepathFromResources("server.exe");
            var startInfo = new ProcessStartInfo
            {
                FileName = filePath,
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = $"{port} \"{pcName}\"",
            };
            serverProcess = new Process
            {
                StartInfo = startInfo,
                EnableRaisingEvents = true // Enables the Exited event to be raised
            };
            serverProcess.Exited += (sender, args) =>
            {
                System.Diagnostics.Debug.WriteLine(args);
            };
            try
            {

                serverProcess.Start();
            }
            catch (Exception ex)
            {
                Logger.LogError("error running server process", ex);
            }

            var ip = Zal.Backend.HelperFunctions.SpecificFunctions.IpGetter.getIp();
            socketio = new SocketIOClient.SocketIO($"http://{ip}:{port}",
                new SocketIOOptions
                {
                    Query = new List<KeyValuePair<string, string>>
                    {
                        //new KeyValuePair<string, string>("uid", uid),

                    }
                });

            socketio.On("room_clients", response =>
            {

                var parsedData = response.GetValue<int>();
                Logger.Log($"local socketio room_clients {parsedData}");
                // if the data is 1, that means w'ere the only one connected to this server. if it's more than 1, it means a mobile is connected to the server.
                isMobileConnected = parsedData > 1;
                FrontendGlobalClass.Instance.dataManager.setMobileConnectionState(isMobileConnected);
                connectionStateChanged.Invoke(null, isMobileConnected ? SocketConnectionState.Connected : SocketConnectionState.Disconnected);
            });
            socketio.On("get_directory", response =>
            {


                var parsedData = response.GetValue<int>();
                Logger.Log($"local socketio room_clients {parsedData}");
                // if the data is 1, that means w'ere the only one connected to this server. if it's more than 1, it means a mobile is connected to the server.
                isMobileConnected = parsedData > 1;
                FrontendGlobalClass.Instance.dataManager.setMobileConnectionState(isMobileConnected);
            });
            socketio.On("get_gpu_processes", response =>
            {
                try
                {
                    var data = JsonConvert.SerializeObject(FrontendGlobalClass.Instance.backend.getGpuProcesses());
                    sendMessage("gpu_processes", data);
                }
                catch (Exception e)
                {
                    Logger.LogError("error getting GPU Processes", e);
                    sendMessage("information_text", $"error getting GPU Processes: {e.Message}");
                }
            });

            socketio.On("start_fps", response =>
            {
                var data = int.Parse(response.GetValue<string>());
                FrontendGlobalClass.Instance.backend?.startFps(data, FrontendGlobalClass.Instance.shouldLogFpsData);
                FrontendGlobalClass.Instance.backend.fpsDataReceived += (sender, e) =>
                {
                    sendMessage("fps_data", e);
                };
            });

            socketio.On("stop_fps", response =>
            {
                FrontendGlobalClass.Instance.backend?.stopFps();
            });


            socketio.On("restart_admin", response =>
            {
                var selfPath = Process.GetCurrentProcess().MainModule.FileName;
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
            });

            socketio.On("change_primary_network", async response =>
            {
                var parsedData = response.GetValue<string>();
                await LocalDatabase.Instance.writeKey("primaryNetwork", parsedData);
            });

            socketio.On("launch_app", response =>
            {
                var parsedData = response.GetValue<string>();
                var processpath = ProcesspathGetter.load(parsedData);
                if (processpath != null)
                {
                    Process.Start(processpath);
                    sendMessage("information_text", $"{parsedData} launched!");
                }
                else
                {
                    sendMessage("information_text", $"failed to launch {processpath}, we couldn't find the Program location.");
                }
            });

            socketio.On("get_process_icon", async response =>
            {
                var parsedData = response.GetValue<string>();
                var processpath = ProcesspathGetter.load(parsedData);
                if (processpath != null)
                {
                    var icon = await GlobalClass.Instance.processesGetter.getFileIcon(processpath);
                    sendMessage("process_icon", new Dictionary<string, string>() { { "name", parsedData }, { "icon", icon } });
                }
            });

            socketio.On("kill_process", response =>
            {
                var parsedData = response.GetValue<string>();
                var pids = JsonConvert.DeserializeObject<List<int>>(parsedData);
                foreach (var pid in pids)
                {
                    try
                    {
                        Process.GetProcessById(pid).Kill();
                    }
                    catch (Exception ex)
                    {
                        sendMessage("information_text", $"failed to kill a process,{ex.Message}");
                    }
                }

                sendMessage("information_text", "Process killed!");
            });

            socketio.OnConnected += (sender, args) =>
            {
                isConnected = true;

            };
            socketio.OnDisconnected += (sender, args) =>
            {
                isConnected = false;
                connectToServer();
            };
            connectToServer();
        }

        private async void connectToServer()
        {

            if (isConnected)
            {
                await socketio.DisconnectAsync();
                isConnected = false;
                return;
            }

            try
            {
                socketio.ConnectAsync();
            }
            catch (Exception)
            {
                connectToServer();
            }
        }
        public void sendMessage(String key, object data)
        {
            socketio?.EmitAsync(key, data);
        }
    }
}
