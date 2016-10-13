
#import "VTCommand.h"
#import "VTConnection.h"
#import "VTDevice.h"
#import "VTFirmwareFile.h"
#import "VTGlobals.h"
#import "VTRecord.h"
#import "VTDeviceLoader.h"

#include <IOKit/usb/IOUSBLib.h>

@interface VTDevice () {
    NSDictionary *_usbProperties;
    io_service_t usbDevice;
}
// The open connection to the device.
@property(nonatomic, readonly, strong) VTConnection *connection;

// Private designated initializer.
- (instancetype)initWithConnection:(VTConnection *)connection usbProperties:(NSDictionary*) properties;
@end

@interface VTDeviceGeneration3 : VTDevice {
    NSString *_firmwareVersion;
    NSDictionary *_deviceSettings;
}
@end

@interface VTDeviceSpeedPuck : VTDeviceGeneration3 {
}
@end
@interface VTDeviceProStart : VTDeviceGeneration3 {
}
@end

@interface VTDeviceS10 : VTDevice {
}
@end
@interface VTDeviceSC1 : VTDevice {
}
@end

@implementation VTDevice
static NSDictionary *productIDToClass = nil;

@synthesize connection = _connection;

#pragma mark - Class methods
+ (void)initialize {
    if (self != [VTDevice self]) {
        return;
    }
    
    productIDToClass = @{
                         @(0xb709) : [VTDeviceSpeedPuck class],
                         @(0xb70a) : [VTDeviceProStart class],
                         @(0x6001) : [VTDeviceS10 class],
                         @(0xb708) : [VTDeviceSC1 class],
                         };
}

+ deviceForUSBProperties:(NSDictionary *)usbProperties {
    
    NSLog(@"deviceForUSBProperties");
    
    int productID = [[usbProperties objectForKey:@kUSBProductID] intValue];
    
    NSAssert(productID, @"No productID");
    
    id klass = [productIDToClass objectForKey:[NSNumber numberWithInt:productID]];
    if (!klass) {
        return nil;
    }
    
    int vendorID = [[usbProperties objectForKey:@kUSBVendorID] intValue];
    NSAssert(vendorID, @"No vendor ID");
    
    NSString *serial = [usbProperties objectForKey:@kUSBSerialNumberString];
    NSAssert(serial, @"No serial number");
    
    NSString *productName = [usbProperties objectForKey:@kUSBProductString];
    
    VTConnection *connection = [VTConnection connectionWithVendorID:vendorID
                                                          productID:productID
                                                       serialNumber:serial
                                                        productName:productName];
    
    NSLog(@"Opening connection (%p) to device: %@ - %@", connection, productName, serial);
    
    BOOL success = [connection open];
    
    // Retry 1
    if (!success) {
        
        NSLog(@"Open failed. Reloading driver and waiting 0.5 seconds before trying again.");
        
        [connection recover];

        sleep(3);
        
        success = [connection open];
        
        // Retry 2
        if (!success) {
            
            NSLog(@"Open failed. Reloading driver and waiting 3 seconds before trying again.");
            
            [connection closeConnectionAndReloadLibrary];
            
            sleep(3);
            
            success = [connection open];
            
            if (!success) {
                
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"We're having trouble connecting to your device."];
                [alert setInformativeText:@"Please unplug the device USB cable, wait a few seconds, and plug it back in."];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
                
                return nil;
            }
            
            
        }
        
        
    }
    
    return [[klass alloc] initWithConnection:connection usbProperties:usbProperties];
}

#pragma mark - Init

- (instancetype)initWithConnection:(VTConnection *)connection
                     usbProperties:(NSDictionary *)usbProperties {
    _connection = connection;
    _usbProperties = [usbProperties copy];
    
    return self;
}

- (void)dealloc {
    _usbProperties = nil;
}

#pragma mark - Public methods

- (NSString *)serial {
    return [_usbProperties objectForKey:@kUSBSerialNumberString];
}

- (NSString *)model {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (NSString *)firmwareVersion {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (NSDictionary *)deviceSettings {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (void)recoverDeviceConnection {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (NSArray *)trackpointLogs {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (BOOL)updateFirmware:(NSString *)filePath {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    
    return FIRMWARE_UPDATE_FAILED;
}

- (void)eraseAll {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (void) closeDeviceConnection {
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (NSString *)description {
    NSString *sd = [super description];
    NSString *s = [self serial];
    NSString *fv = [self firmwareVersion];
    
    return [NSString stringWithFormat:@"%@ (%@, %@)", sd, s, fv];
}


- (void) reenumerateDevice {
    
    if ([_usbProperties objectForKey:@"io_service_t"]) {
        io_service_t devService = [_usbProperties objectForKey:@"io_service_t"];
        [[VTDeviceLoader loader] reenumerateUsbDevice:devService];
    }
    
}
@end

@implementation VTDeviceS10

- (NSString *)model {
    return @"S10";
}

- (NSString *)firmwareVersion {
    // There is no way to get the firmware version of the S10. Just return the
    // known version
    return @"1.1";
}

@end

@implementation VTDeviceSC1
// The legacy method of determining firmware version was to get a user
// information record and decode the byte storing firmware version. However
// getting a command involves knowing the firmware version which we do not know
// yet. Kind of a catch 22 here.
//
// The new method is a simple command, as used on the puck.
//
- (NSString *)model {
    return @"SC1";
}

@end

// This is an abstract class
@implementation VTDeviceGeneration3

- (void)dealloc {
    _firmwareVersion = nil;
    _deviceSettings = nil;
}

- (NSString *)firmwareVersion {
    if (!_firmwareVersion) {
        
        VTCommand *firmwareVersionCommand =
        [VTCommand commandWithSignal:'V'
                           parameter:nil
                         resultClass:[VTFirmwareVersionRecord class]];
        
        VTFirmwareVersionRecord *result =
        (VTFirmwareVersionRecord *)[self.connection
                                    runCommand:firmwareVersionCommand];
        
        _firmwareVersion = [[result version] copy];
    }
    return _firmwareVersion;
}

- (NSArray *)trackpointLogs {
    
    VTCommand *trackpointLogsCommand = [VTCommand commandWithSignal:'O'
                                                          parameter:nil
                                                       resultsClass:[VTTrackpointLogRecord class]];
    
    return [self.connection runCommand:trackpointLogsCommand];
}

- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo {
    
    VTReadTrackpointsCommandParameter *commandParameter = [VTReadTrackpointsCommandParameter commandParameterFromDate:downloadFrom
                                                                                                               toDate:downloadTo];
    
    VTCommand *command = [VTCommand commandWithSignal:'T'
                                            parameter:commandParameter
                                         resultsClass:[VTTrackpointRecord class]];
    
    // Notice that we're using the special track download specific command
    // that includes the error detection
    return (NSArray *)[self.connection runCommandTrackDownload:command];
}

- (void)eraseAll {
    [self.connection runCommand:[VTCommand commandWithSignal:'E' parameter:nil resultClass:[VTCommandResultRecord class]]];
}

- (BOOL)updateFirmware:(NSString *)filePath {
    
    NSLog(@"VTLOG: [VTDevice, updateFirmware = %@]", filePath);  // VTLOG for debugging
    
    VTFirmwareFile *firmwareFile =
    [VTFirmwareFile vtFirmwareFileWithFilePath:filePath];
    return [self.connection runFirmwareUpdate:firmwareFile];
}

- (void)recoverDeviceConnection {
    [self.connection recover];
}

- (void) closeDeviceConnection {
    [self.connection close];
}


@end

@implementation VTDeviceSpeedPuck

- (NSString *)model {
    return @"SpeedPuck";
}

- (NSDictionary *)deviceSettings {
    if (!_deviceSettings) {
        VTPuckSettingsRecord *result = (VTPuckSettingsRecord *)[self.connection
                                                                runCommand:[VTCommand commandWithSignal:'S'
                                                                                              parameter:nil
                                                                                            resultClass:[VTPuckSettingsRecord class]]];
        
        _deviceSettings = [[result settingsDictionary] copy];
    }
    return _deviceSettings;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
    [self.connection
     runCommand:[VTCommand commandWithSignal:'D'
                                   parameter:[VTPuckSettingsRecord
                                              recordFromSettingsDictionary:
                                              settings]
                                 resultClass:[VTCommandResultRecord class]]];
    
    _deviceSettings = nil;
}

@end

@implementation VTDeviceProStart
- (NSString *)model {
    return @"ProStart";
}
@end
