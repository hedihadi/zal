using Firebase.Auth.UI;
using SocketIOClient;
using System;
using System.Collections.Generic;
using Zal.Functions.Models;
using Zal.MajorFunctions;

namespace Zal.Functions.MajorFunctions
{
    public class ServerSocket
    {
        public event EventHandler<ServerSocketConnectionState> connectionStateChanged;
        public SocketIOClient.SocketIO socketio;
        public bool isConnected;

        public ServerSocket(EventHandler<ServerSocketConnectionState> stateChanged)
        {
            connectionStateChanged = stateChanged;
            setupSocketio();
        }

        private async void setupSocketio()
        {

            var uid = FirebaseUI.Instance.Client.User.Uid;
            string? idToken;
            try
            {
                idToken = await FirebaseUI.Instance.Client.User.GetIdTokenAsync();
            }
            catch
            {
                FirebaseUI.Instance.Client.SignOut();
                return;
            }

            socketio = new SocketIOClient.SocketIO("https://api.zalapp.com",
                new SocketIOOptions
                {
                    Query = new List<KeyValuePair<string, string>>
                    {
                        new("uid", uid),
                        new("idToken", idToken),
                        new("type", "0"),
                        new("version", "1"),
                        new("computerName", "default")
                    }
                });

            socketio.On("room_clients", response =>
            {

                var parsedData = response.GetValue<List<int>>();
                Logger.Log($"socketio room_clients {string.Join<int>(",", parsedData)}");
                // if the data is 1, that means the client type is 1, which means this client is a phone
                if (parsedData.Contains(1))
                {
                    Console.WriteLine(parsedData);
                }
            });
            socketio.On("offer_sdp", response =>
            {
                var parsedData = response.GetValue<dynamic>();

                FrontendGlobalClass.Instance.webrtc.start(parsedData.ToString());

            });
            socketio.OnConnected += (sender, args) =>
            {
                isConnected = true;
                connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connected);
            };
            socketio.OnDisconnected += (sender, args) =>
            {
                isConnected = false;
                connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connecting);
                connectToServer();
            };
            connectToServer();
        }

        private async void connectToServer()
        {
            connectionStateChanged.Invoke(null, ServerSocketConnectionState.Connecting);

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
    }
}
