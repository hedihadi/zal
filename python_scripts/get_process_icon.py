import base64
from io import BytesIO
import win32ui
import win32gui
import win32con
import win32api
from PIL import Image
from sys import argv
import socketio
import eventlet

sio = socketio.Server()
app = socketio.WSGIApp(sio)


@sio.on('get_process_icon')
def get_process_icon(sid, data):
    try:
        ico_x = win32api.GetSystemMetrics(win32con.SM_CXICON)
        ico_y = win32api.GetSystemMetrics(win32con.SM_CYICON)
        try:
            large, small = win32gui.ExtractIconEx(data, 0)
        except:
            pass
        if len(large) == 0 or len(small) == 0:
            pass
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
            (ico_x, ico_y),
            bmpstr, 'raw', 'BGRA', 0, 1
        )
        if (ico_x > 49):
            icon = icon.resize((50, 50))
        icon = icon.resize((50, 50))
        buffered = BytesIO()
        icon.save(buffered, format="PNG")
        a = buffered.getvalue()
        img_str = base64.b64encode(buffered.getvalue())
        img_str = img_str.decode("utf-8")
        sio.emit('process_icon', {"process": data, "icon": img_str})
    except Exception as c:
        sio.emit('process_icon', {"process": data, "icon": None})


if __name__ == '__main__':
    # Run the SocketIO server using eventlet
    eventlet.wsgi.server(eventlet.listen(('0.0.0.0', 6511)), app)
