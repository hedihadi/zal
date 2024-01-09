using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Zal.Constants.Models;

namespace ZalConsole.HelperFunctions.SpecificFunctions
{
     class NetworkSpeedGetter
    {
        public networkSpeed primaryNetworkSpeed;
        private Timer networkInterfaceTimer;
        public List<networkInterfaceData> networkInterfaces;
        public NetworkSpeedGetter()
        {
            networkSpeed s =new networkSpeed(0,0);
            this.primaryNetworkSpeed = s;

            //run code that gets networkInterfaces every 5 seconds
            networkInterfaceTimer = new Timer(_ =>
            {
                // Call your method directly inside the timer
                var result = getNetworkInterfaces();
                this.networkInterfaces = result;
            }, null, 0, 5000);

            //run code that periodically gets the primary network speed
            Task.Run(() =>
            {
                while (true)
                {
                    getPrimaryNetworkSpeed();
                }
            });

          
        }
       private void getPrimaryNetworkSpeed() {
            var nics = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces();
            // Select desired NIC
            var a = Settings.Default.primaryNetwork;
            var nic = nics.SingleOrDefault(n => n.Name == Settings.Default.primaryNetwork);
            if (nic == null)
            {
                return;
            }
            var readsBr = new List<double>();
            var readsBs = new List<double>();
            var sw = new Stopwatch();
            var lastBr = nic.GetIPv4Statistics().BytesReceived;
            var lastBs = nic.GetIPv4Statistics().BytesSent;
            for (var i = 0; i < 100; i++)
            {

                sw.Restart();
                Thread.Sleep(100);
                var elapsed = sw.Elapsed.TotalSeconds;
                var br = nic.GetIPv4Statistics().BytesReceived;
                var bs = nic.GetIPv4Statistics().BytesSent;

                var localBr = (br - lastBr) / elapsed;
                var localBs = (bs - lastBs) / elapsed;
                lastBr = br;
                lastBs = bs;

                // Keep last 20, ~2 seconds
                readsBr.Insert(0, localBr);
                if (readsBr.Count > 20)
                {
                    readsBr.RemoveAt(readsBr.Count - 1);
                }
                readsBs.Insert(0, localBs);
                if (readsBs.Count > 20)
                {
                    readsBs.RemoveAt(readsBs.Count - 1);
                }
                if (i % 10 == 0)
                { // ~1 second
                    var brSec = readsBr.Sum() / readsBs.Count();
                    var bsSec = readsBs.Sum() / readsBs.Count();
                    networkSpeed s = new networkSpeed((int)brSec, (int)bsSec);
                    this.primaryNetworkSpeed = s;
                }
            }
        }

        private List<networkInterfaceData> getNetworkInterfaces()
        {
            if (!NetworkInterface.GetIsNetworkAvailable())
                return new List<networkInterfaceData>();

            NetworkInterface[] interfaces
                = NetworkInterface.GetAllNetworkInterfaces();
            List<networkInterfaceData> data = new List<networkInterfaceData>();
            string primaryNetwork = Settings.Default.primaryNetwork;

            foreach (NetworkInterface ni in interfaces)
            {
                var stats = ni.GetIPv4Statistics();
                networkInterfaceData info = new networkInterfaceData();
                info.name = ni.Name;
                info.description = ni.Description;
                info.status = ni.OperationalStatus.ToString();
                info.id = ni.Id;
                info.bytesReceived = stats.BytesReceived;
                info.bytesSent = stats.BytesSent;
                info.isPrimary = primaryNetwork == ni.Name;
                data.Add(info);
            }
            data.Sort(delegate (networkInterfaceData c1, networkInterfaceData c2) { return c2.bytesReceived.CompareTo(c1.bytesReceived); });
            if (Settings.Default.primaryNetwork == "0")
            {
                //if primary network interface isn't set, we'll set it to the network with highest downloaded bytes
                Settings.Default.primaryNetwork = data[0].name;
                Settings.Default.Save();
                Settings.Default.Reload();
                Settings.Default.Upgrade();


                primaryNetwork = Settings.Default.primaryNetwork;
            }
            //get the speed of primary network
            return data;
        }
    }
}
public class networkInterfaceData
{
    public string name { get; set; }
    public string description { get; set; }
    public string status { get; set; }
    public string id { get; set; }
    public long bytesSent { get; set; }
    public long bytesReceived { get; set; }
    public bool isPrimary { get; set; }
}