using System;
using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json;
using SocketIOClient;
using Zal.Functions.Models;
using Zal.MajorFunctions;
using ZalConsole.HelperFunctions;

namespace Zal.Functions.MajorFunctions
{
    public class LocalSocket
    {
        //public event EventHandler<ServerSocketConnectionState> connectionStateChanged;
        public SocketIOClient.SocketIO socketio;
        public bool isConnected = false;
        public bool isMobileConnected = false;
        private Process? serverProcess;
        public LocalSocket(
            //EventHandler<ServerSocketConnectionState> stateChanged
            )
        {
            //  connectionStateChanged = stateChanged;
            setupSocketio();
        }

        private async void setupSocketio()
        {
            //run the server
            var filePath = GlobalClass.Instance.getFilepathFromResources("server.exe");
            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = filePath,
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = $"",
            };
            serverProcess = new Process { StartInfo = startInfo };
            try
            {

                serverProcess.Start();
            }
            catch (Exception ex)
            {
                Logger.LogError($"error running server process", ex);
            }


            var ip = Zal.Backend.HelperFunctions.SpecificFunctions.IpGetter.getIp();
            socketio = new SocketIOClient.SocketIO($"http://{ip}:4920",
                new SocketIOOptions
                {
                    Query = new List<KeyValuePair<string, string>>
                    {
                        //new KeyValuePair<string, string>("uid", uid),

                    }
                });

            socketio.On("room_clients", response =>
            {

                int parsedData = response.GetValue<int>();
                Logger.Log($"local socketio room_clients {parsedData}");
                // if the data is 1, that means w'ere the only one connected to this server. if it's more than 1, it means a mobile is connected to the server.
                isMobileConnected = parsedData != 0;
                FrontendGlobalClass.Instance.dataManager.setMobileConnectionState(isMobileConnected);

            });
            socketio.OnAny((eventName, data) =>
            {
                if (eventName == "room_clients") return;
                var parsedMessage = JsonConvert.DeserializeObject<Dictionary<string, object>>(data.GetValue<string>());
                WebrtcData webrtcData = new WebrtcData();
                webrtcData.data = parsedMessage["data"];
                webrtcData.name = (string)parsedMessage["name"];
                FrontendGlobalClass.Instance.webrtc.messageReceivedAsync(webrtcData);
            });
            socketio.OnConnected += (sender, args) =>
            {
                isConnected = true;
                // connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connected);
            };
            socketio.OnDisconnected += (sender, args) =>
            {
                isConnected = false;
                // connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connecting);
                connectToServer();
            };
            connectToServer();
        }

        private async void connectToServer()
        {
            //connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connecting);

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
            catch (Exception ex)
            {
                connectToServer();
            }
        }
        public void sendMessage(object data)
        {
            socketio?.EmitAsync("message", data);
        }
    }
}
