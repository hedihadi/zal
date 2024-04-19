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
