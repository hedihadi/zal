using System;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Threading;
using System.Windows.Forms;

namespace Zal
{
    internal static class Program
    {
        private static Mutex mutex;
        private const string PipeName = "ZalAppPipe";

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        private static void Main(string[] args)
        {
            bool createdNew;
            mutex = new Mutex(true, "ZalAppMutex", out createdNew); // Unique mutex name

            if (!createdNew)
            {
                // Another instance is already running, send signal to show form
                SendShowSignal();
                return; // Exit the new instance
            }
            var launchedByStartup = args.Contains("--startup");
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm(launchedByStartup));
        }
        private static void SendShowSignal()
        {
            try
            {
                using (var pipeClient = new NamedPipeClientStream(".", PipeName, PipeDirection.Out))
                {
                    pipeClient.Connect(1000); // Attempt to connect to the server
                    using (var writer = new StreamWriter(pipeClient))
                    {
                        writer.WriteLine("SHOW");
                    }
                }
            }
            catch (TimeoutException)
            {
                MessageBox.Show("Unable to connect to the running instance.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
