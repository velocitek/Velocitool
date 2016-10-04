#import "VTDevice.h"
#import "VTDeviceLoader.h"

#include <IOKit/IOCFPlugIn.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>

NSString *VTDeviceAddedNotification = @"VTDeviceAddedNotification";
NSString *VTDeviceRemovedNotification = @"VTDeviceRemovedNotification";

@interface VTDeviceLoader () {
    NSMutableDictionary *_devicesByLocation;
    NSMutableDictionary *_devicesBySerial;
    NSMutableDictionary *_ioServiceBySerial;
    
}
- (void)_addDevice:(io_service_t)device;
- (void)_removeDevice:(io_service_t)device;
@end

static void _RawDeviceAdded(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (__bridge VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        [loader _addDevice:usbDevice];
        NSLog(@"_RawDeviceAdded: %d", usbDevice);
        IOObjectRelease(usbDevice);
    }
}

static void _RawDeviceRemoved(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (__bridge VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        [loader _removeDevice:usbDevice];
        NSLog(@"_RawDeviceRemoved: %d", usbDevice);
        IOObjectRelease(usbDevice);
    }
}

@implementation VTDeviceLoader

+ loader {
    static VTDeviceLoader *the_one_true_instance = nil;
    if (!the_one_true_instance) {
        the_one_true_instance = [[VTDeviceLoader alloc] init];
    }
    return the_one_true_instance;
}

- init {
    if ((self = [super init])) {
        _devicesByLocation = [[NSMutableDictionary alloc] init];
        _devicesBySerial = [[NSMutableDictionary alloc] init];
        
        CFRunLoopSourceRef runLoopSource;
        kern_return_t kr;
        io_iterator_t rawAddedIter;
        io_iterator_t rawRemovedIter;
        CFMutableDictionaryRef matchingDict;
        IONotificationPortRef notifyPort;
        
        // Set up matching dictionary for class IOUSBDevice and its subclasses
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        if (!matchingDict) {
            NSLog(@"ERR: Couldn’t create a USB matching dictionary");
            return nil;
        }
        
        // Add the FTDI 232R vendor ID to the matching dictionary.
        SInt32 usbVendor = 0x0403;
        CFNumberRef vendorID = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
        CFDictionarySetValue(matchingDict, CFSTR(kUSBVendorID), vendorID);
        CFRelease(vendorID);
        
        // Add a wild card match for the productID to the matching dictionary.
        CFDictionarySetValue(matchingDict, CFSTR(kUSBProductID), CFSTR("*"));
        
        // To set up asynchronous notifications, create a notification port and
        // add its run loop event source to the program’s run loop
        notifyPort = IONotificationPortCreate(kIOMasterPortDefault);
        runLoopSource = IONotificationPortGetRunLoopSource(notifyPort);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
        
        //
        // Now set up two notifications: one to be called when a raw device
        // is first matched by the I/O Kit and another to be called when the
        // device is terminated
        //
        
        // Notification of first match:  Retain an additional dictionary reference
        // because each call to IOServiceAddMatchingNotification consumes one
        // reference
        matchingDict = (CFMutableDictionaryRef)CFRetain(matchingDict);
        
        kr = IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, matchingDict, _RawDeviceAdded, (__bridge void *)(self), &rawAddedIter);
        
        NSAssert(kr == KERN_SUCCESS, @"Unable to setup the device match.");
        
        // Iterate over set of matching devices to access already-present devices
        // and to arm the notification
        _RawDeviceAdded((__bridge void *)(self), rawAddedIter);
        
        // Notification of termination: Retain an additional dictionary references
        // because each call to IOServiceAddMatchingNotification consumes one
        // reference
        matchingDict = (CFMutableDictionaryRef)CFRetain(matchingDict);
        
        kr = IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, _RawDeviceRemoved, (__bridge void *)(self),&rawRemovedIter);
        NSAssert(kr == KERN_SUCCESS,  @"Unable to setup the device termination match.");
        
        // Iterate over set of matching devices to access already-present devices
        // and to arm the notification
        _RawDeviceRemoved((__bridge void *)(self), rawRemovedIter);
        
        // Release the matching dictionary
        CFRelease(matchingDict);
        
        // added
        mach_port_deallocate(mach_task_self(), notifyPort);
        notifyPort = 0;
        
    }
    return self;
}

- (void)dealloc {
    _devicesByLocation = nil;
    _devicesBySerial = nil;
}

- (NSArray *)devices {
    return [_devicesBySerial allValues];
}

- (VTDevice *)deviceForSerialNumber:(NSString *)serial {
    return [_devicesBySerial objectForKey:serial];
}

- (void)_addDevice:(io_service_t)usbDevice {
    
    NSLog(@"VTDeviceLoader:_addDevice");
    
    NSAssert(usbDevice, @"Unexpected empty usbDevice.");
    
    CFMutableDictionaryRef properties;
    
    IOReturn result = IORegistryEntryCreateCFProperties(usbDevice, &properties, kCFAllocatorDefault, kNilOptions);
    
    NSAssert(result == kIOReturnSuccess, @"Can't create properties.");
    
    CFDictionarySetValue(properties, @"io_service_t", usbDevice);
    
    if (properties) {
        
        VTDevice *device = [VTDevice deviceForUSBProperties:(__bridge NSDictionary *)properties];
        
        if (device) {
            // The locationID uniquely identifies the device and will remain the same,
            // even across reboots, so long as the bus topology doesn't change.
            NSString *location = [(__bridge NSDictionary *)properties objectForKey:@"locationID"];
            NSString *serial = [device serial];
            
            if (location && serial) {
                
                [_devicesByLocation setObject:device forKey:location];
                [_devicesBySerial setObject:device forKey:[device serial]];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:VTDeviceAddedNotification
                 object:self
                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:serial, @"serial", location, @"location", nil]
                 ];
                
            }
        }
        
        CFRelease(properties);
    }
}


- (void)_removeDevice:(io_service_t)usbDevice {
    NSAssert(usbDevice, @"Unexpected empty usbDevice.");
    
    CFMutableDictionaryRef properties;
    IOReturn result = IORegistryEntryCreateCFProperties(usbDevice, &properties, kCFAllocatorDefault, kNilOptions);
    NSAssert(result == kIOReturnSuccess, @"Can't create properties.");
    
    if (properties) {
        
        NSString *location = [(__bridge NSDictionary *)properties objectForKey:@"locationID"];
        
        NSAssert(location, @"Unable to extract location from properties");
        
        VTDevice *device = [_devicesByLocation objectForKey:location];
        if (!device) {
            NSLog(@"Removal of a device not properly registered.");
        }
        else {
            // Retain the serial as the device is likely to be deallocated.
            NSString *serial = [device serial];
            
            [_devicesByLocation removeObjectForKey:location];
            [_devicesBySerial removeObjectForKey:serial];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:VTDeviceRemovedNotification
             object:self
             userInfo:[NSDictionary dictionaryWithObject:serial
                                                  forKey:@"serial"]];
            
            [device closeDeviceConnection];
            
        }
        CFRelease(properties);
    }
}

-(void) reenumerateUsbDevice:(io_service_t) usbDevice
{
    kern_return_t               kr;
    IOCFPlugInInterface         **plugInInterface = NULL;
    struct IOUSBDeviceStruct187 **dev = NULL;
    HRESULT                     result;
    SInt32                      score;
    
    //Create an intermediate plug-in
    kr = IOCreatePlugInInterfaceForService(usbDevice,
                                           kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                           &plugInInterface, &score);
    //Don’t need the device object after intermediate plug-in is created
    kr = IOObjectRelease(usbDevice);
    if ((kIOReturnSuccess != kr) || !plugInInterface)
    {
        printf("Unable to create a plug-in (%08x)\n", kr);
        return;
    }
    
    //Now create the device interface
    result = (*plugInInterface)->QueryInterface(plugInInterface,
                                                CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                (LPVOID *)&dev);
    
    //Don’t need the intermediate plug-in after device interface
    //is created
    (*plugInInterface)->Release(plugInInterface);
    
    if (result || !dev)
    {
        printf("Couldn’t create a device interface (%08x)\n", (int) result);
        return;
    }
    
    //Open the device to change its state
    kr = (*dev)->USBDeviceOpen(dev);
    if (kr != kIOReturnSuccess)
    {
        printf("Unable to open device: %08x\n", kr);
        (void) (*dev)->Release(dev);
        return;
    }
    
    (*dev)->USBDeviceReEnumerate(dev, kUSBReEnumerateReleaseDeviceMask);
    
    //Close this device and release object
    kr = (*dev)->USBDeviceClose(dev);
    kr = (*dev)->Release(dev);
    
}


-(void) resetUsbDevice:(io_service_t) usbDevice
{
    kern_return_t               kr;
    IOCFPlugInInterface         **plugInInterface = NULL;
    struct IOUSBDeviceStruct187 **dev = NULL;
    HRESULT                     result;
    SInt32                      score;
    
    //Create an intermediate plug-in
    kr = IOCreatePlugInInterfaceForService(usbDevice,
                                           kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                           &plugInInterface, &score);
    //Don’t need the device object after intermediate plug-in is created
    kr = IOObjectRelease(usbDevice);
    if ((kIOReturnSuccess != kr) || !plugInInterface)
    {
        printf("Unable to create a plug-in (%08x)\n", kr);
        return;
    }
    
    //Now create the device interface
    result = (*plugInInterface)->QueryInterface(plugInInterface,
                                                CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                (LPVOID *)&dev);
    
    //Don’t need the intermediate plug-in after device interface
    //is created
    (*plugInInterface)->Release(plugInInterface);
    
    if (result || !dev)
    {
        printf("Couldn’t create a device interface (%08x)\n", (int) result);
        return;
    }
    
    //Open the device to change its state
    kr = (*dev)->USBDeviceOpen(dev);
    if (kr != kIOReturnSuccess)
    {
        printf("Unable to open device: %08x\n", kr);
        (void) (*dev)->Release(dev);
        return;
    }
    
    (*dev)->ResetDevice(dev);
    
    //Close this device and release object
    kr = (*dev)->USBDeviceClose(dev);
    kr = (*dev)->Release(dev);
    
}

@end
