using System.Windows.Forms;
using Zal.Constants.Models;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class batteryDataGetter
    {
        public static batteryData getbatteryData()
        {
            var p = SystemInformation.PowerStatus;

            var life = (int)(p.BatteryLifePercent * 100);

            var data = new batteryData
            {
                hasBattery = p.BatteryChargeStatus != BatteryChargeStatus.NoSystemBattery,
                life = (uint)life,
                isCharging = p.PowerLineStatus == PowerLineStatus.Online,
                lifeRemaining = (uint)p.BatteryLifeRemaining,
            };

            return data;
        }
    }
}
