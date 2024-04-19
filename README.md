# Zal

Zal uses Python, C#, Dart & Flutter under the hood.

## Folder Structure

| Folder       | Description                                        |
| ------------ | -------------------------------------------------- |
| python_scripts  | this folder contains some python scripts. the scripts are converted into executables and used as resources inside zal_program|
| zal_app      | Source code for Zal application for Android & IOS. |
| zal_program  | The front-end and back-end of Zal for Windows.     |

Zal uses C# to collect the data from your PC, but due to my lack of skillset with C#, I had to use Flutter & Dart for the Design.

## Sources

Zal uses a variety of other applications and combine them all into one Application. The list below are the Application that `zal_console` uses under the hood.
| Application | Description |
| ------ | ------ |
| [Librehardwaremonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) | Used to retrieve temperature, loads, network usage, etc... |
| [presentmon](https://github.com/GameTechDev/PresentMon) | Used to get FPS data from Game applications. |
| [Crystaldiskinfo](https://crystalmark.info/en/software/crystaldiskinfo/) | Used to get Storage data. |
