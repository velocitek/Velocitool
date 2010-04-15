#define MAX_NUM_CHARS_IN_FIRMWARE_FILE 200000

#define LOAD_DEVICE
#define FIRMWARE_UPDATE
//#define FILE_READ
//#define FIRMWARE_VERSION_READ
//#define SERIAL_NUMBER_READ
//#define TRACKPOINT_LOG_READ
//#define TRACKPOINTS_READ

#import <Cocoa/Cocoa.h>
#import "VTDeviceLoader.h"
#import "VTDevice.h"
#import "VTCommand.h"
#import "VTRecord.h"
#import "VTDateTime.h"
#import "VTFloat.h"
#import "VTFirmwareFile.h"


#import <Foundation/Foundation.h>


void testFirmwareFileRead(NSString *fileName);
unsigned char getCharFromDataObject(int charNumber,NSData *dataObject);

void testSerialNumberRead(VTDevice *testDevice);
void testFirmwareVersionRead(VTDevice *testDevice);
void testTrackpointLogRead(VTDevice *testDevice);
void testVTFloatClass(void);

void testTrackpointsRead(VTDevice *testDevice);

void testTrackpointReadCommandParameter(VTDevice *testDevice);

int main (int argc, const char * argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	

	
	
	
#ifdef LOAD_DEVICE
	VTDevice *testDevice;
	
	NSString *testUnitSerialNumber;
	
	//NOTE: Make sure this corresponds to a corrected device.  For a SpeedPuck this will match the number on the sticker
	//inside the battery compartment.  This number is not the same as the number on the sticker inside an SC-1
	testUnitSerialNumber = @"VT000902";
		
	VTDeviceLoader *loader;
	
	loader = [VTDeviceLoader loader];
	
	testDevice = [loader deviceForSerialNumber:testUnitSerialNumber];
#endif
	
	
#ifdef TRACKPOINTS_READ
	testTrackpointsRead(testDevice);
#endif
		
#ifdef SERIAL_NUMBER_READ
	testSerialNumberRead(testDevice);
#endif
	
#ifdef FIRMWARE_VERSION_READ
	testFirmwareVersionRead(testDevice);
#endif
	
#ifdef TRACKPOINT_LOG_READ
	testTrackpointLogRead(testDevice);
#endif

#ifdef FILE_READ
	testFirmwareFileRead(@"/Users/alec/Code/sandbox/speedtrack/Velocitool/fake_firmware.hex");
#endif
	
#ifdef FIRMWARE_UPDATE
	
	//NOTE: Make sure this is the absolute path to where the firmware file is on your machine
	if([testDevice updateFirmware:@"/Users/alec/Code/sandbox/command_line_tool/speedtrack/Velocitool/Velocitek_SpeedPuck_1-4.hex"])
	{
		NSLog(@"Success!");
	
	}
	else 
	{
		NSLog(@"Failure... boo hoo!");
	}

#endif

    
    [pool drain];
    return 0;
}


void testFirmwareFileRead(NSString *filePath)
{
	

	
	VTFirmwareFile *firmwareFile = [VTFirmwareFile vtFirmwareFileWithFilePath:filePath];
	
	NSLog(@"%@", [[firmwareFile firmwareData] description] );
 
	
}



//Reads all the trackpoints stored on the test device
void testTrackpointsRead(VTDevice *testDevice)
{
	
	
	NSDate *beginningOfFirstLog = [NSDate dateWithString:@"2010-03-11 15:04:42 -1000"];
								   
	NSDate *endOfLastLog = [NSDate dateWithString:@"2010-03-11 15:19:38 -1000"];
	
	
	VTReadTrackpointsCommandParameter *testCommandParameter = [VTReadTrackpointsCommandParameter commandParameterFromTimeInverval:beginningOfFirstLog
																															  end:endOfLastLog];
	
	NSLog(@"Test Command Parameter: %@",testCommandParameter);
	
	NSArray *trackpoints = [testDevice trackpoints:beginningOfFirstLog endTime:endOfLastLog];
	
	NSLog(@"Trackpoints: %@",trackpoints);
	
}


void testTrackpointReadCommandParameter(VTDevice *testDevice)
{
	NSArray *arrayOfTrackpointLogs = [testDevice trackpointLogs];
	
	int i = 0;	
	for (VTTrackpointLogRecord *trackpointLog in arrayOfTrackpointLogs)
	{
		
		NSLog(@"\n\nTrackpoint Log Number %d:\n%@\n", i, [trackpointLog description]);
		i++;
		
	}
	
	VTTrackpointLogRecord *firstLog = [arrayOfTrackpointLogs objectAtIndex:0];
	VTTrackpointLogRecord *lastLog = [arrayOfTrackpointLogs objectAtIndex:([arrayOfTrackpointLogs count] - 1)];
	
	NSDate *beginningOfFirstLog = [firstLog _start];
	NSDate *endOfLastLog = [lastLog _end];
	
	VTReadTrackpointsCommandParameter *testCommandParameter = [VTReadTrackpointsCommandParameter commandParameterFromTimeInverval:beginningOfFirstLog
																															  end:endOfLastLog];
	
	NSLog(@"Test Command Parameter: %@",testCommandParameter);
}

void testVTFloatClass(void)
{
	
	float testFloat = -36.5;
	//VTFloat *velocitekFloat = [[VTFloat alloc] init];
	//[velocitekFloat setFloatingPointNumber:testFloat];
	VTFloat *velocitekFloat = [VTFloat vtFloatWithFloat:testFloat];
	
	NSLog(@"velocitekFloat is: %@", velocitekFloat);
	
	
	
	NSData *picRepresentation = [velocitekFloat valueForKey:@"picFloatRepresentation"];
	
	
	NSLog(@"PIC Representation is: %@", picRepresentation);
	
	//VTFloat *floatFromPicData = [[VTFloat alloc] init]; 
	//[floatFromPicData setPicFloatRepresentation:picRepresentation];
	VTFloat *floatFromPicData = [VTFloat vtFloatWithPicBytes:picRepresentation];
	
	NSLog(@"Float Created From Pic Representation is: %@", floatFromPicData);
	
	
	[velocitekFloat setFloatingPointNumber:[floatFromPicData floatingPointNumber]];
	NSLog(@"velocitekFloat is now: %@", velocitekFloat);
	
}



void testVTDateTimeClass(void)
{
	
	NSDate *now = [NSDate date];
	
	VTDateTime *velocitekDate = [VTDateTime vtDateWithDate:now];		
	
	NSLog(@"Velocitek Date is: %@", velocitekDate);
	
	NSData *picRepresentation = [velocitekDate valueForKey:@"picDateRepresentation"];
	
	
	VTDateTime *dateFromPicData = [VTDateTime vtDateWithPicBytes:picRepresentation];
	
	NSLog(@"Date Created From Pic Representation is: %@", dateFromPicData);
	
	
	[velocitekDate setDate:[dateFromPicData date]];
	
	NSLog(@"Velocitek Date is now: %@", velocitekDate);
	
}


void testSerialNumberRead(VTDevice *testDevice)
{
	
	NSLog(@"\n-------------------------------------------\nBeginning Serial Number Reading Test\n");
	
	NSString *testDeviceSerialNumber;
	
	testDeviceSerialNumber = [testDevice serial];
	NSLog(@"Test Unit Serial Number is: %@",testDeviceSerialNumber);
	
	NSLog(@"Finished Serial Number Reading Test\n-------------------------------------------\n");
	
}

void testFirmwareVersionRead(VTDevice *testDevice)
{
	
	NSLog(@"\n-------------------------------------------\nBeginning Firmware Version Reading Test\n");
	
	NSString *testDeviceFirmwareVersion;
	
	testDeviceFirmwareVersion = [testDevice firmwareVersion];	
	NSLog(@"Test Unit Firmware Version is: %@",testDeviceFirmwareVersion);
	
	NSLog(@"Finished Firmware Version Reading Test\n-------------------------------------------\n");
	
}



void testTrackpointLogRead(VTDevice *testDevice)
{
	NSLog(@"\n-------------------------------------------\nBeginning Trackpoint Log Reading Test\n");
	
	int i = 0;
	
	for (VTTrackpointLogRecord *trackpointLog in [testDevice trackpointLogs])
	{
				
		NSLog(@"\n\nTrackpoint Log Number %d:\n%@\n", i, [trackpointLog description]);
		i++;
		
	}
	
	NSLog(@"Finished Trackpoint Log Reading Test\n-------------------------------------------\n");

}






/*
 VTDeviceLoader *loader = [VTDeviceLoader loader];
 
 for (VTDevice *device in [loader devices]) {
 
 NSLog(@"%@ (%@ v.%@)\n%@",
 [device model],
 [device serial],
 [device firmwareVersion],
 [device deviceSettings]
 );
 }
 */
