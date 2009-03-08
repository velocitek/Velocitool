
#import "VTCommand.h"
#import "VTGlobals.h"
#import "VTConnection.h"

@interface VTCommand()
- initWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultClass:(Class)resultClass isList:(BOOL)yn;
@end


@implementation VTCommand
// Commands returning a single result
+ commandWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultClass:(Class)resultClass {
    return [[[self alloc] initWithSignal:signalChar parameter:parameter resultClass:resultClass isList:NO] autorelease];
}

// Commands returning a list of results
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


@implementation VTPuckSettingsRecord : VTRecord 

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
