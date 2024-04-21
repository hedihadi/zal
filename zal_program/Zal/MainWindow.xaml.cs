using System.ComponentModel;
using System.Diagnostics;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Input;
using System.Windows.Navigation;
using Firebase.Auth;
using Firebase.Auth.UI;
using Application = System.Windows.Application;

namespace Zal
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {

            InitializeComponent();
            FirebaseUI.Instance.Client.AuthStateChanged += AuthStateChanged;

            setupTrayMenu();
            Logger.ResetLog();

        }

        private void AuthStateChanged(object sender, UserEventArgs e)
        {
            Application.Current.Dispatcher.Invoke(async () =>
            {
                if (e.User == null)
                {
                    Frame.Navigate(new LoginPage());
                }
                else if (e.User.IsAnonymous)
                {
                    Frame.Navigate(new LoginPage());
                }
                else if ((Frame.Content == null || Frame.Content.GetType() != typeof(AuthorizedPage)))
                {
                    Frame.Navigate(new AuthorizedPage());
                }
            });
        }

        private void setupTrayMenu()
        {
            var ni = new NotifyIcon();
            ni.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Process.GetCurrentProcess().MainModule.FileName);
            ni.Visible = true;
            var trayMenu = new ContextMenuStrip();

            // Add items to the context menu
            trayMenu.Items.Add("Open", null, (sender, e) => Show());
            trayMenu.Items.Add("Exit", null, (sender, e) => Application.Current.Shutdown());
            ni.ContextMenuStrip = trayMenu;
            ni.DoubleClick +=
                delegate
                {
                    Show();
                    WindowState = WindowState.Normal;
                };

            // if(Zal.Settings.Default.minimizeToTray)
            {
                //this.Hide();
            }
        }



        private void Frame_Navigated(object sender, NavigationEventArgs e)
        {

        }

        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            DragMove();
        }

        private void Window_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

            Application.Current.Shutdown();

        }
        private void Minimize_Click(object sender, RoutedEventArgs e)
        {
            Hide();

        }
        private void Window_Closing(object sender, CancelEventArgs e)
        {
            foreach (var process in Process.GetProcessesByName("task_manager"))
            {
                process.Kill();
            }
        }
    }
}
