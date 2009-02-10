
#import "VTCommand.h"
#import "VTGlobals.h"
#import "VTConnection.h"

@interface VTCommand()
- initWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultClass:(Class)resultClass isList:(BOOL)yn;
@end


@implementation VTCommand
+ commandWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultClass:(Class)resultClass {
    return [[[self alloc] initWithSignal:signalChar parameter:parameter resultClass:resultClass isList:NO] autorelease];
}

+ commandWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultsClass:(Class)resultClass {
    return [[[self alloc] initWithSignal:signalChar parameter:parameter resultClass:resultClass isList:YES] autorelease];
}


- initWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultClass:(Class)resultClass isList:(BOOL)flag{
    [super init];
    _signal = signalChar;
    _parameter = [parameter retain];
    _resultClass = resultClass;
    _isList = flag;
    return self;
}

- (void)dealloc {
    [_parameter release]; _parameter = nil;
    [super dealloc];
}

- (BOOL)flowControl {
    return NO;
}

- (unsigned char)signal {
    return _signal;
}

- (VTRecord *)parameter {
    return _parameter;
}

- (Class)resultClass {
    return _resultClass;
}

- (BOOL)returnsList {
    return _isList;
}

@end

@implementation VTRecord : NSObject

+ (unsigned char)recordHeader {
    VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
    return '\0';
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
    VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    VTRaiseAbstractMethodException(self, _cmd, [VTRecord self]);
}

@end


@implementation VTCommandResultRecord: VTRecord

+ (unsigned char)recordHeader {
    return 'r';
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    [connection readUnsignedChar];
}

@end


#define VTRecordRateAll           1
#define VTRecordRateEveryTwo      2
#define VTRecordRateEveryFour     4
#define VTRecordRateEveryEight    8
#define VTRecordRateEverySixteen 16

#define VTSpeedUnitKnots           1
#define VTSpeedUnitMilesHours      2
#define VTSpeedUnitKilometersHours 3
#define VTSpeedUnitMetersSeconds   4

#define VTMaxSpeedInstant  0
#define VTMaxSpeed10Second 1
#define VTMaxSpeedBoth     2

#define VTPuckModeNormal 0
#define VTPuckModeMotor  1
#define VTPuckModeBlank  2

@implementation VTPuckSettingsRecord : VTRecord 

+ (unsigned char)recordHeader {
    return 'd';
}

- init {
    [super init];
    _recordRate = VTRecordRateEveryFour;
    _declinaison = 0;
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
    [record setSettingsDictionary:settings];
    return self;
}

- (void)writeDeviceDataForConnection:(VTConnection *)connection {
    [connection writeUnsignedChar:_recordRate];
    [connection writeChar:_declinaison];
    [connection writeUnsignedChar:_speedUnitOfMeasurement];
    [connection writeUnsignedChar:_speedDamping];
    [connection writeUnsignedChar:_headingDamping];
    [connection writeUnsignedChar:_maxSpeedMode];
    [connection writeBool:_barGraphEnabled];
    [connection writeUnsignedChar:_deviceOperationOption];
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    _recordRate = [connection readUnsignedChar];
    _declinaison = [connection readChar];
    _speedUnitOfMeasurement = [connection readUnsignedChar];
    _speedDamping = [connection readUnsignedChar];
    _headingDamping = [connection readUnsignedChar];
    _maxSpeedMode = [connection readUnsignedChar];
    _barGraphEnabled = [connection readBool];
    _deviceOperationOption = [connection readUnsignedChar];
}

- (NSDictionary *)settingsDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedChar:_recordRate], @"recordRate",
                          [NSNumber numberWithChar:_declinaison], @"declinaison",
                          [NSNumber numberWithUnsignedChar:_speedUnitOfMeasurement],  @"speedUnitOfMeasurement",
                          [NSNumber numberWithUnsignedChar:_speedDamping], @"speedDamping",
                          [NSNumber numberWithUnsignedChar:_headingDamping], @"headingDamping",
                          [NSNumber numberWithUnsignedChar:_maxSpeedMode], @"maxSpeedMode",
                          [NSNumber numberWithBool:_barGraphEnabled], @"barGraphOption",
                          [NSNumber numberWithUnsignedChar:_deviceOperationOption],  @"deviceOperationOption",
                          nil
                          ];
    return dict;
}

- (void)setSettingsDictionary:(NSDictionary *)settings {
    // Extremely dangerous. If a key ios absent this will send the wrong data to the device...
    _recordRate = [[settings objectForKey:@"recordRate"] unsignedCharValue];
    _declinaison = [[settings objectForKey:@"declinaison"] charValue];
    _speedUnitOfMeasurement = [[settings objectForKey:@"speedUnitOfMeasurement"] unsignedCharValue];
    _speedDamping = [[settings objectForKey:@"speedDamping"] unsignedCharValue];
    _headingDamping = [[settings objectForKey:@"headingDamping"] unsignedCharValue];
    _maxSpeedMode = [[settings objectForKey:@"maxSpeedMode"] unsignedCharValue];
    _barGraphEnabled = [[settings objectForKey:@"barGraphOption"] boolValue];
    _deviceOperationOption = [[settings objectForKey:@"deviceOperationOption"] unsignedCharValue];
}

@end


@implementation VTFirmwareVersionRecord

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



@implementation VTTrackpointLogRecord : VTRecord

+ (unsigned char)recordHeader {
    return 'l';
}

- (void)dealloc {
    [super dealloc];
}

- (void)readDeviceDataFromConnection:(VTConnection *)connection {
    _logIndex = [connection readUnsignedChar];
    _trackpointCount = [connection readInt32];
    _start = [connection readDate]; 
    _end = [connection readDate];
}

@end

/*
 
 static  char DeviceSettings = 'd';
 static  char CommandResult = 'r';
 static  char Eeprom = 'e';
 static  char TrackpointLogs = 'l';
 static  char Trackpoint = 't';
 static  char TrackpointCountQuery = 'c';
 static  char UserInformation = 'u';
 static  char FirmwareVersionNo = 'v';
 static  char PowerTest = 'p';
 
 
 static  char PowerTest = 'P';
 static  char ReadFirmwareVersionNo = 'V';
 
 static  char ReadTrackpointLogs = 'O';
 static  char TrackpointCountQuery = 'N';
 static  char ReadTrackpoints = 'T';
 static  char EraseTrackpoints = 'E';
 
 static  char ReadDeviceSettings = 'S';
 static  char WriteDeviceSettings = 'D';
 
 static  char ReadUserInformation = 'I';
 static  char WriteUserInformation = 'U';
 
 static  char ReadEeprom = 'A';
 static  char WriteFirmware = 'L';
 
 static  char UploadTrackpoint = 'R';
 
 // Legacy
 static readonly char LegacyReadTrackpoints = 'G';
 static readonly char LegacyReadUserInformation = 'H';
 
 parameters = X
 
 
 The protocol is fairly simple.
 
 Send the command signal we want to execute and wait for confirmation by the device
 
 commandSignal ->
 <- commandSignal
 
 For commands with arguments send
 
 X ->
 argumentrecord ->
 <- X
 
 Writing Firmware or erasing tracks do not return any results, for other command we get
 
 <- record header
 <- record body
 
 
 For getPower:
 P ->
 <- P
 <- p
 <- power (byte). I'm guessing 0 or 1.
 
 
 So for getVersion I expect:
 
 V ->
 <- V
 <- v
 <- major (byte)
 <- minor (byte)
 <- extension (byte)
 
 For the puck the extension is just yet another number;
 for the SC1 it indicates the firmware used: '0' means full, 1 means basic
 
 
 Get version
 
 setRts(low)
 SetFlowControl(false);
 
 [Command with parameters do call with X
 X             ->
 parameters    ->
 <- X
 ]
 [Results now. Writing Firmware or erasing tracks do not return any results
 <- record header
 <- record body
 ]
 setrts(hight)
 
 
 setRts(low)
 SetFlowControl(false);
 ft_write_bytes(commandSignal);
 while(timeout)
 FT_getstatus
 tx queue
 rx queue
 until txqueue == 0 and rxqueue != 0
 
 StopIfInvalidCommandSignalReponse(commandSignal);
 setrts(hight)
 
 
 */
