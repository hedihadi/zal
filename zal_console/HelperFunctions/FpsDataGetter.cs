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
        SocketIOClient.SocketIO client;
        private Process? presentmonProcess;
        //private IList<int>? currentFocusedProcessId;
        private System.Threading.Tasks.Task fpsTask;
        private bool isDisposed = false;
        public event EventHandler<fpsData> fpsDataAdded;
        private Timer presentmonTimer;
        public FpsDataGetter(SocketIOClient.SocketIO client)
        {
        this.client=client;
            //run presentmon and refresh every 30 secs to avoid memory leak.
            presentmonTimer = new Timer(_ =>
            {
                // Call your method directly inside the timer
                startPresentmon();
            }, null, 0, 30000);
        }
        public void startPresentmon()
        {
            //kill any task_manager process that might be running
            foreach (var process in Process.GetProcessesByName("presentmon"))
            {
                process.Kill();
                process.WaitForExit();
                process.Dispose();
                
            }
            if (presentmonProcess != null )
            {
                try { presentmonProcess.Kill(); }   catch { }
                presentmonProcess.Dispose();
                presentmonProcess = null;
            }
            string path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "presentmon.exe");
            try
            {
                File.WriteAllBytes(path, Resources.presentmon);
            }
            catch (Exception ex)
            {
                Logger.LogError($"error writing presentmon",ex);
            }

            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = path,
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = $"-output_stdout -stop_existing_session",
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
            parseIncomingPresentmonData();
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
                //System.Diagnostics.Debug.WriteLine($"p: {processId} - {processName}");
                if (processId != null)
                {
                    var time = getTimestamp();
                    if (msBetweenPresents.Any(char.IsDigit))
                    {
                        fpsData fpsData = new fpsData();
                        fpsData.processId = processId;
                        fpsData.msBetweenPresents = double.Parse(msBetweenPresents);
                        fpsData.processName = processName;
                        try
                        {
                            client.EmitAsync("fps_data", fpsData);
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
