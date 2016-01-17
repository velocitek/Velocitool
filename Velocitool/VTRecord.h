#import <Cocoa/Cocoa.h>

@class VTConnection;

// Abstract class for a record to send or receive from a device.
@interface VTRecord: NSObject
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
@property (nonatomic, readwrite, retain) NSDate *timestamp;
@property (nonatomic, readwrite) float latitude;
@property (nonatomic, readwrite) float longitude;
@property (nonatomic, readwrite) float speed;
@property (nonatomic, readwrite) float heading;
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
@interface VTCommandResultRecord: VTRecordWithHeader
@end


@interface VTPuckSettingsRecord : VTRecordWithHeader {
    unsigned char _recordRate;
    unsigned char _declination;
    unsigned char _speedUnitOfMeasurement;
    unsigned char _speedDamping;
    unsigned char _headingDamping;
    unsigned char _maxSpeedMode;
    BOOL _barGraphEnabled;
    unsigned char _deviceOperationOption;
}

+ (VTPuckSettingsRecord *)recordFromSettingsDictionary:(NSDictionary *)settings;
- (NSDictionary *)settingsDictionary;
- (void)setSettingsDictionary:(NSDictionary *)settings;

@end


@interface VTFirmwareVersionRecord : VTRecordWithHeader {
    NSString *_version;
}

- (NSString *)version;
@end






@interface VTTrackpointLogRecord : VTRecordWithHeader 
{
	
    bool selectedForDownload;
	char logIndex;
    int numTrackpoints;
    NSDate *start; 
    NSDate *end;
}
@property (nonatomic, readwrite) bool selectedForDownload;
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSDate *end;
@property (nonatomic, readonly) int numTrackpoints;

@end
