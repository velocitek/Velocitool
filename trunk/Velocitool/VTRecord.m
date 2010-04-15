//
//  VTRecord.m
//  Velocitool
//
//  Created by Alec Stewart on 3/29/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTRecord.h"
#import "VTConnection.h"
#import "VTGlobals.h"

@implementation VTRecord : NSObject


- (void)writeDeviceDataForConnection:(VTConnection *)connection {
    VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}


- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}

- (void)readFromConnection:(VTConnection *)connection {
    
	[self readDeviceDataFromConnection:connection];
}

- (void)writeForConnection:(VTConnection *)connection {
	
	[self writeDeviceDataForConnection:connection];
	
}

@end

@implementation VTTrackpointRecord : VTRecord


- (void)dealloc {
	[super dealloc];
}

- (NSString *)description
{
	NSString *timestamp_description;
	NSString *latitude_description;
	NSString *longitude_description;
	NSString *speed_description;
	NSString *heading_description;
	
	NSString *description_string;
	
	timestamp_description = [[NSString alloc] initWithFormat:@"Timestamp: %@", _timestamp];
	
	latitude_description = [[NSString alloc] initWithFormat:@"Latitude: %f", _latitude];
	longitude_description = [[NSString alloc] initWithFormat:@"Longitude: %f", _longitude];
	
	speed_description = [[NSString alloc] initWithFormat:@"Speed: %f", _speed];
	heading_description = [[NSString alloc] initWithFormat:@"Heading: %f", _heading];
	
	
	description_string = [[NSString alloc] initWithFormat:@"\t%@\n\t%@\n\t%@\n\t%@\n\t%@\n", 
						  timestamp_description, latitude_description, longitude_description, 
						  speed_description, heading_description]; 
	
	return description_string;
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection 
{							
	_timestamp = [connection readDate];
	_latitude = [connection readFloat];
	_longitude = [connection readFloat];
	//TODO: round speed and heading
	// speed = Convert.ToSingle(Math.Round(reader.ReadSingle(), 3));
	// heading = Convert.ToSingle(Math.Round(reader.ReadSingle(), 2));
	
	_speed = [connection readFloat];
	
	_heading = [connection readFloat];		
	
	[connection readLength:NUM_EMPTY_TRACKPOINT_BYTES];
	
	
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
	
	[connection writeDate:_timestamp];
	[connection writeFloat:_latitude];
	[connection writeFloat:_longitude];
	[connection writeFloat:_speed];
	[connection writeFloat:_heading];
	
	int i;
	for(i = 0; i < NUM_EMPTY_TRACKPOINT_BYTES; i++)
	{
		[connection writeUnsignedChar:0];
	}
	
}

@end

@implementation VTReadTrackpointsCommandParameter : VTRecord

@synthesize _downloadFrom;
@synthesize _downloadTo;

+ (VTReadTrackpointsCommandParameter *)commandParameterFromTimeInverval:(NSDate *)startTime end:(NSDate *)endTime {
	
	VTReadTrackpointsCommandParameter *commandParameter = [[self alloc] init];
	
	[commandParameter set_downloadFrom:startTime];
	
	[commandParameter set_downloadTo:endTime];
	
	return commandParameter;
	
}

- (NSString *)description {
	
	NSString *fromDescription = [_downloadFrom description];
	NSString *toDescription = [_downloadTo description];
	
	NSString *descriptionString = [NSString stringWithFormat:@"\nReadTrackpointsCommandParameter From: %@\nTo: %@",fromDescription,toDescription];
	
	return descriptionString; 
}



- (void)writeDeviceDataForConnection:(VTConnection *)connection {
	
	[connection writeDate:_downloadFrom];
	[connection writeDate:_downloadTo];
	
}

@end

@implementation VTRecordWithHeader : VTRecord

+ (unsigned char)recordHeader {
    
	VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
    
	return '\0';
}

- (void)readFromConnection:(VTConnection *)connection {
    
	
	unsigned char expectedHeaderCharacter = [[self class] recordHeader];
	unsigned char receivedHeaderCharacter = [connection readUnsignedChar];
	
	if (receivedHeaderCharacter != expectedHeaderCharacter) {
		NSLog(@"VTError: Invalid record header received from device.  Received %c, expected %c. Aborting.", 
			  receivedHeaderCharacter, expectedHeaderCharacter);
		[connection recover];
		return;
	}	
		
	[self readDeviceDataFromConnection:connection];
}

- (void)writeForConnection:(VTConnection *)connection {
	
	unsigned char header = [[self class] recordHeader];
	
	[connection writeUnsignedChar:header];
		
	//Next, write the data
	[self writeDeviceDataForConnection:connection];
	
}


@end


@implementation VTCommandResultRecord: VTRecordWithHeader

+ (unsigned char)recordHeader {
    return 'r';
}


- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    [connection readUnsignedChar];
}

@end


@implementation VTPuckSettingsRecord : VTRecordWithHeader 

+ (unsigned char)recordHeader {
    return 'd';
}


- init {
    [super init];
    
    // load some default values
    _recordRate = VTRecordRateEveryFour;
    _declination = 0;
    _speedUnitOfMeasurement = VTSpeedUnitKnots;
    _speedDamping = 1;
    _headingDamping = 1;
    _maxSpeedMode = VTMaxSpeed10Second;
    _barGraphEnabled = YES;
    _deviceOperationOption = VTPuckModeNormal;
    return self;
}


+ (VTPuckSettingsRecord *)recordFromSettingsDictionary:(NSDictionary *)settings {
    VTPuckSettingsRecord *record = [[self alloc] init];
    if(settings) {
        [record setSettingsDictionary:settings];
    }
    return record;
}


- (void)writeDeviceDataForConnection:(VTConnection *)connection {
    [connection writeUnsignedChar:_recordRate];
    [connection writeChar:_declination];
    [connection writeUnsignedChar:_speedUnitOfMeasurement];
    [connection writeUnsignedChar:_speedDamping];
    [connection writeUnsignedChar:_headingDamping];
    [connection writeUnsignedChar:_maxSpeedMode];
    [connection writeBool:_barGraphEnabled];
    [connection writeUnsignedChar:_deviceOperationOption];
}




- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    _recordRate = [connection readUnsignedChar];
    _declination = [connection readChar];
    _speedUnitOfMeasurement = [connection readUnsignedChar];
    _speedDamping = [connection readUnsignedChar];
    _headingDamping = [connection readUnsignedChar];
    _maxSpeedMode = [connection readUnsignedChar];
    _barGraphEnabled = [connection readBool];
    _deviceOperationOption = [connection readUnsignedChar];
}


- (NSDictionary *)settingsDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedChar:_recordRate], VTRecordRatePref,
                          [NSNumber numberWithChar:_declination], VTDeclinationPref,
                          [NSNumber numberWithUnsignedChar:_speedUnitOfMeasurement], VTSpeedUnitPref,
                          [NSNumber numberWithUnsignedChar:_speedDamping], VTSpeedDampingPref,
                          [NSNumber numberWithUnsignedChar:_headingDamping], VTHeadingDampingPref,
                          [NSNumber numberWithUnsignedChar:_maxSpeedMode], VTMaxSpeedPref,
                          [NSNumber numberWithBool:_barGraphEnabled], VTBarGraphEnabled,
                          [NSNumber numberWithUnsignedChar:_deviceOperationOption],  VTPuckModePref,
                          nil
                          ];
    return dict;
}


- (void)setSettingsDictionary:(NSDictionary *)settings {
    id value = nil;
    
    if( (value = [settings objectForKey:VTRecordRatePref]) ) {
        _recordRate = [value unsignedCharValue];
    }
    if( (value = [settings objectForKey:VTDeclinationPref]) ) {
        _declination = [value charValue];
    }
    if( (value = [settings objectForKey:VTSpeedUnitPref]) ) {
        _speedUnitOfMeasurement = [value unsignedCharValue];
    }
    if( (value = [settings objectForKey:VTSpeedDampingPref]) ) {
        _speedDamping = [value unsignedCharValue];
    }
    if( (value = [settings objectForKey:VTHeadingDampingPref]) ) {
        _headingDamping = [value unsignedCharValue];
    }
    if( (value = [settings objectForKey:VTMaxSpeedPref]) ) {
        _maxSpeedMode = [value unsignedCharValue];
    }
    if( (value = [settings objectForKey:VTBarGraphEnabled]) ) {
        _deviceOperationOption = [value boolValue];
    }
    if( (value = [settings objectForKey:VTPuckModePref]) ) {
        _deviceOperationOption = [value unsignedCharValue];
    }
}

@end


@implementation VTFirmwareVersionRecord : VTRecordWithHeader 

+ (unsigned char)recordHeader {
    return 'v';
}

- (void)dealloc {
    [_version release]; _version = nil;
    [super dealloc];
}



- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    unsigned char major = [connection readUnsignedChar];
    unsigned char minor = [connection readChar];
    [connection readLength:2]; // Ignore those
    _version = [[NSString alloc] initWithFormat:@"%d.%d", major, minor];
}

- (NSString *)version {
    return _version;
}

@end



@implementation VTTrackpointLogRecord : VTRecordWithHeader

@synthesize _start;
@synthesize _end;

+ (unsigned char)recordHeader {
    return 'l';
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)description
{
	NSString *number_trackpoints_description;
	NSString *beginning_date_time_description;
	NSString *ending_date_time_description;
	
	NSString *description_string;
	
	number_trackpoints_description = [[NSString alloc] initWithFormat:@"Number of trackpoints in log: %d", _trackpointCount];
	beginning_date_time_description = [[NSString alloc] initWithFormat:@"Log Start: %@", _start];
	ending_date_time_description = [[NSString alloc] initWithFormat:@"Log End: %@", _end];
	
	description_string = [[NSString alloc] initWithFormat:@"\t%@\n\t%@\n\t%@\n", number_trackpoints_description, beginning_date_time_description, ending_date_time_description]; 
	
	return description_string;
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    _logIndex = [connection readUnsignedChar];
    _trackpointCount = [connection readInt32];
    _start = [connection readDate]; 
    _end = [connection readDate];
}

@end
