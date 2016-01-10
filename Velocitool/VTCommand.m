

#import "VTCommand.h"
#import "VTRecord.h"
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


// Commands returning a list of results, note the 's' at the end of 'results'.
+ commandWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultsClass:(Class)resultClass {
    return [[[self alloc] initWithSignal:signalChar parameter:parameter resultClass:resultClass isList:YES] autorelease];
}


- initWithSignal:(unsigned char)signalChar parameter:(VTRecord *)parameter resultClass:(Class)resultClass isList:(BOOL)flag {
    if ((self =[super init])) {
      _signal = signalChar;
      _parameter = [parameter retain];
      _resultClass = resultClass;
      _isList = flag;
    }
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
