
#import "VTDevice.h"
#import "VTConnection.h"
#import "VTCommand.h"
#import "VTGlobals.h"

#include <IOKit/usb/IOUSBLib.h>


static NSDictionary *productIDToClass = nil;

@interface VTDevice ()
- initWithConnection:(VTConnection *)connection properties:(NSDictionary *)properties;
@end


@interface VTDeviceSpeedPuck:VTDevice {
    NSString *_firmwareVersion;
    NSDictionary *_deviceSettings;
} 
@end

@interface VTDeviceS10:VTDevice {} @end
@interface VTDeviceSC1:VTDevice {} @end
@interface VTFakeDevice:VTDevice {} @end

@implementation VTDevice

+ (void)initialize {
    productIDToClass = [[NSDictionary alloc] initWithObjectsAndKeys:
                        [VTDeviceSpeedPuck class], [NSNumber numberWithInt:0xb709], 
                        [VTDeviceS10 class],       [NSNumber numberWithInt:0x6001], 
                        [VTDeviceSC1 class],       [NSNumber numberWithInt:0xb708], 
                        nil
    ];
}

+ deviceForProperties:(NSDictionary *)properties {
    VTConnection *connection;
    
    if (![properties count]) {
        return [[VTFakeDevice alloc] init];
    }
    
    int vendorID = [[properties objectForKey:@kUSBVendorID] intValue];
    int productID = [[properties objectForKey:@kUSBProductID] intValue];
    NSString *serial = [properties objectForKey:@"USB Serial Number"];
    id klass = [productIDToClass objectForKey:[NSNumber numberWithInt:productID]];
    
    if (vendorID && klass && serial &&
        (connection = [VTConnection connectionWithVendorID:vendorID productID:productID serialNumber:serial]) ) {
            return [[[klass alloc] initWithConnection:connection properties:properties] autorelease];
    }
    return nil;
}

- initWithConnection:(VTConnection *)connection properties:(NSDictionary *)properties {
    _connection = [connection retain];
    _properties = [properties copy];
    return self;
    
}

- (NSString *)serial {
    return [_properties objectForKey:@"USB Serial Number"];
}

- (void)dealloc {
    [_connection release]; _connection = nil;
    [_properties release]; _properties = nil;
    [super dealloc];
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

- (BOOL)isPowered {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return FALSE;
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

- (NSArray *)trackpointLogs {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (NSString *)description {
    NSString *sd     = [super description];
    NSString *s      = [self serial];
    NSString *fv     = [self firmwareVersion];
    
    return [NSString stringWithFormat:@"%@ (%@, %@)", sd, s, fv];
}

@end

@implementation VTDeviceS10

- (BOOL)isPowered {
    return YES; // Actually, who knows.
}

- (NSString *)model {
    return @"S10";
}

- (NSString *)firmwareVersion {
    // There is no way to get the firmware version of the S10. Just return the known version
    return @"1.1";
}

- (NSDictionary *)deviceSettings {
    return [NSDictionary dictionary]; // No settings
}

- (void)setDeviceSettings:(NSDictionary *)settings {
}

@end

@implementation VTDeviceSC1
    // The legacy method of determining firmware version was to get a user information record and
    // decode the byte storing firmware version. However getting a command involves knowing the 
    // firmware version which we do not know yet. Kind of a catch 22 here.
    //
    // The new method is a simple command, as used on the puck. 
    //
- (NSString *)model {
    return @"SC1";
}

@end

@implementation VTFakeDevice

- (BOOL)isPowered {
    return YES;
}

- (NSString *)model {
    return @"FakeStuff";
}

- (NSString *)serial {
    return @"Fake007";
}

- (NSString *)firmwareVersion {
    return @"3.1415";
}

- (NSDictionary *)deviceSettings {
    return [[VTPuckSettingsRecord recordFromSettingsDictionary:nil] settingsDictionary];
}

- (void)setDeviceSettings:(NSDictionary *)settings {
    NSLog(@"set settings %@", settings);
}

- (NSArray *)trackpointLogs {
    return [NSArray array];
}


@end

@implementation VTDeviceSpeedPuck

- (BOOL)isPowered {
    return YES;
    /* The puck is powered by USB while plugged in. So this code works, but is not necessary
    NSData *result = [_wrapperDevice runCommand:'P' withArguments:nil responsePrefix:'p' expectedLength:1];
    if (result) {
        return ((char *)[result bytes])[0];
    }
    return -1;
    */
}

- (NSString *)model {
    return @"SpeedPuck";
}

- (void)dealloc {
    [_firmwareVersion release]; _firmwareVersion = nil;
    [_deviceSettings release];  _deviceSettings = nil;
    [super dealloc];
}

- (NSString *)firmwareVersion {
    if(!_firmwareVersion) {
        VTFirmwareVersionRecord *result = (VTFirmwareVersionRecord *)[_connection runCommand:[VTCommand commandWithSignal:'V' parameter:nil resultClass:[VTFirmwareVersionRecord class]]];
        
        _firmwareVersion = [[result version] copy];
    }
    return _firmwareVersion;
}

- (NSDictionary *)deviceSettings {
    if(!_deviceSettings) {
        VTPuckSettingsRecord *result = (VTPuckSettingsRecord *)[_connection runCommand:[VTCommand commandWithSignal:'S' parameter:nil resultClass:[VTPuckSettingsRecord class]]];
    
        _deviceSettings = [[result settingsDictionary] copy];
    }
    return _deviceSettings;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
    [_connection runCommand:[VTCommand commandWithSignal:'D' parameter:[VTPuckSettingsRecord recordFromSettingsDictionary:settings] resultClass:[VTCommandResultRecord class]]];
    
    [_deviceSettings release]; _deviceSettings = nil;
}

- (NSArray *)trackpointLogs {
    NSArray *records = (NSArray *)[_connection runCommand:[VTCommand commandWithSignal:'O' parameter:nil resultsClass:[VTTrackpointLogRecord class]]];
    return records;
}
                                                   
@end


