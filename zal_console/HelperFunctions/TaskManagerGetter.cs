using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Zal.HelperFunctions.SpecificFunctions;

namespace Zal.HelperFunctions
{
     class TaskManagerGetter
    {

        private Process? taskmanagerProcess;
        public TaskManagerGetter()
        {
            keepTaskManagerRunning();
        }

        private void startTaskmanager()
        {
            //kill any task_manager process that might be running
            foreach (var process in Process.GetProcessesByName("task_manager"))
            {
                process.Kill();
            }

            if (IsAdminstratorChecker.IsAdministrator() == false)
            {
                //dont run because psutil uses too much CPU if it's not running as adminstrator
                Logger.Log("didn't run taskmanager, program isn't running as adminstrator");
                return;
            }
            string path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "task_manager.exe");
            try
            {
                File.WriteAllBytes(path, Resources.task_manager);
            }
            catch (Exception ex)
            {
                Logger.LogError("error writing taskmanager to file", ex);
                
            }

            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = path, // Replace with the actual path
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Arguments = "",
            };
            this.taskmanagerProcess = new Process { StartInfo = startInfo };

            try
            {
                this.taskmanagerProcess.Start();
            }
            catch(Exception ex) {
                Logger.LogError("error running taskmanager", ex);
            }
        }
        public Dictionary<string, dynamic>? getTaskmanagerData()
        {
            if(taskmanagerProcess==null || taskmanagerProcess.HasExited == true)
            {
                return null;
            }
            Dictionary<string, dynamic>? taskmanagerData=null;
            try
            {
                taskmanagerData = parseTaskmanagerDataFromFile();
            }
            catch (Exception ex)
            {
                Logger.LogError("error parsing taskmanager data from file", ex);
            }
            if(taskmanagerData == null)
            {
                return null;
            }
            return taskmanagerData;

        }
        private Dictionary<string, dynamic> parseTaskmanagerDataFromFile()
        {
            string path = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "zal_taskmanager_result.json");
            string contents = File.ReadAllText(path);
            Dictionary<string, dynamic> parsedData = JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(contents);
            return parsedData;
        }
        private async Task keepTaskManagerRunning()
        {
            this.startTaskmanager();
            while (true)
            {
                Process[] processes = Process.GetProcessesByName("task_manager");
                if (processes.Length == 0)
                {
                    if (taskmanagerProcess != null) {
                        taskmanagerProcess.Dispose();
                        taskmanagerProcess = null;
                        this.startTaskmanager();
                    }
                }
                ///wait for 5 seconds before checking again
                await Task.Delay(5000);
            }
        }
    }
}
