namespace Zal.Pages
{
    partial class ConfigurationsForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ConfigurationsForm));
            this.button1 = new System.Windows.Forms.Button();
            this.runOnStartupCheckbox = new System.Windows.Forms.CheckBox();
            this.startMinimizedCheckbox = new System.Windows.Forms.CheckBox();
            this.logFpsDataCheckbox = new System.Windows.Forms.CheckBox();
            this.label2 = new System.Windows.Forms.Label();
            this.gpusListbox = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(229, 112);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 9;
            this.button1.Text = "Save";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // runOnStartupCheckbox
            // 
            this.runOnStartupCheckbox.AutoSize = true;
            this.runOnStartupCheckbox.Location = new System.Drawing.Point(12, 12);
            this.runOnStartupCheckbox.Name = "runOnStartupCheckbox";
            this.runOnStartupCheckbox.Size = new System.Drawing.Size(98, 17);
            this.runOnStartupCheckbox.TabIndex = 10;
            this.runOnStartupCheckbox.Text = "Run on Startup";
            this.runOnStartupCheckbox.UseVisualStyleBackColor = true;
            // 
            // startMinimizedCheckbox
            // 
            this.startMinimizedCheckbox.AutoSize = true;
            this.startMinimizedCheckbox.Location = new System.Drawing.Point(12, 35);
            this.startMinimizedCheckbox.Name = "startMinimizedCheckbox";
            this.startMinimizedCheckbox.Size = new System.Drawing.Size(97, 17);
            this.startMinimizedCheckbox.TabIndex = 11;
            this.startMinimizedCheckbox.Text = "Start Minimized";
            this.startMinimizedCheckbox.UseVisualStyleBackColor = true;
            // 
            // logFpsDataCheckbox
            // 
            this.logFpsDataCheckbox.AutoSize = true;
            this.logFpsDataCheckbox.Location = new System.Drawing.Point(12, 58);
            this.logFpsDataCheckbox.Name = "logFpsDataCheckbox";
            this.logFpsDataCheckbox.Size = new System.Drawing.Size(91, 17);
            this.logFpsDataCheckbox.TabIndex = 12;
            this.logFpsDataCheckbox.Text = "Log FPS data";
            this.logFpsDataCheckbox.UseVisualStyleBackColor = true;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Arial", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(147, 15);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(125, 14);
            this.label2.TabIndex = 14;
            this.label2.Text = "Select your primary GPU";
            this.label2.Click += new System.EventHandler(this.label2_Click);
            // 
            // gpusListbox
            // 
            this.gpusListbox.FormattingEnabled = true;
            this.gpusListbox.Location = new System.Drawing.Point(146, 35);
            this.gpusListbox.Name = "gpusListbox";
            this.gpusListbox.Size = new System.Drawing.Size(158, 56);
            this.gpusListbox.TabIndex = 13;
            this.gpusListbox.SelectedIndexChanged += new System.EventHandler(this.gpusList_SelectedIndexChanged);
            // 
            // ConfigurationsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(316, 145);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.gpusListbox);
            this.Controls.Add(this.logFpsDataCheckbox);
            this.Controls.Add(this.startMinimizedCheckbox);
            this.Controls.Add(this.runOnStartupCheckbox);
            this.Controls.Add(this.button1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "ConfigurationsForm";
            this.Text = "Configurations";
            this.Load += new System.EventHandler(this.ConfigurationsForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.CheckBox runOnStartupCheckbox;
        private System.Windows.Forms.CheckBox startMinimizedCheckbox;
        private System.Windows.Forms.CheckBox logFpsDataCheckbox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox gpusListbox;
    }
}