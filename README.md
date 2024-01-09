# Zal

Zal uses Python, C#, Dart & Flutter under the hood.

## Why 4 Folders? Well...

| Folder       | Description                                        |
| ------------ | -------------------------------------------------- |
| zal_app      | source code for Zal application for Android & IOS. |
| zal_program  | the front-end of Zal for Windows.                  |
| zal_console  | the back-end of Zal for Windows.                   |
| task_manager | used to get data about running processes.          |

Zal uses C# to collect the data from your PC, but due to my lack of skillset with C#, i had to use Flutter & Dart for the Design.
the build folder is inside `zal_program/assets/executables/zal-console/` and from there zal_program will run the C# application.

## Sources

Zal uses a variety of other applications and combine them all into one Application. the list below are the Application that `zal_console` uses under the hood.
| Application | Description |
| ------ | ------ |
| [Librehardwaremonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) | used to retrieve temperature, loads, network usage, etc... |
| [presentmon](https://github.com/GameTechDev/PresentMon) | used to get FPS data from Game applications. |
| [Crystaldiskinfo](https://crystalmark.info/en/software/crystaldiskinfo/) |used to get Storage data. |
