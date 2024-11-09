using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ZalConsole.HelperFunctions;

namespace Zal
{
    public class LocalDatabase
    {
        private readonly Dictionary<string, object> data = new Dictionary<string, object>();
        private static LocalDatabase instance;
        private readonly SemaphoreSlim _writeSemaphore = new SemaphoreSlim(1);

        private LocalDatabase(Dictionary<string, object> initData)
        {
            data = initData;
        }

        public static async Task Initialize()
        {
            var text = await GlobalClass.Instance.readTextFromDocumentFolder("database.json");
            if (text != null && text != "")
            {
                try
                {
                    var parsedData = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, object>>(text);
                    if (parsedData != null)
                    {
                        instance = new LocalDatabase(parsedData);
                        return;
                    }

                }
                catch (Exception ex)
                {
                    Logger.LogError("error reading database.json", ex);
                }
            }

            instance = new LocalDatabase(new Dictionary<string, object>());
        }

        public  static  LocalDatabase Instance
        {
            get
            {
                if (instance == null)
                {
                    throw new Exception("initialize first!!");
                }

                return instance;
            }
        }

        public object readKey(string key)
        {
            if (data.ContainsKey(key))
            {
                return data[key];
            }

            return null;
        }

        public async Task writeKey(string key, object text)
        {
            await _writeSemaphore.WaitAsync();
            try
            {
                data[key] = text;
                var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(data);
                WriteAsync(serializedData);
            }
            finally
            {
                _writeSemaphore.Release();
            }
        }

        private static void WriteAsync(string text)
        {
            GlobalClass.Instance.saveTextToDocumentFolder("database.json", text);

        }
    }
}
