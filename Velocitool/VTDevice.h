
#import <Cocoa/Cocoa.h>

@class VTConnection;
@class VTRecord;
@class VTReadTrackpointsCommandParameter;
//
// This represent a Velocitek device
//

@interface VTDevice : NSObject {
    NSDictionary *_properties;
    VTConnection *_connection;
	
}
@property (nonatomic, readwrite, retain) VTConnection *_connection;

+ deviceForProperties:(NSDictionary *)properties;


- (NSString *)serial;
- (NSString *)model;
- (NSString *)firmwareVersion;
- (NSDictionary *)deviceSettings;
- (void)setDeviceSettings:(NSDictionary *)settings;
- (NSArray *)trackpointLogs;
- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo;
- (BOOL)updateFirmware:(NSString *)filePath;
- (void)eraseAll;

@end
