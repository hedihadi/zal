using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Zal.Constants.Models;
using Zal.HelperFunctions.SpecificFunctions;

namespace Zal.HelperFunctions
{
    public class FpsDataGetter
    {
        private Process? presentmonProcess;
        private System.Threading.Tasks.Task fpsTask;
        private bool isDisposed = false;
        public event EventHandler<dynamic> sendFpsData;
        private List<double> fpsDatas = [];
        Stopwatch stopwatch = new Stopwatch();
        public FpsDataGetter()
        {
            stopwatch.Start();
            //run presentmon and refresh every 30 secs to avoid memory leak.
            //presentmonTimer = new Timer(_ =>
            //  {
            // Call your method directly inside the timer
            //      startPresentmon();
            //  }, null, 0, 30000);

            //send fpsdata to mobile every n seconds

        }

        public  double calculatePercentile(IEnumerable<double> seq, double percentile)
        {
            var elements = seq.ToArray();
            Array.Sort(elements);
            double realIndex = percentile * (elements.Length - 1);
            int index = (int)realIndex;
            double frac = realIndex - index;
            if (index + 1 < elements.Length)
                return elements[index] * (1 - frac) + elements[index + 1] * frac;
            else
                return elements[index];
        }
        public void disposeIt()
        {
            isDisposed = true;
            stopPresentmon();
        }
        private void stopPresentmon()
        {

            foreach (var process in Process.GetProcessesByName("presentmon"))
            {
                process.Kill();
                process.WaitForExit();
                process.Dispose();

            }
            if (presentmonProcess != null)
            {
                try { presentmonProcess.Kill(); } catch { }
                presentmonProcess.Dispose();
                presentmonProcess = null;
            }

        }
        public async void startPresentmon(int processId)
        {
            
            //startFpsTimer();
            //kill any presentmon process that might be running

            string path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "presentmon.exe");
            try
            {
                File.WriteAllBytes(path, Resources.presentmon);
            }
            catch (Exception ex)
            {
                Logger.LogError($"error moving presentmon to temp folder", ex);
            }

            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = path,
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = $"-output_stdout -stop_existing_session -process_id {processId} -terminate_on_proc_exit",
            };
            presentmonProcess = new Process { StartInfo = startInfo };
            try
            {

                presentmonProcess.Start();
            }
            catch (Exception ex)
            {
                Logger.LogError($"error running presentmon", ex);
            }
            Task.Run(async () => { await parseIncomingPresentmonData(); });
        }
        private static String getTimestamp()
        {

            return (new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds()).ToString();
        }
        //chosenProcessName is the process that was used during the creation of this void, if the currentProcessName changes, this void will stop itself.
        private async Task parseIncomingPresentmonData()
        {
            StreamReader reader = presentmonProcess.StandardOutput;

            while (!reader.EndOfStream)
            {


                if (isDisposed) break;
                Thread.Sleep(30);
                string line = reader.ReadLine();
                var msBetweenPresents = "";
                try
                {
                    msBetweenPresents = line.Split(',')[9];
                }
                catch
                {
                    continue;
                }

                uint? processId = null;
                String? processName = line.Split(',')[0];
                try
                {
                    processId = uint.Parse(line.Split(',')[1]);
                }
                catch
                {

                }
                if (processName == "<error>") continue;

                if (processId != null)
                {
                    var time = getTimestamp();
                    if (msBetweenPresents.Any(char.IsDigit))
                    {
                        //fpsData fpsData = new fpsData();
                        //fpsData.processId = processId;
                        var doubledMsBetweenPresents = double.Parse(msBetweenPresents);
                        //fpsData.processName = processName;
                        fpsDatas.Add((1000 / doubledMsBetweenPresents));


                        if(fpsDatas.Count > 10)
                        {
                            try
                            {
                                sendFpsData.Invoke(null, fpsDatas);
                            }
                            catch
                            {

                            }
                            fpsDatas.Clear();
                        }
                        continue;
                        if (stopwatch.ElapsedMilliseconds >199)
                        {
                          
                            try
                            {
                                System.Diagnostics.Debug.WriteLine($"p: {processId} - {processName}");
                                List<double> copyOfFpsDatas = fpsDatas.ToList();
                                var percentile01 = calculatePercentile(copyOfFpsDatas, 0.01);
                                var percentile001 = calculatePercentile(copyOfFpsDatas, 0.001);
                                var averageFps = copyOfFpsDatas.Average();
                                var dataToSend = new Dictionary<String, dynamic>();
                                dataToSend["percentile01"] = percentile01;
                                dataToSend["percentile001"] = percentile001;
                                dataToSend["averageFps"] = averageFps;
                                dataToSend["data"] = copyOfFpsDatas;
                                sendFpsData.Invoke(null, dataToSend);
                                if(fpsDatas.Count > 500)
                                {
                                    fpsDatas.RemoveAt(0);
                                } 
                                stopwatch.Restart();
                            }
                            catch
                            {

                            }
                           
                        }


                    }
                }
            }

        }
    }
}
