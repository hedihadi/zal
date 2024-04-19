using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Management;
using System.Runtime.InteropServices;

namespace Zal.HelperFunctions.SpecificFunctions
{
    public class FocusedWindowGetter
    {
        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        public IList<int>? getFocusedWindowProcessId()
        {
            var hwnd = GetForegroundWindow();

            // The foreground window can be NULL in certain circumstances,
            // such as when a window is losing activation.
            if (hwnd == IntPtr.Zero)
            {
                return null;
            }

            GetWindowThreadProcessId(hwnd, out var pid);
            var proc = Process.GetProcessById(((int)pid));

            return proc.GetChildProcesses().Select(process => process.Id).ToList();
        }
    }
}

public static class ProcessExtensions
{
    public static IList<Process> GetChildProcesses(this Process process)
    {
        var processes = new ManagementObjectSearcher(
                $"Select * From Win32_Process Where ParentProcessID={process.Id}")
            .Get()
            .Cast<ManagementObject>()
            .Select(mo =>
                Process.GetProcessById(Convert.ToInt32(mo["ProcessID"])))
            .ToList();
        processes.Add(process);
        Process[] processesByName = Process.GetProcessesByName(process.ProcessName);
        foreach (var processByName in processesByName)
        {
            processes.Add(processByName);
        }

        return processes;
    }
}
