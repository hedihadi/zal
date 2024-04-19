using System.Collections.Generic;

namespace Zal.Constants.Models
{
    public class crystalDiskData
    {
        public bool isNvme = false;
        public Dictionary<string, dynamic> info { get; set; }
        public List<smartAttribute> smartAttributes { get; set; }
    }

    public class smartAttribute
    {
        private string _attributeName;
        public string id { get; set; }
        public int? currentValue { get; set; }
        public int? worstValue { get; set; }
        public int? threshold { get; set; }
        public long? rawValue { get; set; }

        public string attributeName
        {
            get => _attributeName;
            set => _attributeName = value?.Replace("'", "").Replace("\"", "");
        }
    }
}
