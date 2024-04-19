using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.Functions.Models;
using Zal.MajorFunctions;
using ZalConsole.HelperFunctions;

namespace Zal.Functions.MajorFunctions
{
    public class NotificationsManager
    {
        private readonly List<NotificationData> notifications = new List<NotificationData>();
        private readonly List<NotificationWithTimestamp> notificationTimestamps = [];

        public NotificationsManager()
        {
            Task.Delay(2000).ContinueWith(t => { initialize(); });
        }

        private async Task initialize()
        {
            var data = await GlobalClass.Instance.readTextFromDocumentFolder("notifications");
            if (data != null)
            {
                try
                {
                    var parsedData = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(data);
                    foreach (var notif in parsedData)
                    {
                        await addNewNotification(NotificationData.FromDictionary(notif));
                    }

                    await broadcastNotificationsToMobile();
                }

                catch (Exception ex)
                {
                    Logger.LogError("error parsing notifications from local", ex, data);
                }
            }
            else
            {
                await setBasicNotificatons();
            }
        }

        async Task setBasicNotificatons()
        {

            await addNewNotification(new NotificationData(
                key: NotificationKey.Cpu,
                childKey: new NotificationKeyWithUnit(keyName: "temperature", unit: "C"),
                factorType: NotificationFactorType.Higher,
                factorValue: 75,
                secondsThreshold: 5,
                suspended: false
            ));

            await addNewNotification(new NotificationData(
                key: NotificationKey.Gpu,
                childKey: new NotificationKeyWithUnit(displayName: "Gpu", keyName: "temperature", unit: "C"),
                factorType: NotificationFactorType.Higher,
                factorValue: 75,
                secondsThreshold: 5,
                suspended: false
            ));
            await addNewNotification(new NotificationData(
                key: NotificationKey.Ram,
                childKey: new NotificationKeyWithUnit(keyName: "memoryUsedPercentage", unit: "%"),
                factorType: NotificationFactorType.Higher,
                factorValue: 95,
                secondsThreshold: 5,
                suspended: false
            ));
            saveNotifications();
            broadcastNotificationsToMobile();
        }

        public async Task checkNotifications(computerData data)
        {
            if (notifications.Count == 0) return;

            var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(data);
            var dictionaryData = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(serializedData);

            foreach (var notification in notifications)
            {
                if (notification.suspended) continue;

                double? currentValue = null;
                string? id = null;

                ///each hardware has their own structure, so we have to get [currentValue] and [id] for each hardware in different ways.
                if (notification.key == NotificationKey.Gpu)
                {
                    id = $"gpuData.{notification.childKey.keyName}";
                    var primaryGpu = await ChartsDataManager.getPrimaryGpu(data);
                    var serializedGpu = Newtonsoft.Json.JsonConvert.SerializeObject(primaryGpu);
                    var dictionaryGpu = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(serializedGpu);
                    currentValue = Convert.ToDouble(dictionaryGpu[notification.childKey.keyName]);
                }
                else if (notification.key == NotificationKey.Cpu)
                {
                    id = $"cpuData.{notification.childKey.keyName}";
                    currentValue = (double?)((Newtonsoft.Json.Linq.JObject)(dictionaryData["cpuData"]))[notification.childKey.keyName];
                }
                else if (notification.key == NotificationKey.Ram)
                {
                    id = $"ramData.{notification.childKey.keyName}";
                    currentValue = (double?)((Newtonsoft.Json.Linq.JObject)(dictionaryData["ramData"]))[notification.childKey.keyName];

                }
                else if (notification.key == NotificationKey.Storage)
                {
                    id = $"storageData.{notification.childKey.keyName}";
                    //this could be wrong
                    currentValue = ((List<dynamic>)dictionaryData["storagesData"])
                        .Find(element => element["diskNumber"] == Convert.ToInt32(notification.childKey.keyName)).FirstOrDefault()["temperature"];

                }
                else if (notification.key == NotificationKey.Network)
                {
                    id = $"networkData.{notification.childKey.keyName}";
                    var keyName = notification.childKey.keyName;
                    if (keyName == "totalUpload")
                    {
                        var primaryInterface = data.networkInterfaces.Where(network => network.isPrimary).FirstOrDefault();
                        if (primaryInterface != null) currentValue = bytesToGB(primaryInterface.bytesSent);
                        else currentValue = 0;
                    }
                    else if (keyName == "totalDownload")
                    {
                        var primaryInterface = data.networkInterfaces.Where(network => network.isPrimary).FirstOrDefault();
                        if (primaryInterface != null) currentValue = bytesToGB(primaryInterface.bytesReceived);
                        else currentValue = 0;
                    }
                    else if (keyName == "downloadSpeed")
                    {
                        currentValue = bytesToMB(data.primaryNetworkSpeed.download);
                    }
                    else if (keyName == "uploadSpeed")
                    {
                        currentValue = bytesToMB(data.primaryNetworkSpeed.upload);
                    }
                }

                if (currentValue == null || id == null)
                {
                    throw new Exception("faled to find notification id or value");
                }

                var notficationWithTimeStamp = notificationTimestamps.Where(notification => notification.id == id).FirstOrDefault();
                if (notficationWithTimeStamp == null)
                {
                    var notif = new NotificationWithTimestamp(id, notification, DateTime.Now, false);
                    notificationTimestamps.Add(notif);
                    continue;
                }

                ///if [isDataAboveValue] is true, that means we theoretically should send the notification
                bool isDataAboveValue = false;

                ///determining [isDataAboveValue]
                if (notification.factorType == NotificationFactorType.Higher)
                {
                    if (currentValue >= notification.factorValue) isDataAboveValue = true;
                }
                else
                {
                    if (currentValue <= notification.factorValue) isDataAboveValue = true;
                }

                if (isDataAboveValue)
                {
                    var elpased = notficationWithTimeStamp.GetElapsedTime();
                    if (elpased > notification.secondsThreshold && notficationWithTimeStamp.flipflop == false)
                    {
                        ApiManager.SendAlertToMobile(notification, currentValue ?? 0.0);
                        notificationTimestamps[notificationTimestamps.IndexOf(notficationWithTimeStamp)].flipflop = true;
                    }
                }
                else
                {
                    notificationTimestamps[notificationTimestamps.IndexOf(notficationWithTimeStamp)].flipflop = false;
                    notificationTimestamps[notificationTimestamps.IndexOf(notficationWithTimeStamp)].lastCheck = DateTime.Now;
                }
            }
        }

        private async Task saveNotifications()
        {
            var data = Newtonsoft.Json.JsonConvert.SerializeObject(notifications);
            GlobalClass.Instance.saveTextToDocumentFolder("notifications", data);
        }

        public async Task addNewNotification(NotificationData notification)
        {
            notifications.Add(notification);
        }

        public async Task newNotification(Dictionary<string, object> notificationData)
        {
            var notification = NotificationData.FromDictionary(notificationData);
            notifications.Add(notification);
            await broadcastNotificationsToMobile();
            await saveNotifications();
        }

        public async Task editNotification(Dictionary<string, object> notificationData)
        {
            var type = notificationData["type"].ToString();
            var notification = NotificationData.FromDictionary(Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(notificationData["notification"].ToString()));
            var foundNotification = notifications.FirstOrDefault(n => n.getKey() == notification.getKey());

            if (foundNotification != null)
            {
                if (type == "delete")
                {
                    notifications.Remove(foundNotification);
                }
                else if (type == "suspend")
                {

                    foundNotification.suspended = true;
                }
                else if (type == "unsuspend")
                {

                    foundNotification.suspended = false;
                }

                await broadcastNotificationsToMobile();
                await saveNotifications();
            }
        }

        public async Task broadcastNotificationsToMobile()
        {
            while (true)
            {
                if (FrontendGlobalClass.Instance.webrtc.isConnected())
                {
                    var data = Newtonsoft.Json.JsonConvert.SerializeObject(notifications);
                    //for some reason, without this delay the mobile app won't receive the notifications.
                    await Task.Delay(2000);
                    FrontendGlobalClass.Instance.webrtc.sendMessage("notifications", data);
                    break;
                }

                await Task.Delay(2000);
            }
        }

        private double bytesToGB(long bytes)
        {
            const long gigabyte = 1024 * 1024 * 1024;
            return bytes / gigabyte;
        }

        private double bytesToMB(long bytes)
        {
            const long gigabyte = 1024 * 1024;
            return bytes / gigabyte;
        }
    }
}
