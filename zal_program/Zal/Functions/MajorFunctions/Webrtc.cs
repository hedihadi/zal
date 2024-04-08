using Newtonsoft.Json;
using SIPSorcery.Net;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Threading.Tasks;
using Zal.Functions.Models;
using Zal.HelperFunctions.SpecificFunctions;
using Zal.MajorFunctions;
using ZalConsole.HelperFunctions;

namespace Zal.Functions.MajorFunctions
{
    public class Webrtc
    {
        RTCPeerConnection? pc;
        RTCDataChannel? dataChannel;
        public event EventHandler<RTCPeerConnectionState> connectionStateChanged;
        public event EventHandler<WebrtcData> messageReceivedEvent;

        public Webrtc(EventHandler<RTCPeerConnectionState> connectionStateChanged)
        {
            this.connectionStateChanged = connectionStateChanged;
        }

        public async Task start(string data)
        {
            var pc = await CreatePeerConnection();

            RTCSessionDescriptionInit answerInit = JsonConvert.DeserializeObject<RTCSessionDescriptionInit>(data);

            var res = pc.setRemoteDescription(answerInit);
            if (res != SetDescriptionResultEnum.OK)
            {
                // No point continuing. Something will need to change and then try again.
                pc.Close("failed to set remote sdp");
                await FrontendGlobalClass.Instance.serverSocket.socketio.EmitAsync("offer_failed");
                return;
            }

            var answer = pc.createAnswer();
            //await pc.setLocalDescription(answer);
            await FrontendGlobalClass.Instance.serverSocket.socketio.EmitAsync("accept_answer", answer.toJSON());
        }

        private async Task<RTCPeerConnection?> CreatePeerConnection()
        {
            RTCConfiguration config = new RTCConfiguration
            {
                iceServers = new List<RTCIceServer>
                {
                    new RTCIceServer { urls = "stun:stun.relay.metered.ca:80" },
                    new RTCIceServer
                    {
                        urls = "turn:global.relay.metered.ca:80",
                        username = "1e0b3b6edb6997a73313ef82",
                        credential = "i27Gzv1zV/ClbtLM",
                    },
                    new RTCIceServer
                    {
                        urls = "turn:global.relay.metered.ca:80?transport=tcp",
                        username = "1e0b3b6edb6997a73313ef82",
                        credential = "i27Gzv1zV/ClbtLM",
                    },
                    new RTCIceServer
                    {
                        urls = "turn:global.relay.metered.ca:443",
                        username = "1e0b3b6edb6997a73313ef82",
                        credential = "i27Gzv1zV/ClbtLM",
                    },
                    new RTCIceServer
                    {
                        urls = "turns:global.relay.metered.ca:443?transport=tcp",
                        username = "1e0b3b6edb6997a73313ef82",
                        credential = "i27Gzv1zV/ClbtLM",
                    },
                }
            };
            var pc = new RTCPeerConnection(config);

            var dc = await pc.createDataChannel("zaldatachannel", null);
            dataChannel = dc;
            dataChannel.onmessage += (datachan, type, data) =>
            {
                System.Diagnostics.Debug.WriteLine("message");
                string message = Encoding.UTF8.GetString(data);
                var parsedMessage = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(message);
                WebrtcData webrtcData = new WebrtcData();
                webrtcData.data = parsedMessage["data"];
                webrtcData.name = (string)parsedMessage["name"];
                messageReceivedAsync(webrtcData);
            };
            pc.onconnectionstatechange += (state) =>
            {
                connectionStateChanged.Invoke(null, state);

                //notify dataManager about the connection state
                FrontendGlobalClass.Instance.dataManager.setMobileConnectionState(state == RTCPeerConnectionState.connected);
                if (state == RTCPeerConnectionState.connected)
                {
                    Task.Delay(2000).ContinueWith(async (a) =>
                    {
                        await FrontendGlobalClass.Instance.notificationsManager.broadcastNotificationsToMobile();
                    });
                }

                if (state == RTCPeerConnectionState.failed)
                {
                    pc.Close("ice disconnection");
                }
                else if (state == RTCPeerConnectionState.connected)
                {
                    GlobalClass.Instance.processesGetter.resetSentIcons();
                }
                else if (state == RTCPeerConnectionState.disconnected)
                {
                    //execute this code in case the user disconnected while fps running.
                    FrontendGlobalClass.Instance.backend?.stopFps();
                    GlobalClass.Instance.processesGetter.resetSentIcons();
                }
            };

            return pc;
        }

        private async Task messageReceivedAsync(WebrtcData messageData)
        {
            if (messageData.name == "get_gpu_processes")
            {
                try
                {
                    var data = Newtonsoft.Json.JsonConvert.SerializeObject(FrontendGlobalClass.Instance.backend.getGpuProcesses());
                    sendMessage("gpu_processes", data);
                }
                catch (Exception e)
                {
                    Logger.LogError("error getting GPU Processes", e);
                    sendMessage("information_text", $"error getting GPU Processes: {e.Message}");
                }
            }
            else if (messageData.name == "start_fps")
            {
                FrontendGlobalClass.Instance.backend?.startFps(int.Parse(messageData.data.ToString()), FrontendGlobalClass.Instance.shouldLogFpsData);
                FrontendGlobalClass.Instance.backend.fpsDataReceived += (sender, e) =>
                {
                    sendMessage("fps_data", e);
                };
            }
            else if (messageData.name == "stop_fps")
            {
                FrontendGlobalClass.Instance.backend?.stopFps();
            }
            else if (messageData.name == "edit_notification")
            {
                var data = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(messageData.data.ToString());
                FrontendGlobalClass.Instance.notificationsManager.editNotification(data);
            }
            else if (messageData.name == "new_notification")
            {
                var data = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(messageData.data.ToString());
                FrontendGlobalClass.Instance.notificationsManager.newNotification(data);
            }
            else if (messageData.name == "restart_admin")
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
            else if (messageData.name == "change_primary_network")
            {
                await LocalDatabase.Instance.writeKey("primaryNetwork", messageData.data.ToString());

            }
            else if (messageData.name == "launch_app")
            {
                var processpath = ProcesspathGetter.load(messageData.data.ToString());
                if (processpath != null)
                {
                    System.Diagnostics.Process.Start(processpath);
                    sendMessage("information_text", $"{messageData.data} launched!");
                }
                else
                {
                    sendMessage("information_text", $"failed to launch {processpath}, we couldn't find the Program location.");
                }
            }
            else if (messageData.name == "get_process_icon")
            {
                var processpath = ProcesspathGetter.load(messageData.data.ToString());
                if (processpath != null)
                {
                    var icon = await GlobalClass.Instance.processesGetter.getFileIcon(processpath);
                    sendMessage("process_icon", new Dictionary<string, string>() { { "name", messageData.data.ToString() }, { "icon", icon } });
                }

            }
            else if (messageData.name == "kill_process")
            {
                var pids = Newtonsoft.Json.JsonConvert.DeserializeObject<List<int>>(messageData.data.ToString());
                foreach (var pid in pids)
                {
                    System.Diagnostics.Process.GetProcessById(pid).Kill();
                }

                sendMessage("information_text", $"Process killed!");

            }
            else
            {
                throw new Exception($"{messageData.name} is not handled");
            }
        }

        public bool isConnected()
        {
            return dataChannel?.IsOpened ?? false;
        }

        public void sendMessage(string name, object data)
        {
            var map = new Dictionary<string, object>();
            map["data"] = data;
            map["name"] = name;
            var compressed = Newtonsoft.Json.JsonConvert.SerializeObject(map);
            dataChannel?.send(compressed);
        }
    }
}
