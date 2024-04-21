using System.Collections.Generic;
using System.Windows.Forms;
using Zal.Constants.Models;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class monitorDataGetter
    {
        public static List<monitorData>? getmonitorData()
        {
            var result = new List<monitorData>();
            var screens = Screen.AllScreens;
            foreach (var screen in screens)
            {
                var data = new monitorData
                {
                    name = screen.DeviceName,
                    height = (uint)screen.Bounds.Height,
                    width = (uint)screen.Bounds.Width,
                    isPrimary = screen.Primary,
                    bitsPerPixel = (uint)screen.BitsPerPixel,
                };
                result.Add(data);
            }
            return result;
        }
    }
}
