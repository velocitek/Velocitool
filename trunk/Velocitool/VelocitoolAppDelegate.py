
from Foundation import *
from AppKit import *

class VelocitoolAppDelegate(NSObject):
    def __init__(self):
        self.devices = [ (1, "a"), (2, b)]
        self.selection = []
        pass
        
    def applicationDidFinishLaunching_(self, sender):
        mainBundle =  NSBundle.mainBundle()
        
        libPath = mainBundle.pathForResource_ofType_("libftd2xx.0.1.4.dylib", "")
        
        wrapper = VTWrapper.wrapperForLibAtPath_(libPath)
        
        
        NSLog("Devices = %@", VTDeviceLoader.loader().devices())

        NSLog("Application did finish launching.")
