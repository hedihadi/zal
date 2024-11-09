using System.Windows.Forms;
using Zal.Constants.Models;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class batteryDataGetter
    {
        public static batteryData getbatteryData()
        {
            PowerStatus p = SystemInformation.PowerStatus;

            int life = (int)(p.BatteryLifePercent * 100);

            var data = new batteryData();
            data.hasBattery = p.BatteryChargeStatus != BatteryChargeStatus.NoSystemBattery;
            data.life = (uint)life;
            data.isCharging = p.PowerLineStatus == PowerLineStatus.Online;
            data.lifeRemaining = (uint)p.BatteryLifeRemaining;

            return data;
        }
    }
}
