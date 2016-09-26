#import "VTConnection.h"
#import "VTGlobals.h"
#import "VTRecord.h"

@implementation VTRecord : NSObject
- (void)readFromConnection:(VTConnection *)connection {
  [self readDeviceDataFromConnection:connection];
}

- (void)writeForConnection:(VTConnection *)connection {
  [self writeDeviceDataForConnection:connection];
}
- (void)writeDeviceDataForConnection:(VTConnection *)connection {
  VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}
@end

@implementation VTTrackpointRecord : VTRecord

#define NUM_EMPTY_TRACKPOINT_BYTES 9
@synthesize timestamp = _timestamp;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize speed = _speed;
@synthesize heading = _heading;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timestamp = nil;
    }
    return self;
}


- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  self.timestamp = [connection readDate];
  self.latitude = [connection readFloat];
  self.longitude = [connection readFloat];

  // TODO: round speed and heading
  // speed = Convert.ToSingle(Math.Round(reader.ReadSingle(), 3));
  // heading = Convert.ToSingle(Math.Round(reader.ReadSingle(), 2));
  self.speed = [connection readFloat];
  self.heading = [connection readFloat];

  // Padding.
  [connection readLength:NUM_EMPTY_TRACKPOINT_BYTES];
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
  [connection writeDate:self.timestamp];
  [connection writeFloat:self.latitude];
  [connection writeFloat:self.longitude];
  [connection writeFloat:self.speed];
  [connection writeFloat:self.heading];

  // Padding
  for (int i = 0; i < NUM_EMPTY_TRACKPOINT_BYTES; i++) {
    [connection writeUnsignedChar:0];
  }
}

- (NSString *)description {
  NSString *timestamp_description;
  NSString *latitude_description;
  NSString *longitude_description;
  NSString *speed_description;
  NSString *heading_description;

  NSString *description_string;

  timestamp_description =
      [NSString stringWithFormat:@"Timestamp: %@", self.timestamp];

  latitude_description =
      [NSString stringWithFormat:@"Latitude: %f", self.latitude];
  longitude_description =
      [NSString stringWithFormat:@"Longitude: %f", self.longitude];

  speed_description = [NSString stringWithFormat:@"Speed: %f", self.speed];
  heading_description =
      [NSString stringWithFormat:@"Heading: %f", self.heading];

  description_string = [NSString
      stringWithFormat:@"\t%@\n\t%@\n\t%@\n\t%@\n\t%@\n", timestamp_description,
                       latitude_description, longitude_description,
                       speed_description, heading_description];

  return description_string;
}
@end

@implementation VTReadTrackpointsCommandParameter : VTRecord

@synthesize downloadFrom = _downloadFrom;
@synthesize downloadTo = _downloadTo;

+ (VTReadTrackpointsCommandParameter *)
commandParameterFromDate:(NSDate *)startTime
                  toDate:(NSDate *)endTime {
  VTReadTrackpointsCommandParameter *commandParameter =
      [[self alloc] init];

  commandParameter->_downloadFrom = startTime;
  commandParameter->_downloadTo = endTime;
  return commandParameter;
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
  [connection writeDate:self.downloadFrom];
  [connection writeDate:self.downloadTo];
}

- (NSString *)description {
  NSString *fromDescription = [self.downloadFrom description];
  NSString *toDescription = [self.downloadTo description];

  NSString *descriptionString = [NSString
      stringWithFormat:@"\nReadTrackpointsCommandParameter From: %@\nTo: %@",
                       fromDescription, toDescription];
  return descriptionString;
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
    NSLog(@"VTError: Invalid record header received from device.  Received %c, "
          @"expected %c. Aborting.",
          receivedHeaderCharacter, expectedHeaderCharacter);
    [connection recover];
    return;
  }
  [super readFromConnection:connection];
}

- (void)writeForConnection:(VTConnection *)connection {
  unsigned char header = [[self class] recordHeader];

  [connection writeUnsignedChar:header];

  [super writeForConnection:connection];
}
@end

@implementation VTCommandResultRecord : VTRecordWithHeader

+ (unsigned char)recordHeader {
  return 'r';
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  [connection readUnsignedChar];
}

@end

@implementation VTPuckSettingsRecord {
  unsigned char _recordRate;
  unsigned char _declination;
  unsigned char _speedUnitOfMeasurement;
  unsigned char _speedDamping;
  unsigned char _headingDamping;
  unsigned char _maxSpeedMode;
  BOOL _barGraphEnabled;
  unsigned char _deviceOperationOption;
}

+ (unsigned char)recordHeader {
  return 'd';
}

- init {
  if ((self = [super init])) {
    // load some default values
    _recordRate = VTRecordRateEveryFour;
    _declination = 0;
    _speedUnitOfMeasurement = VTSpeedUnitKnots;
    _speedDamping = 1;
    _headingDamping = 1;
    _maxSpeedMode = VTMaxSpeed10Second;
    _barGraphEnabled = YES;
    _deviceOperationOption = VTPuck1_4ModeNormal;
  }
  return self;
}

+ (VTPuckSettingsRecord *)recordFromSettingsDictionary:
    (NSDictionary *)settings {
  VTPuckSettingsRecord *record = [[self alloc] init];
  if (settings) {
    [record setSettingsDictionary:settings];
  }
  return record;
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
  [connection writeUnsignedChar:_recordRate];
  [connection writeUnsignedChar:_declination];
  [connection writeUnsignedChar:_speedUnitOfMeasurement];
  [connection writeUnsignedChar:_speedDamping];
  [connection writeUnsignedChar:_headingDamping];
  [connection writeUnsignedChar:_maxSpeedMode];
  [connection writeBool:_barGraphEnabled];
  [connection writeUnsignedChar:_deviceOperationOption];
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  _recordRate = [connection readUnsignedChar];
  _declination = [connection readUnsignedChar];
  _speedUnitOfMeasurement = [connection readUnsignedChar];
  _speedDamping = [connection readUnsignedChar];
  _headingDamping = [connection readUnsignedChar];
  _maxSpeedMode = [connection readUnsignedChar];
  _barGraphEnabled = [connection readBool];
  _deviceOperationOption = [connection readUnsignedChar];
}

- (NSDictionary *)settingsDictionary {
  NSDictionary *dict = @{
    VTRecordRatePref : @(_recordRate),
    VTDeclinationPref : @(_declination),
    VTSpeedUnitPref : @(_speedUnitOfMeasurement),
    VTSpeedDampingPref : @(_speedDamping),
    VTHeadingDampingPref : @(_headingDamping),
    VTMaxSpeedPref : @(_maxSpeedMode),
    VTBarGraphPref : @(_barGraphEnabled),
    VTPuckModePref : @(_deviceOperationOption)
  };
  return dict;
}

- (void)setSettingsDictionary:(NSDictionary *)settings {
  id value = nil;

  if ((value = [settings objectForKey:VTRecordRatePref])) {
    _recordRate = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTDeclinationPref])) {
    _declination = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTSpeedUnitPref])) {
    _speedUnitOfMeasurement = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTSpeedDampingPref])) {
    _speedDamping = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTHeadingDampingPref])) {
    _headingDamping = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTMaxSpeedPref])) {
    _maxSpeedMode = [value unsignedCharValue];
  }
  if ((value = [settings objectForKey:VTBarGraphPref])) {
    _deviceOperationOption = [value boolValue];
  }
  if ((value = [settings objectForKey:VTPuckModePref])) {
    _deviceOperationOption = [value unsignedCharValue];
  }
}

@end

@implementation VTFirmwareVersionRecord
@synthesize version = _version;

+ (unsigned char)recordHeader {
  return 'v';
}


- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  unsigned char major = [connection readUnsignedChar];
  unsigned char minor = [connection readChar];
  [connection readLength:2];  // Ignore those
  _version = [[NSString alloc] initWithFormat:@"%d.%d", major, minor];
}

- (NSString *)version {
  return _version;
}
@end

@implementation VTTrackpointLogRecord

@synthesize selectedForDownload = _selectedForDownload;
@synthesize logIndex = _logIndex;
@synthesize start = _start;
@synthesize end = _end;
@synthesize numTrackpoints = _numTrackpoints;

+ (unsigned char)recordHeader {
  return 'l';
}


- (void)readDeviceDataFromConnection:(VTConnection *)connection {
  _logIndex = [connection readUnsignedChar];
  _numTrackpoints = [connection readInt32];
  _start = [connection readDate];
  _end = [connection readDate];
}

- (NSString *)description {
  NSString *number_trackpoints_description;
  NSString *beginning_date_time_description;
  NSString *ending_date_time_description;

  NSString *description_string;

  number_trackpoints_description =
      [NSString stringWithFormat:@"Number of trackpoints in log: %d",
                                 self.numTrackpoints];
  beginning_date_time_description =
      [NSString stringWithFormat:@"Log Start: %@", self.start];
  ending_date_time_description =
      [NSString stringWithFormat:@"Log End: %@", self.end];

  description_string = [NSString
      stringWithFormat:@"\t%@\n\t%@\n\t%@\n", number_trackpoints_description,
                       beginning_date_time_description,
                       ending_date_time_description];

  return description_string;
}

@end
