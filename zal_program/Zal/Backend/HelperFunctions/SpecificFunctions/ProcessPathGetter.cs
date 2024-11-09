using System;
using System.IO;

namespace Zal.HelperFunctions.SpecificFunctions
{
    internal class ProcesspathGetter
    {
        ///saves process path
        public static void save(string name, string processPath)
        {
            var directory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Zal", "programs_path");
            var folderPath = Directory.CreateDirectory(directory).FullName;
            using (var w = File.CreateText(Path.Combine(folderPath, name)))
            {
                w.Write(processPath);
            }
        }
        public static string? load(string name)
        {
            try
            {
                var directory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "Zal", "programs_path");
                var folderPath = Directory.CreateDirectory(directory).FullName;
                return File.ReadAllText(Path.Combine(folderPath, name));
            }
            catch { return null; }
        }
    }
}
