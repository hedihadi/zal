using System;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.Functions.MajorFunctions;
using Zal.Functions.Models;

namespace Zal.MajorFunctions
{
    public class FrontendGlobalClass
    {
        private static FrontendGlobalClass? instance;
        public LocalSocket localSocket;
        public BackendManager backend;
        public DataManager dataManager;
        public bool shouldLogFpsData = false;
        private FrontendGlobalClass(
            EventHandler<SocketConnectionState> socketConnectionStateChanged,
            EventHandler<computerData> computerDataReceived

            )
        {
            // Initialization code here
            backend = new BackendManager();
            localSocket = new LocalSocket(stateChanged: socketConnectionStateChanged);
            dataManager = new DataManager(computerDataReceived);


        }
        public static async Task Initialize(
            EventHandler<SocketConnectionState> socketConnectionStateChanged,
            //invoked when we retrieve computerData
            EventHandler<computerData> computerDataReceived
            )
        {
            await LocalDatabase.Initialize();
            instance = new FrontendGlobalClass(socketConnectionStateChanged, computerDataReceived);


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
