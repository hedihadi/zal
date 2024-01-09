using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Zal.Constants.Models
{
    public class networkSpeed
    {
        public long download { get; set; }
        public long upload { get; set; }
        public networkSpeed(long download, long upload)
        {
            this.download = download;   
            this.upload = upload;
        }

        
    }
}
