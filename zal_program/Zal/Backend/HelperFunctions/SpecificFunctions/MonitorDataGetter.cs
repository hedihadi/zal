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
            Screen[] screens = Screen.AllScreens;
            foreach (var screen in screens)
            {
                var data = new monitorData();
                data.name = screen.DeviceName;
                data.height = (uint)screen.Bounds.Height;
                data.width = (uint)screen.Bounds.Width;
                data.isPrimary = screen.Primary;
                data.bitsPerPixel = (uint)screen.BitsPerPixel;
                result.Add(data);
            }
            return result;
        }
    }
}
