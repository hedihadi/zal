using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Zal.Constants.Models
{
   public class batteryData
    {
        public bool hasBattery { get; set; }
        public uint life { get; set; }
        public bool isCharging { get; set; }
        public uint lifeRemaining { get; set; } 


    }
}
