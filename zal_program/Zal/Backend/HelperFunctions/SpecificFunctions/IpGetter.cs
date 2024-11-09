using System.Net;
using System.Net.Sockets;

namespace Zal.Backend.HelperFunctions.SpecificFunctions;

internal class IpGetter
{
    public static string getIp()
    {
        using (var socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, 0))
        {
            socket.Connect("8.8.8.8", 65530);
            var endPoint = socket.LocalEndPoint as IPEndPoint;
            var ip = endPoint.Address.ToString();
            Logger.Log($"ip found: {ip}");
            return ip;
        }
    }
}
