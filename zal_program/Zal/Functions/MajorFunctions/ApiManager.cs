using Firebase.Auth.UI;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Zal.Functions.Models;
namespace Zal.Functions.MajorFunctions
{
    internal class ApiManager
    {
        public static async Task SendAlertToMobile(NotificationData notification, double value)
        {
            var displayName = $"{notification.childKey.displayName ?? notification.key.ToString()} {ConvertCamelToSpaced(notification.childKey.keyName)}";
            var factorTypeText = notification.factorType == NotificationFactorType.Lower ? "fell below" : "reached";
            var body = $"{displayName} {factorTypeText} {FormatDouble(value)}{notification.childKey.unit}";

            await SendDataToDatabase("pc_message", new Dictionary<string, dynamic>
        {
            { "title", "ALERT!" },
            { "body", body }
        });
        }
        public static async Task<HttpResponseMessage> SendDataToDatabase(string route, Dictionary<string, dynamic> data = null)
        {
            // Assuming FirebaseAuth is a class with a static property 'Instance' and 'Instance.TokenProvider' is a property returning a token.
            var idToken = await FirebaseUI.Instance.Client.User.GetIdTokenAsync();

            var databaseUrl = "https://zalapp.com/api"; // Replace this with your database URL
            var url = $"{databaseUrl}/{route}";

            var json = data != null ? JsonConvert.SerializeObject(data) : "{}";

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", idToken);
                return await client.PostAsync(url, content);
            }
        }
        private static string FormatDouble(double number)
        {
            var formattedString = number.ToString((number == (int)number) ? "F0" : "F1");
            return formattedString.EndsWith(".0") ? formattedString.Split('.')[0] : formattedString;
        }

        private static string ConvertCamelToSpaced(string camelCase)
        {
            if (string.IsNullOrEmpty(camelCase))
                return camelCase;

            var spacedString = new StringBuilder();
            spacedString.Append(camelCase[0]);

            for (var i = 1; i < camelCase.Length; i++)
            {
                if (char.IsUpper(camelCase[i]))
                {
                    spacedString.Append(' ');
                    spacedString.Append(camelCase[i]);
                }
                else
                {
                    spacedString.Append(camelCase[i]);
                }
            }

            return spacedString.ToString();
        }
    }
}
