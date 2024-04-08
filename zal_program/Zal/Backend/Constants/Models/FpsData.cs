using System;

namespace Zal.Constants.Models
{
    public class fpsData
    {
        public string processName { get; set; }
        public uint? processId { get; set; }
        public double msBetweenPresents { get; set; } 
        public DateTime dateCreated { get; set; }
        public fpsData() {
            dateCreated = DateTime.Now;
        }
    }
}
