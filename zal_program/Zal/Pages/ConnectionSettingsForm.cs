using System;
using System.Linq;
using System.Windows.Forms;
using Zal.MajorFunctions;

namespace Zal.Pages
{
    public partial class ConnectionSettingsForm : Form
    {
        public ConnectionSettingsForm()
        {
            InitializeComponent();
        }

        private void ConnectionSettingsForm_Load(object sender, EventArgs e)
        {
            var pcName = (string?)LocalDatabase.Instance.readKey("pcName");
            if (pcName == null)
            {
                try
                {
                    pcName = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
                }
                catch
                {
                    pcName = "Default Computer";
                }
            }
            pcName = string.Concat(pcName.Where(char.IsLetterOrDigit));
            portTextBox.Text = LocalDatabase.Instance.readKey("port")?.ToString() ?? "4920";
            pcNameTextBox.Text = pcName;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            LocalDatabase.Instance.writeKey("port", portTextBox.Text.Length == 0 ? null : portTextBox.Text);
            LocalDatabase.Instance.writeKey("pcName", pcNameTextBox.Text.Length == 0 ? null : pcNameTextBox.Text);
            FrontendGlobalClass.Instance.localSocket.restartSocketio();
            this.Hide();
        }

        private void pcNameTextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.Handled = !char.IsLetter(e.KeyChar) && !char.IsControl(e.KeyChar)
     && !char.IsSeparator(e.KeyChar) && !char.IsDigit(e.KeyChar) && !char.IsControl(e.KeyChar);
        }

        private void portTextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.Handled = !char.IsControl(e.KeyChar)
         && !char.IsDigit(e.KeyChar) && !char.IsControl(e.KeyChar);
        }
    }
}
