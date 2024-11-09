using System.Collections.Generic;
using System.Linq;

namespace Zal.Functions
{

    public static class DictionaryExtensions
    {
        public static TValue GetValueOrDefault<TKey, TValue>(this IDictionary<TKey, TValue> dictionary, TKey key, TValue defaultValue = default)
        {
            return dictionary.TryGetValue(key, out var value) ? value : defaultValue;
        }

    }
    public static class Utils
    {
        public static string getPcName()
        {
            var pcName = (string?)LocalDatabase.Instance.readKey("pcName");
            if (pcName == null)
            {
                try
                {
                    pcName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
                }
                catch
                {
                    pcName = "Default Computer";
                }
            }
            pcName = string.Concat(pcName.Where(char.IsLetterOrDigit));

            return pcName;
        }
    }
}
