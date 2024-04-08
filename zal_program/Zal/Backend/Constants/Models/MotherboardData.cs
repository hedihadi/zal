﻿using LibreHardwareMonitor.Hardware;

namespace Zal.Constants.Models
{
   public  class motherboardData
    {
        public string name { get;set;}
        public uint temperature { get;set;}
        public motherboardData(IHardware hardware)
        {
            this.name = hardware.Name;
                        foreach (ISensor sensor in hardware.Sensors)
                        {
                            if (sensor.SensorType == SensorType.Temperature)
                            {
                                this.temperature = (uint)sensor.Value;
                            }

    }
}
    }
}
