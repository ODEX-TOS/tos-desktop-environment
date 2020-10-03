import dbus
import re
import subprocess as s
from dbus.mainloop.glib import DBusGMainLoop
DBusGMainLoop(set_as_default=True)
 
bus = dbus.SystemBus()
DeviceName = {}

def valid(name):
    return re.search("^sd[a-z][0-9][0-9]*$",name)

def notify(title, desc):
    s.call(["notify-send", title, desc])

def extract_name(name):
    """
    Extract /dev/ from the name
    """
    return name.replace('/dev/', '').replace('/', '')

def get_device_from_dbus(cls):
    deviceinfo = cls.get('org.freedesktop.UDisks2.Block')
    dev = bytearray(deviceinfo.get('Device')).replace(b'\x00', b'').decode('utf-8')
    return dev
 
# Function which will run when signal is received
def callback_added_function(address, cls):
    device = get_device_from_dbus(cls)
    naming = extract_name(device)
    DeviceName[address] = naming
    if valid(naming):
        notify("USB plugged in", "Mounting to /media/"+naming)

def callback_removed_function(address, cls):
    device=DeviceName[address]
    if valid(device):
        notify("USB removed", "Unmounting from /media/"+device)
 
# Which signal to have an eye for
iface  = 'org.freedesktop.DBus.ObjectManager'
signal = 'InterfacesAdded'
signalR = 'InterfacesRemoved'
bus.add_signal_receiver(callback_added_function, signal, iface)
bus.add_signal_receiver(callback_removed_function, signalR, iface)
 
# Let's start the loop
import gi.repository.GLib as gi
loop = gi.MainLoop()
loop.run()
