#import <Cocoa/Cocoa.h>

@class VTDevice;

// Triggered when at least one device is plugged in or disconnected. Call -devices to get them.
// The user info contains the serial number of the device in question, under the key @"serial"
extern NSString *VTDeviceAddedNotification;
extern NSString *VTDeviceRemovedNotification;

@interface VTDeviceLoader : NSObject {
    
	NSMutableDictionary *_devicesByLocation;
    NSMutableDictionary *_devicesBySerial;
			
}

+ loader;
- (NSArray *)devices; // Returns an array of currently plugged in VTDevices
- (VTDevice *)deviceForSerialNumber:(NSString *)serial;

@end
