#import <Cocoa/Cocoa.h>

// This represent a Velocitek device. This class is an abstract superclass,
// all devices will be concrete subclasses.
@interface VTDevice : NSObject

// Properties is assumed to be a dictionary created by
// IORegistryEntryCreateCFProperties. The keys kUSBVendorID, kUSBProductID and
// kUSBSerialNumberString need to all be there for the object to be created.
// A table in the class will return the right device object subclass for the
// properties.
+ deviceForUSBProperties:(NSDictionary *)usbProperties;

// Returns the serial number of the device.
- (NSString *)serial;

// Returns the model of the device.
- (NSString *)model;

// Return the firmware version currently installed on the device.
- (NSString *)firmwareVersion;

// Only the speedpuck supports device settings.
// TODO: Currently the UI knows the models that support settings. This should be
// captured in this class instead.
- (NSDictionary *)deviceSettings;
- (void)setDeviceSettings:(NSDictionary *)settings;

// Only the speedpuck and the ProStart do capture logs (well, the other may be,
// but the code to retrieve the data is not here).
// TODO: Same as deviceSettings: the UI captures the capabilities for now.
- (NSArray *)trackpointLogs;
- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo;
- (void)eraseAll;

// Not working. Do not use for now.
- (BOOL)updateFirmware:(NSString *)filePath;

- (void) recoverDeviceConnection;
- (void) closeDeviceConnection;

@end
