using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Zal.Constants.Models
{
   public class monitorData
    {
        public string name { get; set; }
        public uint height { get; set; }
        public uint width { get; set; }
        public bool isPrimary { get; set; } 
        public uint bitsPerPixel { get; set; }
    }
}
