using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Zal.Constants.Models
{
   public class cpuInfo
    {
        public string name { get; set; }
        public string socket { get; set; }
        public uint speed { get; set; }
        public uint busSpeed { get; set; }
        public ulong l2Cache { get; set; }
        public ulong l3Cache { get; set; }
        public uint cores { get; set; }
        public uint threads { get; set; }


    }
}
