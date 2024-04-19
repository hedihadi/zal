using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.NetworkInformation;
using System.Threading;
using System.Threading.Tasks;
using Zal;
using Zal.Constants.Models;

namespace ZalConsole.HelperFunctions.SpecificFunctions
{
    internal class NetworkSpeedGetter
    {
        public networkSpeed primaryNetworkSpeed;
        private readonly Timer networkInterfaceTimer;
        public List<networkInterfaceData> networkInterfaceDatas;
        private List<NetworkInterface> networkInterfaces;

        public NetworkSpeedGetter()
        {
            var s = new networkSpeed(0, 0);
            primaryNetworkSpeed = s;

            //run code that gets networkInterfaces every 5 seconds
            networkInterfaceTimer = new Timer(async _ =>
            {
                // Call your method directly inside the timer
                var result = await getNetworkInterfacesAsync();
                networkInterfaceDatas = result;
            }, null, 0, 5000);

            //run code that periodically gets the primary network speed
            Task.Run(async () =>
            {
                while (true)
                {
                    var primaryNetwork = (string?)LocalDatabase.Instance.readKey("primaryNetwork");
                    getPrimaryNetworkSpeedAsync(primaryNetwork);
                }
            });
        }

        private async Task getPrimaryNetworkSpeedAsync(string? primaryNetwork)
        {
            //var nics = networkInterfaces();
            if (networkInterfaces == null)
            {
                networkInterfaces = NetworkInterface.GetAllNetworkInterfaces().ToList();
            }

            // Select desired NIC
            var a = primaryNetwork;
            var nic = networkInterfaces.SingleOrDefault(n => n.Name == primaryNetwork);
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
                {
                    // ~1 second
                    var brSec = readsBr.Sum() / readsBs.Count();
                    var bsSec = readsBs.Sum() / readsBs.Count();
                    var s = new networkSpeed((int)brSec, (int)bsSec);
                    primaryNetworkSpeed = s;
                }
            }
        }

        private async Task<List<networkInterfaceData>> getNetworkInterfacesAsync()
        {
            var primaryNetwork = LocalDatabase.Instance.readKey("primaryNetwork");
            if (!NetworkInterface.GetIsNetworkAvailable())
                return new List<networkInterfaceData>();

            var interfaces
                = NetworkInterface.GetAllNetworkInterfaces();
            List<networkInterfaceData> data = new List<networkInterfaceData>();

            foreach (var ni in interfaces)
            {
                var stats = ni.GetIPv4Statistics();
                var info = new networkInterfaceData
                {
                    name = ni.Name,
                    description = ni.Description,
                    status = ni.OperationalStatus.ToString(),
                    id = ni.Id,
                    bytesReceived = stats.BytesReceived,
                    bytesSent = stats.BytesSent,
                    isPrimary = primaryNetwork == ni.Name,
                };
                data.Add(info);
            }

            data.Sort(delegate(networkInterfaceData c1, networkInterfaceData c2) { return c2.bytesReceived.CompareTo(c1.bytesReceived); });
            if (primaryNetwork == null)
            {
                //if primary network interface isn't set, we'll set it to the network with highest downloaded bytes
                await LocalDatabase.Instance.writeKey("primaryNetwork", data[0].name);
                primaryNetwork = data[0].name;
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
