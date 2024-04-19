using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;

namespace ZalConsole.HelperFunctions
{
    public class FilesGetter
    {
        ///used to send file to mobile, this can be used to stop sending the file.
        private readonly CancellationTokenSource cts;

        private readonly int chunkSize = 153600;
        // SocketIOClient.SocketIO client;
        //var client;
        // public FilesGetter(SocketIOClient.SocketIO client) {
        //     this.client = client;
        //     setupListeners();
        // }
        // private void setupListeners()
        // {
        //     client.On("get_directory", async response =>
        //     {
        //         var path = response.GetValue<string>();
        //         if (path == "")
        //         {
        //             var drives = getDrives();
        //             sendData("directory", drives);
        //             return;
        //         }
        //         List<FileData> folders=  [];
        //         try
        //         {
        //              folders = getDirectoryFolders(path);
        //         }
        //         catch(UnauthorizedAccessException) {
        //             await client.EmitAsync("information_text", "Access to path is denied.");
        //             return;
        //         } 
        //         var files = getDirectoryFiles(path);
        //         Dictionary<string, dynamic> data = new Dictionary<string, dynamic>();
        //         var allFiles = folders.Concat(files).ToList();
        //         sendData("directory", allFiles);
        //
        //
        //
        //     });
        //
        //     client.On("get_file", async response =>
        //     {
        //     var path = response.GetValue<string>();
        //     cts = new CancellationTokenSource();
        //
        //         List<long> sentChunks = [];
        //
        //         using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
        //         {
        //             byte[] buffer = new byte[chunkSize];
        //             int bytesRead;
        //             long byteOffset = 0;
        //
        //             while ((bytesRead = fs.Read(buffer, 0, buffer.Length)) > 0)
        //             {
        //                 // Convert the chunk to base64 or any other encoding as needed
        //                 string base64Chunk = Convert.ToBase64String(buffer, 0, bytesRead);
        //                 // Send the chunk with byte offset to Flutter using the sendData function
        //                 sendData("file", new { ByteOffset = byteOffset, ChunkData = base64Chunk });
        //                 sentChunks.Add(byteOffset);
        //                 // Update the byte offset for the next chunk
        //                 byteOffset += bytesRead;
        //                 // Simulate some delay to avoid overwhelming the network
        //                 await Task.Delay(150);
        //                
        //             }
        //
        //         }
        //         await Task.Delay(2000);
        //         sendData("file_complete", new { chunkSize = chunkSize, sentChunks = sentChunks });
        //
        //     });
        //     client.On("get_file_missing_chunks", async response =>
        //     {
        //         var data = response.GetValue<string>();
        //         var parsedData = JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(data);
        //         var path = parsedData["path"];
        //         foreach(var chunk in parsedData["chunks"])
        //         {
        //             using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
        //             {
        //                 byte[] buffer = new byte[chunkSize];
        //                 var bytesRead = fs.Read(buffer, 0, buffer.Length);
        //                 string base64Chunk = Convert.ToBase64String(buffer, 0, bytesRead);
        //                 sendData("file", new { ByteOffset = chunk, ChunkData = base64Chunk });
        //                 await Task.Delay(150);
        //                 
        //             }
        //         }
        //         await Task.Delay(150);
        //         sendData("file_complete", new { chunkSize = chunkSize, sentChunks = parsedData["chunks"] });
        //
        //
        //
        //     });
        //     client.On("run_file", async response =>
        //     {
        //         var data = response.GetValue<string>();
        //         try
        //         {
        //             System.Diagnostics.Process.Start(data);
        //             await client.EmitAsync("information_text", "file ran!");
        //
        //         }catch (Exception ex)
        //         {
        //             await client.EmitAsync("information_text", $"error running file: {ex.Message}");
        //         }
        //
        //
        //     });
        //     client.On("move_file", async response =>
        //     {
        //         var data = response.GetValue<string>();
        //         var parsedData = JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(data);
        //         try
        //         {
        //             System.IO.File.Move(parsedData["oldPath"], parsedData["newPath"]);
        //             await client.EmitAsync("information_text", $"done!");
        //         }
        //         catch (Exception ex)
        //         {
        //             await client.EmitAsync("information_text", $"error performing action: {ex.Message}");
        //         }
        //     });
        //     client.On("copy_file", async response =>
        //     {
        //         var data = response.GetValue<string>();
        //         var parsedData = JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(data);
        //         try
        //         {
        //             System.IO.File.Copy(parsedData["oldPath"], parsedData["newPath"]);
        //             await client.EmitAsync("information_text", $"done!");
        //         }
        //         catch (Exception ex)
        //         {
        //             await client.EmitAsync("information_text", $"error performing action: {ex.Message}");
        //         }
        //     });
        //     client.On("delete_file", async response =>
        //     {
        //         var data = response.GetValue<string>();
        //         try
        //         {
        //             System.IO.File.Delete(data);
        //             await client.EmitAsync("information_text", $"done!");
        //         }
        //         catch (Exception ex)
        //         {
        //             await client.EmitAsync("information_text", $"error performing action: {ex.Message}");
        //         }
        //         
        //     });
        // }
        //void ProcessChunk(byte[] chunk, int bytesRead)
        //{
        //    Dictionary<String,dynamic> data = new Dictionary<String,dynamic>();
        //    data["chunk"] = Convert.ToBase64String(chunk);
        //    data["bytesRead"]= bytesRead;
        //    sendData("file", data);
        //}
        //  public  void ProcessReceivedChunk(byte[] chunk, long byteLocation, long remainingBytes)
        //{
        //    Dictionary<String,dynamic> data= new Dictionary<String,dynamic>();
        //    data["chunk"] = chunk;
        //    data["byteLocation"]=byteLocation;
        //    data["remainingBytes"]=remainingBytes;
        //
        //    sendData("file",data);
        //}
        private List<FileData> getDirectoryFiles(string path)
        {
            var result = new List<FileData>();
            DirectoryInfo info = new DirectoryInfo(path);
            if (info.Exists)
            {

                var files = info.GetFiles();
                foreach (var file in files)
                {
                    if (file.Attributes.HasFlag(FileAttributes.Hidden))
                    {
                        continue;
                    }
                    FileData filed = new FileData();
                    filed.name = file.Name;
                    filed.extension = file.Extension;
                    filed.directory = file.DirectoryName;
                    filed.fileType = "file";
                    filed.size = file.Length;
                    filed.dateModified = ConvertToUnixTimestamp(file.LastWriteTime);
                    filed.dateCreated = ConvertToUnixTimestamp(file.CreationTime);
                    result.Add(filed);

                }
            }
            return result;
        }
        private List<FileData> getDirectoryFolders(string path)
        {
            var result = new List<FileData>();
            DirectoryInfo info = new DirectoryInfo(path);
            if (info.Exists)
            {

                var directories = info.GetDirectories();
                foreach (var directory in directories)
                {
                    if (directory.Attributes.HasFlag(FileAttributes.Hidden))
                    {
                        continue;
                    }
                    FileData folder = new FileData();
                    folder.directory = path;
                    folder.name = directory.Name;
                    folder.fileType = "folder";
                    folder.dateCreated = ConvertToUnixTimestamp(directory.CreationTime);
                    folder.dateModified = ConvertToUnixTimestamp(directory.LastWriteTime);
                    result.Add(folder);

                }
            }
            return result;
        }
        public static long ConvertToUnixTimestamp(DateTime date)
        {
            DateTime origin = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            TimeSpan diff = date.ToUniversalTime() - origin;
            return ((long)diff.TotalMilliseconds);
        }
        private List<FileData> getDrives()
        {
            DriveInfo[] drives = DriveInfo.GetDrives();
            List<FileData> result = new List<FileData>();
            foreach (var drive in drives)
            {
                FileData data = new FileData();
                data.label = drive.VolumeLabel;
                data.name = drive.Name;
                data.fileType = "folder";
                data.size = drive.TotalSize - drive.AvailableFreeSpace;
                result.Add(data);

            }
            return result;
        }

        // private async void sendData(string key,object data)
        // {
        //     var serializedData = Newtonsoft.Json.JsonConvert.SerializeObject(data);
        //     await client.EmitAsync(key, serializedData);
        // }
    }
}
