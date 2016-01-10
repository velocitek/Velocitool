//
//  VTRecord.h
//  Velocitool
//
//  Created by Alec Stewart on 3/29/10.
//  Copyright 2010 Velocitek. All rights reserved.
//
#define NUM_EMPTY_TRACKPOINT_BYTES 9
#import <Cocoa/Cocoa.h>

@class VTConnection;

@interface VTRecord: NSObject {
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection;
- (void)readDeviceDataFromConnection:(VTConnection *)connection;
- (void)writeForConnection:(VTConnection *)connection;
- (void)readFromConnection:(VTConnection *)connection;

@end


@interface VTTrackpointRecord : VTRecord {
    
	
	float _latitude;
	float _longitude;
	float _speed;
	float _heading;
	NSDate *_timestamp;
	
}

@property (nonatomic, readwrite, retain) NSDate *_timestamp;
@property (nonatomic, readwrite) float _latitude;
@property (nonatomic, readwrite) float _longitude;
@property (nonatomic, readwrite) float _speed;
@property (nonatomic, readwrite) float _heading;

@end

@interface VTReadTrackpointsCommandParameter : VTRecord
{
	NSDate *_downloadFrom;
	NSDate *_downloadTo;
}

@property (nonatomic, readwrite, retain) NSDate *_downloadFrom;
@property (nonatomic, readwrite, retain) NSDate *_downloadTo;

+ (VTReadTrackpointsCommandParameter *)commandParameterFromTimeInverval:(NSDate *)startTime end:(NSDate *)endTime;

- (void)writeDeviceDataForConnection:(VTConnection *)connection;

@end

@interface VTRecordWithHeader : VTRecord
{
	
}

+ (unsigned char)recordHeader;
- (void)readFromConnection:(VTConnection *)connection;
- (void)writeForConnection:(VTConnection *)connection;

@end


@interface VTCommandResultRecord: VTRecordWithHeader {
}

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
