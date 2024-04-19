using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Zal.Functions.Models
{

    public class NotificationWithTimestamp
    {
        public string id { get; set; }
        public NotificationData notification { get; set; }
        public DateTime lastCheck { get; set; }
        public bool flipflop { get; set; }

        public NotificationWithTimestamp(string id, NotificationData notification, DateTime lastCheck, bool flipflop)
        {
            this.id = id;
            this.notification = notification;
            this.lastCheck = lastCheck;
            this.flipflop = flipflop;
        }

        public int GetElapsedTime()
        {
            return (DateTime.Now - lastCheck).Seconds;
        }
    }

    public class NotificationKeyWithUnit
    {
        public string keyName { get; }
        public string unit { get; }
        public string? displayName { get; }

        public NotificationKeyWithUnit(string keyName, string unit, string? displayName = null)
        {
            this.keyName = keyName;
            this.unit = unit;
            this.displayName = displayName;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(this, obj))
            {
                return true;
            }

            return obj is NotificationKeyWithUnit other && other.keyName == keyName && other.unit == unit;
        }

        public override int GetHashCode()
        {
            return keyName.GetHashCode() ^ unit.GetHashCode();
        }

        public Dictionary<string, object> ToDictionary()
        {
            var result = new Dictionary<string, object>();
            result.Add("keyName", keyName);
            result.Add("unit", unit);

            if (displayName != null)
            {
                result.Add("displayName", displayName);
            }

            return result;
        }

        public static NotificationKeyWithUnit FromDictionary(JObject map)
        {
            return new NotificationKeyWithUnit(
                map["keyName"]?.ToString() ?? string.Empty,
                map["unit"]?.ToString() ?? string.Empty,
                map.ContainsKey("displayName") ? map["displayName"]?.ToString() : null);
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(ToDictionary());
        }


    }

    public enum NotificationKey
    {
        Gpu,
        Cpu,
        Ram,
        Storage,
        Network
    }

    public enum NotificationFactorType
    {
        Higher,
        Lower
    }

    public class NotificationData
    {
        public NotificationKey key { get; }
        public NotificationKeyWithUnit childKey { get; set; }
        public NotificationFactorType factorType { get; set; }
        public double factorValue { get; }
        public int secondsThreshold { get; }
        public bool suspended { get; set; }

        public NotificationData(NotificationKey key, NotificationKeyWithUnit childKey, NotificationFactorType factorType, double factorValue, int secondsThreshold, bool suspended)
        {
            this.key = key;
            this.childKey = childKey;
            this.factorType = factorType;
            this.factorValue = factorValue;
            this.secondsThreshold = secondsThreshold;
            this.suspended = suspended;
        }
        //returns a string that can be used to compare notificationdata to other notificationdata
        public string getKey()
        {
            return $"{key}.{factorType}.{factorType}.{childKey.keyName}";
        }

        public NotificationData CopyWith(
            NotificationKey? key = null,
            NotificationKeyWithUnit? childKey = null,
            NotificationFactorType? factorType = null,
            double? factorValue = null,
            int? secondsThreshold = null,
            bool? suspended = null)
        {
            return new NotificationData(
                key ?? this.key,
                childKey ?? this.childKey,
                factorType ?? this.factorType,
                factorValue ?? this.factorValue,
                secondsThreshold ?? this.secondsThreshold,
                suspended ?? this.suspended);
        }

        public Dictionary<string, object> ToDictionary()
        {
            var result = new Dictionary<string, object>();
            result.Add("key", key.ToString());
            result.Add("childKey", childKey.ToDictionary());
            result.Add("factorType", factorType.ToString());
            result.Add("factorValue", factorValue);
            result.Add("secondsThreshold", secondsThreshold);
            result.Add("suspended", suspended);

            return result;
        }

        public static NotificationData FromDictionary(Dictionary<string, object> map)
        {
            return new NotificationData(
                Enum.Parse<NotificationKey>(map["key"].ToString()),
                NotificationKeyWithUnit.FromDictionary((JObject)map["childKey"]),
                Enum.Parse<NotificationFactorType>(map["factorType"].ToString()),
                Convert.ToDouble(map["factorValue"]),
                Convert.ToInt32(map["secondsThreshold"]),
                Convert.ToBoolean(map["suspended"]));
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(ToDictionary());
        }

        public static NotificationData FromJson(string source)
        {
            return FromDictionary(JsonConvert.DeserializeObject<Dictionary<string, object>>(source));
        }
    }
}
