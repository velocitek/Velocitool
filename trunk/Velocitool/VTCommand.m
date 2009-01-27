//
//  VTCommand.m
//  Velocitool
//
//  Created by Eric Noyau on 08/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VTCommand.h"


@implementation VTCommand

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