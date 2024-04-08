using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using ZalConsole.HelperFunctions;

namespace Zal.HelperFunctions
{
    public class FpsDataGetter
    {
        private Process? presentmonProcess;
        private readonly Task fpsTask;
        private bool isDisposed = false;
        public event EventHandler<dynamic> sendFpsData;
        private readonly List<double> fpsDatas = [];
        private readonly int processId;
        readonly Stopwatch stopwatch = new Stopwatch();
        bool shouldLog = false;

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

        public double calculatePercentile(IEnumerable<double> seq, double percentile)
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

        public void stopPresentmon()
        {
            Logger.Log("stopping presentmon");
            foreach (var process in Process.GetProcessesByName("presentmon"))
            {
                process.Kill();
                Logger.Log("presentmon killed");
            }
        }

        public async void startPresentmon(int processId, bool logFps)
        {
            shouldLog = logFps;
            //startFpsTimer();
            //kill any presentmon process that might be running
            var filePath = GlobalClass.Instance.getFilepathFromResources("presentmon.exe");
            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = filePath,
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

        private static string getTimestamp()
        {

            return (new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds()).ToString();
        }

        //chosenProcessName is the process that was used during the creation of this void, if the currentProcessName changes, this void will stop itself.
        private async Task parseIncomingPresentmonData()
        {
            StreamReader reader = presentmonProcess.StandardOutput;

            while (!reader.EndOfStream)
            {
                try
                {
                    if (isDisposed)
                    {
                        Logger.Log("presentmon disposed, stopping fps");
                        break;
                    }

                    //Thread.Sleep(30);
                    string line = reader.ReadLine();
                    if (shouldLog) Logger.Log($"fpsData:{line}");
                    var msBetweenPresents = "";
                    try
                    {
                        msBetweenPresents = line.Split(',')[9];
                    }
                    catch
                    {
                        Logger.Log("skipped line, msBetweenPresents failed");
                        continue;
                    }

                    uint? processId = null;
                    string? processName = line.Split(',')[0];
                    try
                    {
                        processId = uint.Parse(line.Split(',')[1]);
                    }
                    catch
                    {
                        Logger.Log("skipped line, processId failed");
                    }

                    if (processName == "<error>")
                    {
                        Logger.Log("skipped line, error line");
                        continue;
                    }

                    if (processId != null)
                    {
                        var time = getTimestamp();
                        if (msBetweenPresents.Any(char.IsDigit))
                        {
                            var doubledMsBetweenPresents = double.Parse(msBetweenPresents, System.Globalization.NumberStyles.AllowDecimalPoint, System.Globalization.NumberFormatInfo.InvariantInfo);
                            fpsDatas.Add((1000 / doubledMsBetweenPresents));

                            if (fpsDatas.Count > 10)
                            {
                                try
                                {
                                    sendFpsData.Invoke(null, fpsDatas);
                                }
                                catch (Exception exc)
                                {
                                    Logger.LogError("error sending fps data", exc);
                                }

                                fpsDatas.Clear();
                            }

                            continue;
                        }
                        else
                        {
                            Logger.Log("msBetweenPresents not digits");
                        }
                    }
                    else
                    {
                        Logger.Log("processId is null");
                    }
                }
                catch (Exception exc)
                {
                    Logger.LogError("error during fps", exc);
                }
            }
        }
    }
}
