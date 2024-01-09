using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Compression;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Zal.Constants.Models;
using System.Text.RegularExpressions;

namespace Zal.HelperFunctions.SpecificFunctions
{
     class CrystaldiskInfoGetter
    {
       static public List<crystalDiskData>? getcrystalDiskData()
        {
            if (IsAdminstratorChecker.IsAdministrator() == false)
            {
                //dont run if it's not running as adminstrator, because crystaldiskInfo don't work without it
                Logger.Log("didn't run crystaldiskInfo, program isn't running as adminstrator");
                return null;
            }
            string tempPath = Path.Combine(Path.GetTempPath(), "ZaldiskInfo");
            string zipResourceName = "diskInfo.zip"; // Make sure this matches the name in your resources
            string executableName = "diskInfo.exe";

            // Create the temporary directory if it doesn't exist
            Directory.CreateDirectory(tempPath);

            // Access the zip file from resources
            byte[] zipData = Resources.diskInfo as byte[];

            // Write the zip data to a temporary file
            string tempZipPath = Path.Combine(tempPath, zipResourceName);
            try
            {
                File.WriteAllBytes(tempZipPath, zipData);
            }
            catch (Exception ex)
            {
                Logger.LogError($"error writing crystaldiskInfo zipdata to file",ex);
            }

            // Extract the zip file to the temporary directory
            try
            {
                using (ZipArchive archive = ZipFile.OpenRead(tempZipPath))
                {
                    foreach (ZipArchiveEntry entry in archive.Entries)
                    {
                        string extractPath = Path.Combine(tempPath, entry.FullName);

                        // If the entry is a directory, create the directory
                        if (entry.FullName.EndsWith("/"))
                        {
                            Directory.CreateDirectory(extractPath);
                        }
                        else
                        {
                            entry.ExtractToFile(extractPath, true);
                        }
                    }
                }
            }
            catch(Exception ex) {
                Logger.LogError($"error extracting crystaldiskInfo zip", ex);
            }

            // Construct the path to the executable
            string executablePath = Path.Combine(tempPath, executableName);


            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = Path.Combine(tempPath, executableName), // Replace with the actual path
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = "/CopyExit diskInfo.txt",
            };
            var process = new Process { StartInfo = startInfo };

            try
            {
                process.Start();
            }
            catch( Exception ex ) {
                Logger.LogError($"error running crystaldiskInfo process", ex);
            }
            process.WaitForExit();
            string resultPath = Path.Combine(tempPath, "diskInfo.txt");
            var diskInfos = CrystaldiskInfoGetter.parseCrystaldiskInfoOutput(resultPath);
            process.Close();
            return diskInfos;
        }


        static private List<crystalDiskData> parseCrystaldiskInfoOutput(String filePath)
        {

            List<crystalDiskData> hardwareList = new List<crystalDiskData>();
            crystalDiskData currentHardware = null;

            foreach (string line in File.ReadLines(filePath))
            {
                if (line.StartsWith(" (0"))
                {
                    // New hardware entry found
                    if (currentHardware != null)
                    {
                        hardwareList.Add(currentHardware);


                    }

                    currentHardware = new crystalDiskData();
                    currentHardware.info = new Dictionary<string, dynamic>();
                }
                else if (currentHardware != null)
                {
                    if (line.Contains("Model :"))
                    {
                        currentHardware.info.Add("model", line.Split(':')[1].Trim());
                    }
                    if (line.Contains("Buffer Size :") && line.Contains("Unknown") == false)
                    {
                        string hoursString = Regex.Match(line.Split(':')[1].Trim(), @"\d+").Value;
                        if (!string.IsNullOrEmpty(hoursString))
                        {
                            currentHardware.info.Add("bufferSize", int.Parse(hoursString));
                        }
                    }
                    if (line.Contains("Transfer Mode :"))
                    {
                        string text = line.Split(':')[1];

                        currentHardware.info.Add("transferMode", text.Split('|'));

                    }
                    if (line.Contains("Queue Depth :"))
                    {
                        currentHardware.info.Add("queueDepth", line.Split(':')[1].Trim());
                    }
                    if (line.Contains("# Of Sectors :"))
                    {
                        currentHardware.info.Add("sectors", line.Split(':')[1].Trim());
                    }
                    if (line.Contains("Power On Hours :"))
                    {
                        string hoursString = Regex.Match(line.Split(':')[1].Trim(), @"\d+").Value;
                        if (!string.IsNullOrEmpty(hoursString))
                        {
                            currentHardware.info.Add("powerOnHours", int.Parse(hoursString));
                        }
                    }
                    if (line.Contains("Drive Letter :"))
                    {
                        List<string> driveLetters = ParseDriveLettersFromString(line);
                        if (driveLetters.Count!=0)
                        {
                            currentHardware.info.Add("driveLetters", driveLetters);
                        }
                    }
                    if (line.Contains("Power On Count :"))
                    {
                        string hoursString = Regex.Match(line.Split(':')[1].Trim(), @"\d+").Value;
                        if (!string.IsNullOrEmpty(hoursString))
                        {
                            currentHardware.info.Add("powerOnCount", int.Parse(hoursString));
                        }
                    }
                    if (line.Contains("Health Status :"))
                    {
                        string hoursString = Regex.Match(line.Split(':')[1].Trim(), @"\d+").Value;
                        if (!string.IsNullOrEmpty(hoursString))
                        {
                            currentHardware.info.Add("healthPercentage", int.Parse(hoursString));
                        }

                        Regex regex = new Regex("[a-zA-Z]+");
                        Match match = regex.Match(line.Split(':')[1].Trim());
                        if (match.Success)
                        {
                            currentHardware.info.Add("healthText", match.Value);
                        }
                    }
                    if (line.Contains("Features :"))
                    {
                        currentHardware.info.Add("features", line.Split(':')[1].Trim().Split(',').ToList());
                    }
                    ////////////////////
                    ///////////////////
                    else if ((line.Contains("ID Cur Wor Thr RawValues(6) Attribute Name")))
                    {
                        currentHardware.smartAttributes = new List<smartAttribute>();
                        continue; // Skip header line
                    }
                    else if (line.Contains("ID RawValues(6) Attribute Name"))
                    {
                        currentHardware.smartAttributes = new List<smartAttribute>();
                        currentHardware.isNvme = true;
                        continue; // Skip header line
                    }
                    else if (line == "" || line.Contains("--") || line.Contains("     +0") || line.Contains("        0") || line.Contains(": "))
                    {
                        continue;
                    }
                    else if (currentHardware.smartAttributes != null && currentHardware.isNvme==false)
                    {
                        string[] parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        var attributeName = string.Join(" ", parts, 5, parts.Length - 5);
                        if (attributeName.Contains("Temperature"))
                        {
                            continue;
                        }
                        long rawValue = 0;
                        try
                        {
                            rawValue = long.Parse(parts[4], System.Globalization.NumberStyles.HexNumber);
                        }
                        catch (Exception c)
                        {
                            Console.WriteLine(c.Message);
                        }
                        smartAttribute smartAttribute = new smartAttribute
                        {
                            id = parts[0],
                            currentValue = int.Parse(parts[1].Replace("_", "")),
                            worstValue = int.Parse(parts[2].Replace("_", "")),
                            threshold = int.Parse(parts[3].Replace("_", "")),
                            rawValue = rawValue,
                            attributeName = attributeName
                        };
                        currentHardware.smartAttributes.Add(smartAttribute);
                    }
                    else if (currentHardware.smartAttributes != null && currentHardware.isNvme == true)
                    {
                        string[] parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        var attributeName = string.Join(" ", parts, 2, parts.Length - 2);
                        if (attributeName.Contains("Temperature"))
                        {
                            continue;
                        }
                        long rawValue = 0;
                        try
                        {
                            rawValue = long.Parse(parts[1], System.Globalization.NumberStyles.HexNumber);
                        }
                        catch (Exception c)
                        {
                            Console.WriteLine(c.Message);
                        }
                        smartAttribute smartAttribute = new smartAttribute
                        {
                            id = parts[0],
                            rawValue = rawValue,
                            attributeName = attributeName
                        };
                        currentHardware.smartAttributes.Add(smartAttribute);
                    }
                }
            }

            // Add the last hardware entry if present
            if (currentHardware != null)
            {
                hardwareList.Add(currentHardware);
            }
            hardwareList = hardwareList.Where(x => x.info.ContainsKey("model")).ToList();

            // Now you have a list of hardware entries with all SMART attributes
            return hardwareList;
        }
        static List<string> ParseDriveLettersFromString(string input)
        {
            List<string> driveLetters = new List<string>();

            // Use a regular expression to match drive letters
            Regex regex = new Regex(@"[A-Za-z]:");
            MatchCollection matches = regex.Matches(input);

            foreach (Match match in matches)
            {
                // Extract the matched drive letter and add it to the list
                driveLetters.Add(match.Value.Trim().Replace(":",""));
            }

            return driveLetters;
        }
    }
}


