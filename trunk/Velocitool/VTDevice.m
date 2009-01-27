
#import "VTDevice.h"
#import "VTWrapper.h"
#import "VTGlobals.h"
#import "VTConvert.h"

#include <IOKit/usb/IOUSBLib.h>


static NSDictionary *productIDToClass = nil;

@interface VTDevice ()
- initWithDeviceWrapper:(VTWrapperDevice *)wrapperDevice properties:(NSDictionary *)properties;
@end


@interface VTDeviceSpeedPuck:VTDevice {} @end
@interface VTDeviceS10:VTDevice {} @end
@interface VTDeviceSC1:VTDevice {} @end

@implementation VTDevice

+ (void)initialize {
    productIDToClass = [[NSDictionary alloc] initWithObjectsAndKeys:
                        [VTDeviceSpeedPuck class], [NSNumber numberWithInt:0xb709], 
                        [VTDeviceS10 class], [NSNumber numberWithInt:0x6001], 
                        [VTDeviceSC1 class], [NSNumber numberWithInt:0xb708], 
                        nil
    ];
}

+ deviceForProperties:(NSDictionary *)properties {
    VTWrapperDevice *wrapperDevice;
    
    int vendorID = [[properties objectForKey:@kUSBVendorID] intValue];
    int productID = [[properties objectForKey:@kUSBProductID] intValue];
    NSString *serial = [properties objectForKey:@"USB Serial Number"];
    id klass = [productIDToClass objectForKey:[NSNumber numberWithInt:productID]];
    
    if (vendorID && klass && serial &&
        (wrapperDevice = [[VTWrapper wrapper] openDeviceWithVendorID:vendorID productID:productID serialNumber:serial]) ) {
            return [[[klass alloc] initWithDeviceWrapper:wrapperDevice properties:properties] autorelease];
    }
    return nil;
}

- initWithDeviceWrapper:(VTWrapperDevice *)wrapperDevice properties:(NSDictionary *)properties {
    _properties = [properties copy];
    _wrapperDevice = [wrapperDevice retain];
    return self;
    
}

+ converterClass {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}


- (NSString *)serial {
    return [_properties objectForKey:@"USB Serial Number"];
}

- (void)dealloc {
    [super dealloc];
    [_properties release];     _properties = nil;
    [_wrapperDevice release];  _wrapperDevice = nil;
}

- (NSString *)firmwareVersion {
    // For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
    return nil;
}

- (NSString *)isPowered {
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

- (NSString *)description {
    NSString *sd = [super description];
    NSString *s = [self serial];
    NSString *fv =  [self firmwareVersion];
    NSDictionary *ds = [self deviceSettings];
    
    return [NSString stringWithFormat:@"%@ (%@, %@, settings = %@)", sd, s, fv, ds];
}

@end

@implementation VTDeviceS10
- (BOOL)isPowered {
    return YES;
}

- (NSString *)firmwareVersion {
    // There is no way to get the firmware version of the S10. Just return the known version
    return @"1.1";
}
@end

@implementation VTDeviceSC1
    // The legacy method of determining firmware version was to get a user information record and
    // decode the byte storing firmware version. However getting a command involves knowing the 
    // firmware version which we do not know yet. Kind of a catch 22 here.
    //
    // The new method is a simple command, as used on the puck. 
    //
@end

@implementation VTDeviceSpeedPuck

+ converterClass {
    return [VTPuckSettings class];
}

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

- (NSString *)firmwareVersion {
    NSData *result = [_wrapperDevice runCommand:'V' responsePrefix:'v' expectedLength:4];
    
    if (result) {
        const unsigned char *bytes = [result bytes];
        return [NSString stringWithFormat:@"%d.%d", bytes[0], bytes[1]]; // The two other bytes are not used.
    }
    return nil;
}

- (NSDictionary *)deviceSettings {
    NSData *result = [_wrapperDevice runCommand:'S' responsePrefix:'d' expectedLength:8];
    if (result) {
        return [[[self class] converterClass] settingsDictionaryForData:result];
    }
    return nil;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
    [_wrapperDevice runCommand:'D' withArgumentsPrefix:'d' arguments:[[[self class] converterClass] dataForSettingsDictionary:settings] responsePrefix:'r' expectedLength:1];
    
    //usleep(500000); // Let the device digest this data...
    
    //[_wrapperDevice reset];
        
    [self firmwareVersion];
    
    /*NSData *result = */
    /*
    if (result) {
        ((char *)[result bytes])[0];
    }
    */
}

- (NSArray *)trackpointLogs {
    NSData *result = [_wrapperDevice runCommand:'O' responsePrefix:'2' expectedLength:2];
    if (result) {
        const unsigned char *bytes = [result bytes];
        
        int version = bytes[0];
        int count = bytes[1];
        int ii;
        NSMutableArray *aa = [NSMutableArray array];
        for(ii = 0; ii < count; ii++) {
            NSData *log = [_wrapperDevice readLength:19];
            
            [aa addObject:[[[self class] converterClass] trackpointLogDictionaryForData:log]];
        }
        return aa;
    }
    return nil;
}


                                                   
@end


