//
//  DeviceLoader.m
//  Velocitool
//
//  Created by Eric Noyau on 07/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VTDeviceLoader.h"
#import "VTDevice.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>

NSString *VTDeviceChangedNotification = @"VTDeviceChangedNotification";


@interface VTDeviceLoader ()
- (void)_addDevice:(io_service_t)device;
- (void)_removeDevice:(io_service_t)device;
- (void)_notify;
@end

static VTDeviceLoader *the_one_true_instance = Nil;

static void _RawDeviceAdded(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ( (usbDevice = IOIteratorNext(iterator)) ) {
        [loader _addDevice:usbDevice];
        
        IOObjectRelease(usbDevice);
    }
    [loader _notify];
}

static void _RawDeviceRemoved(void *loader_ptr, io_iterator_t iterator) {
    VTDeviceLoader *loader = (VTDeviceLoader *)loader_ptr;
    io_service_t usbDevice;
    
    while ( (usbDevice = IOIteratorNext(iterator)) ) {
        [loader _removeDevice:usbDevice];
        
        IOObjectRelease(usbDevice);
    }
    [loader _notify];
}


@implementation VTDeviceLoader

+ loader {
    if (!the_one_true_instance) {
        the_one_true_instance = [[VTDeviceLoader alloc] init];
    }
    
    return the_one_true_instance;
}

- (void)dealloc {
    [super dealloc];
    [_devices release];
    _devices = nil;
}

- (NSArray *)devices {
    return [_devices allValues];
}

- (void)_addDevice:(io_service_t)usbDevice {
    NSLog(@"Adding device");
	IOReturn result;
    CFMutableDictionaryRef properties;
    
    result = IORegistryEntryCreateCFProperties(usbDevice, &properties,  kCFAllocatorDefault, kNilOptions);
    if ((result == kIOReturnSuccess) && properties) {
        NSLog(@"%@", properties);
        
        VTDevice *device = [VTDevice deviceForProperties:(NSDictionary *)properties];
        
        if (device) {
            // The locationID uniquely identifies the device and will remain the same, even across
            // reboots, so long as the bus topology doesn't change.        
            [_devices setObject:device
                         forKey:[(NSDictionary *)properties objectForKey:@"locationID"]
            ]; 
        }
        CFRelease(properties);
    }
}

- (void)_removeDevice:(io_service_t)usbDevice {
    NSLog(@"removing device");
	IOReturn result;
    CFMutableDictionaryRef properties;
    
    result = IORegistryEntryCreateCFProperties(usbDevice, &properties,  kCFAllocatorDefault, kNilOptions);
    if ((result == kIOReturnSuccess) && properties) {
        NSLog(@"%@", properties);
        [_devices removeObjectForKey:[(NSDictionary *)properties objectForKey:@"locationID"]]; 
        CFRelease(properties);
    }
}

- (void)_notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:VTDeviceChangedNotification object:self];
}


- init {
    _devices = [[NSMutableDictionary alloc] init];

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
    
    //Iterate over set of matching devices to access already-present devices
    //and to arm the notification
    _RawDeviceAdded(self, rawAddedIter);
    
    // Notification of termination: Retain an additional dictionary references because each call to
    // IOServiceAddMatchingNotification consumes one reference
    matchingDict = (CFMutableDictionaryRef) CFRetain(matchingDict);
    kr = IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, _RawDeviceRemoved, self, &rawRemovedIter);
    
    //Iterate over set of matching devices to access already-present devices
    //and to arm the notification
    _RawDeviceRemoved(self, rawRemovedIter);
    
    // Release the matching dictionary
    CFRelease(matchingDict);
        
    return self;
}


@end
