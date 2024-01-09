
import json
import os
import sys
import time
import base64
import psutil
from timeit import default_timer as timer
from io import BytesIO
import tempfile

class TaskManager:
    # we use this to keep track of the loaded pid icons so that we don't have to load the icons everytime
    pidIcons={}
    def _get_process_icon(self, pid):
        if pid in self.pidIcons:
            return self.pidIcons[pid]
        
        try:
            process = psutil.Process(pid)
            exe_path = process.as_dict(attrs=['exe'])['exe']
            if exe_path is None or exe_path == '' or 'System32' in exe_path:
                return None

            import win32ui
            import win32gui
            import win32con
            import win32api
            from PIL import Image

            ico_x = win32api.GetSystemMetrics(win32con.SM_CXICON)
            ico_y = win32api.GetSystemMetrics(win32con.SM_CYICON)
            try:
                large, small = win32gui.ExtractIconEx(exe_path, 0)
            except:
                return None
            if len(large) == 0 or len(small) == 0:
                return None
            win32gui.DestroyIcon(small[0])

            hdc = win32ui.CreateDCFromHandle(win32gui.GetDC(0))
            hbmp = win32ui.CreateBitmap()
            hbmp.CreateCompatibleBitmap(hdc, ico_x, ico_x)
            hdc = hdc.CreateCompatibleDC()

            hdc.SelectObject(hbmp)
            hdc.DrawIcon((0, 0), large[0])

            bmpstr = hbmp.GetBitmapBits(True)
            icon = Image.frombuffer(
                'RGBA',
                (ico_x, ico_y),  # Use the original icon size (ico_x, ico_y)
                bmpstr, 'raw', 'BGRA', 0, 1
            )

            icon = icon.resize((25, 25))  # Resize the image to (25, 25)

            buffered = BytesIO()
            icon.save(buffered, format="PNG")
            a=buffered.getvalue()
            img_str = base64.b64encode(buffered.getvalue())
            img_str=img_str.decode("utf-8") 
            self.pidIcons[pid]=img_str
            return img_str
        except Exception as c:
            return None
    def _get_running_processes_with_icon(self):
        processes = {}
        rawProcesses = psutil.process_iter(['pid', 'name', 'memory_info', 'cpu_percent'])
        ##disk_counters_prev = psutil.disk_io_counters()
        ##net_counters_prev = psutil.net_io_counters()
        ##time.sleep(1)
        ##disk_counters_curr = psutil.disk_io_counters()
        ##net_counters_curr = psutil.net_io_counters()
        ##
        ##disk_read_rate = (disk_counters_curr.read_bytes - disk_counters_prev.read_bytes) / (1024 * 1024)  # MB/s
        ##disk_write_rate = (disk_counters_curr.write_bytes - disk_counters_prev.write_bytes) / (1024 * 1024)  # MB/s
        ##networkReadRate = (net_counters_curr.bytes_recv - net_counters_prev.bytes_recv) / (1024 * 1024)  # MB/s
        ##networkWriteRate = (net_counters_curr.bytes_sent - net_counters_prev.bytes_sent) / (1024 * 1024)  # MB/s
        cpu_count=psutil.cpu_count()
        for process in rawProcesses:
            try:
                process_info = process.info
                pid = process_info['pid']
                name = process_info['name']
                # exclude the processes with these names, because they're system processes
                if any(substring in name for substring in ['System Idle Process', 'svchost', 'conhost']):
                    continue
                memoryUsage = process_info['memory_info'].rss / (1024 * 1024)  # Convert to MB
                cpuPercent = process_info['cpu_percent']/cpu_count
                icon = self._get_process_icon(pid)
                if name not in processes:
                    processes[name] = {'pids': [pid], 'memoryUsage': memoryUsage, 'cpuPercent': cpuPercent, 'icon': icon}
                    #processes[name] = {'pids': [pid], 'memoryUsage': memoryUsage, 'cpuPercent': cpuPercent, 'icon': icon,
                    #                   'diskReadRate': disk_read_rate, 'diskWriteRate': disk_write_rate,
                    #                   'networkReadRate': networkReadRate, 'networkWriteRate': networkWriteRate}
                else:
                    processes[name]['pids'].append(pid)
                    processes[name]['memoryUsage'] += memoryUsage
                    processes[name]['cpuPercent'] += cpuPercent
                    #processes[name]['diskReadRate'] += disk_read_rate
                    #processes[name]['diskWriteRate'] += disk_write_rate
                    #processes[name]['networkReadRate'] += networkReadRate
                    #processes[name]['networkWriteRate'] += networkWriteRate
                    processes[name]['icon'] = icon

            except psutil.NoSuchProcess:
                pass
            time.sleep(0.006)
        #for process in processes:
        #    #round some numbers to save up bandwidth
        #    processes[process]['networkReadRate']=round(processes[process]['networkReadRate'],2)
        #    processes[process]['networkWriteRate']=round(processes[process]['networkWriteRate'],2)
        #    processes[process]['diskReadRate']=round(processes[process]['diskReadRate'],2)
        #    processes[process]['diskWriteRate']=round(processes[process]['diskWriteRate'],2)
        return processes
    def getProcesses(self):
        running_processes = self._get_running_processes_with_icon()
        return running_processes

a=TaskManager()

while True:
    start = timer()       
    r=TaskManager()._get_running_processes_with_icon()   
    elpased_time=timer() -start      
    f = tempfile.TemporaryFile()
    tempdir=tempfile.gettempdir()
    open(f"{tempdir}\\zal_taskmanager_result.json","w+").write(json.dumps(r))
    #time.sleep(abs(0.9-elpased_time))
    print(timer()-start)