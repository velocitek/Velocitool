#import <Cocoa/Cocoa.h>

@class VTConnection;

// Abstract class for a record to send or receive from a device.
@interface VTRecord : NSObject
// Serialize the record into the connection.
- (void)writeForConnection:(VTConnection *)connection;
// Deserialize the record from the connection.
- (void)readFromConnection:(VTConnection *)connection;

// For subclasses to implement.
- (void)writeDeviceDataForConnection:(VTConnection *)connection;
- (void)readDeviceDataFromConnection:(VTConnection *)connection;
@end

// Represent a position in a path.
@interface VTTrackpointRecord : VTRecord
@property(nonatomic, readwrite, retain) NSDate *timestamp;
@property(nonatomic, readwrite) float latitude;
@property(nonatomic, readwrite) float longitude;
@property(nonatomic, readwrite) float speed;
@property(nonatomic, readwrite) float heading;
@end

// A simple record to encode two dates to retrieve trackpoints.
@interface VTReadTrackpointsCommandParameter : VTRecord
@property(nonatomic, readonly, retain) NSDate *downloadFrom;
@property(nonatomic, readonly, retain) NSDate *downloadTo;

+ (VTReadTrackpointsCommandParameter *)
commandParameterFromDate:(NSDate *)startTime
                  toDate:(NSDate *)endTime;
@end

// Records with the type encoded at the beginning.
@interface VTRecordWithHeader : VTRecord
// For subclassed to implement.
+ (unsigned char)recordHeader;
@end

// An empty record announcing results.
@interface VTCommandResultRecord : VTRecordWithHeader
@end

// Record for the SpeedPuck settings.
@interface VTPuckSettingsRecord : VTRecordWithHeader
@property(nonatomic, readwrite, assign) NSDictionary *settingsDictionary;
+ (VTPuckSettingsRecord *)recordFromSettingsDictionary:(NSDictionary *)settings;
@end

// Used to retrieve the firmware version.
@interface VTFirmwareVersionRecord : VTRecordWithHeader
@property(nonatomic, readonly) NSString *version;
@end

@interface VTTrackpointLogRecord : VTRecordWithHeader
// Used from the UI to select which logs to download. Whatever uses this should
// probably use the logIndex instead.
@property(nonatomic, readwrite) bool selectedForDownload;
@property(nonatomic, readonly) char logIndex;
@property(nonatomic, readonly) NSDate *start;
@property(nonatomic, readonly) NSDate *end;
@property(nonatomic, readonly) int numTrackpoints;
@end
