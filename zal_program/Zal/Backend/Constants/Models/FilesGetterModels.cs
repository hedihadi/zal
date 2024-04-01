using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
public class FileData
{
    private string _label;
    public string label
    {
        get => _label;
        set => _label = value?.Replace("'", "").Replace("\"", "");
    }
    public string directory { get; set; }
    public long size { get; set; }
    public string name {  get; set; }
    public string fileType {  get; set; }
public long? dateCreated { get; set; }
    public long? dateModified { get; set; }

    public string extension { get; set; }
}
