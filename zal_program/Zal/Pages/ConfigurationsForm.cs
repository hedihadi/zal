using System;
using System.Windows.Forms;
using Zal.MajorFunctions;

namespace Zal.Pages
{
    public partial class ConfigurationsForm : Form
    {
        private Func<System.Threading.Tasks.Task> setupRunOnStartup;
        private System.Collections.Generic.List<Constants.Models.gpuData> gpuData;
        public ConfigurationsForm(Func<System.Threading.Tasks.Task> setupRunOnStartup, System.Collections.Generic.List<Constants.Models.gpuData> gpuData)
        {
            this.gpuData = gpuData;
            this.setupRunOnStartup = setupRunOnStartup;
            InitializeComponent();
        }

        private void ConfigurationsForm_Load(object sender, EventArgs e)
        {
            runOnStartupCheckbox.Checked = (LocalDatabase.Instance.readKey("runOnStartup")?.ToString() ?? "1") == "1";
            startMinimizedCheckbox.Checked = (LocalDatabase.Instance.readKey("startMinimized")?.ToString() ?? "1") == "1";
            FrontendGlobalClass.Instance.shouldLogFpsData = logFpsDataCheckbox.Checked;

            if (gpusListbox.Items.Count == 0)
            {
                gpusListbox.Items.Clear();
                foreach (var gpu in gpuData)
                {

                    gpusListbox.Items.Add(gpu.name);
                    Logger.Log($"detected gpu:{gpu.name}");
                }

                //if primary gpu is not set, set it.
                if (gpuData.Count != 0)
                {
                    var primaryGpu = LocalDatabase.Instance.readKey("primaryGpu");


                    if (primaryGpu == null)
                    {
                        Logger.Log($"setting primary gpu to {gpuData[0].name}");
                        LocalDatabase.Instance.writeKey("primaryGpu", gpuData[0].name);
                        gpusListbox.SelectedItem = gpuData[0].name;
                    }
                    else
                    {
                        //check if the primary gpu exists inside this data, this is a useful check in case of the user changed their gpu
                        bool doesPrimaryGpuExist = false;
                        foreach (var gpu in gpuData)
                        {
                            if (gpu.name == primaryGpu.ToString())
                            {
                                doesPrimaryGpuExist = true;
                                Logger.Log($"detected primary gpu:{gpu.name}");
                                gpusListbox.SelectedItem = gpu.name;
                            }
                        }

                        if (doesPrimaryGpuExist == false)
                        {
                            Logger.Log($"primary gpu not found, setting this gpu as default:{gpuData[0].name}");
                            //reset primary gpu
                            LocalDatabase.Instance.writeKey("primaryGpu", gpuData[0].name);
                            gpusListbox.SelectedItem = gpuData[0].name;
                        }
                    }
                }
                // GpusList.SelectedItem = primaryGpu;
            }

        }

        private async void button1_Click(object sender, EventArgs e)
        {
            await LocalDatabase.Instance.writeKey("runOnStartup", runOnStartupCheckbox.Checked ? "1" : "0");
            await LocalDatabase.Instance.writeKey("startMinimized", startMinimizedCheckbox.Checked ? "1" : "0");
            FrontendGlobalClass.Instance.localSocket.restartSocketio();
            this.Hide();
        }

        private async void gpusList_SelectedIndexChanged(object sender, EventArgs e)
        {
            var selectedGpuName = gpusListbox.SelectedItem.ToString();
            await LocalDatabase.Instance.writeKey("primaryGpu", selectedGpuName.ToString());
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }
    }
}
