using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Pipes;
using System.Net;
using System.Threading.Tasks;
using System.Windows.Forms;
using Zal.Constants.Models;
using Zal.MajorFunctions;
using Zal.Pages;

namespace Zal
{
    public partial class MainForm : Form
    {
        // Constants for the message
        private const int WM_SYSCOMMAND = 0x0112;
        private const int SC_MINIMIZE = 0xf020;
        private Task pipeTask;
        private List<gpuData> gpuDatas = [];
        private NotifyIcon ni;
        private const string PipeName = "ZalAppPipe";
        private bool launchedByStartup;
        public MainForm(bool launchedByStartup)
        {

            this.launchedByStartup = launchedByStartup;
            InitializeComponent();
            Logger.ResetLog();
            pipeTask = StartPipeServer();
        }

        private Task StartPipeServer()
        {
            return Task.Run(() =>
             {
                 while (true)
                 {
                     using (var pipeServer = new NamedPipeServerStream(PipeName, PipeDirection.In))
                     {
                         try
                         {
                             pipeServer.WaitForConnection(); // Wait for a client to connect
                             using (var reader = new StreamReader(pipeServer))
                             {
                                 var command = reader.ReadLine();
                                 if (command == "SHOW")
                                 {
                                     Invoke(new Action(() =>
                                     {
                                         this.Show();
                                         this.WindowState = FormWindowState.Normal;
                                         this.Activate();
                                     }));
                                 }
                             }
                         }
                         catch (IOException)
                         {
                             // Handle pipe disconnection or errors
                         }
                     }
                     // PipeServer disposed and loop continues to create a new NamedPipeServerStream instance
                 }
             });
        }
        private void setupTrayMenu()
        {
            ni = new NotifyIcon();
            ni.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Process.GetCurrentProcess().MainModule.FileName);
            ni.Visible = true;
            var trayMenu = new ContextMenuStrip();
            trayMenu.Click +=
                delegate (object sender, EventArgs args)
                {
                    Show();
                    WindowState = FormWindowState.Normal;
                };
            // Add items to the context menu
            trayMenu.Items.Add("Open", null, (sender, e) => Show());
            trayMenu.Items.Add("Exit", null, (sender, e) => System.Windows.Forms.Application.Exit());
            ni.ContextMenuStrip = trayMenu;
            ni.DoubleClick +=
                delegate (object sender, EventArgs args)
                {
                    Show();
                    WindowState = FormWindowState.Normal;
                };

            if ((string?)LocalDatabase.Instance.readKey("startMinimized") == "1")
            {
                if (launchedByStartup)
                { this.Hide(); }
            }
        }
        private async void MainForm_Load(object sender, EventArgs e)
        {


            await FrontendGlobalClass.Initialize(socketConnectionStateChanged: (sender, state) =>
             {
                 this.Invoke(new Action(() =>
                 {
                     mobileConnectionText.Text = state == Functions.Models.SocketConnectionState.Connected ? "Mobile connected" : "Mobile not connected";
                     mobileConnectionText.ForeColor = !(state == Functions.Models.SocketConnectionState.Connected) ? Color.FromKnownColor(KnownColor.IndianRed) : Color.FromKnownColor(KnownColor.ForestGreen);
                 }));
             }, computerDataReceived: (sender, data) =>
             {
                 this.Invoke(new Action(() =>
                 {
                     gpuDatas = data.gpuData;

                 }));
             });
            setupTrayMenu();
            setupRunOnStartup();
            checkForUpdates();
        }

        private void connectionSettingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var form2 = new ConnectionSettingsForm();
            form2.Show();
        }

        private void configurationsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var form2 = new ConfigurationsForm(setupRunOnStartup, gpuDatas);
            form2.Show();
        }
        private async Task checkForUpdates()
        {
            var latestVersion = new WebClient().DownloadString("https://zalapp.com/program-version");
            var currentVersion = System.Windows.Forms.Application.ProductVersion;
            if (latestVersion != currentVersion)
            {
                var dialog = System.Windows.Forms.MessageBox.Show($"New update is available! do you want to update?\ncurrent version: {currentVersion}\nlatest version:{latestVersion}", "Zal", MessageBoxButtons.YesNo);
                if (dialog == DialogResult.Yes)
                {
                    using (var webClient = new WebClient())
                    {
                        try
                        {
                            var fileName = Path.Combine(Path.GetTempPath(), "zal.msi");
                            webClient.DownloadFile("https://zalapp.com/zal.msi", fileName);
                            Console.WriteLine("File downloaded successfully.");

                            var p = new Process();
                            var pi = new ProcessStartInfo {
                                UseShellExecute = true,
                                FileName = fileName,
                            };
                            p.StartInfo = pi;
                            p.Start();
                        }
                        catch (Exception ex)
                        {
                            System.Windows.Forms.MessageBox.Show("An error occurred updating Zal: " + ex.Message);
                        }
                    }
                }
            }
        }
        private async Task setupRunOnStartup()
        {
            var runOnStartup = (string?)LocalDatabase.Instance.readKey("runOnStartup") == "1";
            //replace false with saved settings
            var rk = Registry.CurrentUser.OpenSubKey
                ("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true);
            var executablePath = $"\"{Process.GetCurrentProcess().MainModule.FileName}\" --startup";
            if (runOnStartup)
                rk.SetValue("Zal", executablePath);
            else
                rk.DeleteValue("Zal", false);
        }

        private void viewLogToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Process.Start("notepad.exe", Logger.GetLogFilePath());

        }

        private async void copyProcessedBackendDataToolStripMenuItem_ClickAsync(object sender, EventArgs e)
        {
            var data = await FrontendGlobalClass.Instance.dataManager.getBackendData();
            System.Windows.Forms.Clipboard.SetText(Newtonsoft.Json.JsonConvert.SerializeObject(data));
        }

        private void copyRawBackendDataToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var data = FrontendGlobalClass.Instance.backend.getEntireComputerData();
            System.Windows.Forms.Clipboard.SetText(Newtonsoft.Json.JsonConvert.SerializeObject(data));

        }



        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void backgroundWorker1_DoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
        {

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            var pname = Process.GetProcessesByName("server");
            serverConnectionText.Text = pname.Length != 0 ? "Server running" : "Server not running";
            serverConnectionText.ForeColor = (pname.Length == 0) ? Color.FromKnownColor(KnownColor.IndianRed) : Color.FromKnownColor(KnownColor.ForestGreen);

            timer1.Interval = pname.Length != 0 ? 100 : 1000;


        }
        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);


            if (m.Msg == WM_SYSCOMMAND)
            {

                if (m.WParam.ToInt32() == SC_MINIMIZE)
                {
                    this.Hide();
                    m.Result = IntPtr.Zero;
                    return;
                }
            }
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            ni.Visible = false; // Hide tray icon
        }

        private void restartServerToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FrontendGlobalClass.Instance.localSocket.restartSocketio();
        }
    }

}
