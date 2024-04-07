using SIPSorcery.Net;
using System;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.Functions.MajorFunctions;
using Zal.Functions.Models;
using ZalConsole.HelperFunctions;

namespace Zal.MajorFunctions
{
    public class FrontendGlobalClass
    {
        private static FrontendGlobalClass? instance;
        public ServerSocket serverSocket;
        public Backend backend;
        public Webrtc webrtc;
        public DataManager dataManager;
        public NotificationsManager notificationsManager;
        public RunningProgramsTracker runningProgramsTracker;
        public bool shouldLogFpsData = false;
        private FrontendGlobalClass(EventHandler<RTCPeerConnectionState> webrtcConnectionStateChanged,
            EventHandler<ServerSocketConnectionState> socketServerConnectionStateChanged,
            EventHandler<computerData> computerDataReceived

            )
        {
            // Initialization code here
            backend = new Backend();
            serverSocket = new ServerSocket(socketServerConnectionStateChanged);
            webrtc = new Webrtc(webrtcConnectionStateChanged);
            dataManager = new DataManager(computerDataReceived);
            notificationsManager = new NotificationsManager();
            consumerTimeTask();
            runningProgramsTracker = new RunningProgramsTracker();


        }
        public static async void Initialize(EventHandler<RTCPeerConnectionState> webrtcConnectionStateChanged,
            EventHandler<ServerSocketConnectionState> socketServerConnectionStateChanged,
            //invoked when we retrieve computerData
            EventHandler<computerData> computerDataReceived
            )
        {
            instance = new FrontendGlobalClass(webrtcConnectionStateChanged, socketServerConnectionStateChanged, computerDataReceived);


        }

        //this function notifies the server every 5 minutes, this is used to show app usage in the app
        private async Task consumerTimeTask()
        {
            while (true)
            {
                //wait for 5 mintues
                await Task.Delay(300000);
                //send data to database
                var response = await ApiManager.SendDataToDatabase("consumer-times");
                Console.WriteLine(response);

            }
        }
        public static FrontendGlobalClass Instance
        {
            get
            {
                if (instance == null)
                {
                    throw new Exception("call Initialize first");
                }
                return instance;
            }
        }

    }

}
