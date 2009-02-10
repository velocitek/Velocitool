
#import <Cocoa/Cocoa.h>

@class VTConnection;
@class VTRecord;
//
// This represent a Velocitek device
//

@interface VTDevice : NSObject {
    NSDictionary *_properties;
    VTConnection *_connection;
}

+ deviceForProperties:(NSDictionary *)properties;
- (NSString *)serial;
- (NSString *)model;
- (NSString *)firmwareVersion;
- (NSDictionary *)deviceSettings;
- (void)setDeviceSettings:(NSDictionary *)settings;

@end
