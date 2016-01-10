#import "VTDeviceLoader.h"
#import "VTDevice.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>

NSString *VTDeviceAddedNotification = @"VTDeviceAddedNotification";
NSString *VTDeviceRemovedNotification = @"VTDeviceRemovedNotification";


@interface VTDeviceLoader ()
- (void)_addDevice:(io_service_t)device;
- (void)_removeDevice:(io_service_t)device;
@end

static VTDeviceLoader *the_one_true_instance = Nil;

static void _RawDeviceAdded(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ( (usbDevice = IOIteratorNext(iterator)) ) {
        [loader _addDevice:usbDevice];
        
        IOObjectRelease(usbDevice);
    }
}


static void _RawDeviceRemoved(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ( (usbDevice = IOIteratorNext(iterator)) ) {
        [loader _removeDevice:usbDevice];
        
        IOObjectRelease(usbDevice);
    }
}


@implementation VTDeviceLoader

+ loader {
    if (!the_one_true_instance) {
        the_one_true_instance = [[VTDeviceLoader alloc] init];
    }
    
    return the_one_true_instance;
}


- (void)dealloc {
    [_devicesByLocation release]; _devicesByLocation = nil;
    [_devicesBySerial release]; _devicesBySerial = nil;
    [super dealloc];
}


- (NSArray *)devices {
    return [_devicesBySerial allValues];
}


- (VTDevice *)deviceForSerialNumber:(NSString *)serial {
    return [_devicesBySerial objectForKey:serial];
}


- (void)_addDevice:(io_service_t)usbDevice {
	IOReturn result;
    CFMutableDictionaryRef properties;
    NSString *location;
    
    if (!usbDevice) {
        result = kIOReturnSuccess;
        properties = (CFMutableDictionaryRef)[NSDictionary new];
        location = @"Nowhere";
		
    } else {
        result = IORegistryEntryCreateCFProperties(usbDevice, &properties,  kCFAllocatorDefault, kNilOptions);
        location = [(NSDictionary *)properties objectForKey:@"locationID"];
    }
    
    if ((result == kIOReturnSuccess) && properties) {
        
        VTDevice *device = [VTDevice deviceForProperties:(NSDictionary *)properties];
		
        if (device) {
            // The locationID uniquely identifies the device and will remain the same, even across
            // reboots, so long as the bus topology doesn't change.        
            [_devicesByLocation setObject:device forKey:location]; 
            [_devicesBySerial setObject:device forKey:[device serial]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VTDeviceAddedNotification object:self userInfo:[NSDictionary dictionaryWithObject:[device serial] forKey:@"serial"]];
        }
        CFRelease(properties);
    }
}


- (void)_removeDevice:(io_service_t)usbDevice {
	IOReturn result;
    CFMutableDictionaryRef properties;
    
    result = IORegistryEntryCreateCFProperties(usbDevice, &properties,  kCFAllocatorDefault, kNilOptions);
    if ((result == kIOReturnSuccess) && properties) {
        NSString *location = [(NSDictionary *)properties objectForKey:@"locationID"];
        VTDevice *device = [_devicesByLocation objectForKey:location];
        NSString *serial = [[[device serial] retain] autorelease];
        
        [_devicesByLocation removeObjectForKey:location]; 
        [_devicesBySerial removeObjectForKey:serial]; 
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VTDeviceRemovedNotification object:self userInfo:[NSDictionary dictionaryWithObject:serial forKey:@"serial"]];
		
        CFRelease(properties);
        
    }
}


- init {
  if ((self = [super init])) {

    _devicesByLocation = [[NSMutableDictionary alloc] init];
    _devicesBySerial = [[NSMutableDictionary alloc] init];
	
    CFRunLoopSourceRef      runLoopSource;
    kern_return_t           kr;
    io_iterator_t           rawAddedIter;
    io_iterator_t           rawRemovedIter;
    CFMutableDictionaryRef  matchingDict;
    IONotificationPortRef   notifyPort;
	
    // Set up matching dictionary for class IOUSBDevice and its subclasses
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if (!matchingDict) {
        NSLog(@"ERR: Couldn’t create a USB matching dictionary");
        return nil;
    }
    
    // Add the FTDI 232R vendor ID to the matching dictionary.
    SInt32        usbVendor = 0x0403; 
    CFNumberRef   vendorID = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
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
    
    // Notification of first match:  Retain an additional dictionary reference because each call to
    // IOServiceAddMatchingNotification consumes one reference
    matchingDict = (CFMutableDictionaryRef) CFRetain(matchingDict);
    kr = IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, matchingDict, _RawDeviceAdded, self, &rawAddedIter);
    
    // Iterate over set of matching devices to access already-present devices and to arm the notification
    _RawDeviceAdded(self, rawAddedIter);
    
    // Notification of termination: Retain an additional dictionary references because each call to
    // IOServiceAddMatchingNotification consumes one reference
    matchingDict = (CFMutableDictionaryRef) CFRetain(matchingDict);
    kr = IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, _RawDeviceRemoved, self, &rawRemovedIter);
    
    // Iterate over set of matching devices to access already-present devices and to arm the notification
    _RawDeviceRemoved(self, rawRemovedIter);
    
    // Release the matching dictionary
    CFRelease(matchingDict);
    
    // For debug, add a fake device by default.
    //[self _addDevice:IO_OBJECT_NULL];
  }
  return self;
}


@end
