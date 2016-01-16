#define MAX_NUM_CHARS_IN_FIRMWARE_FILE 200000

#define ALL_DEVICES
//#define LOAD_DEVICE
//#define TRACKPOINT_SAVE
//#define FIRMWARE_UPDATE
//#define FILE_READ
//#define FIRMWARE_VERSION_READ
//#define SERIAL_NUMBER_READ
//#define TRACKPOINT_LOG_READ
//#define TRACKPOINTS_READ
//#define PROGRESS_TRACKER
//#define DEVICE_SETTINGS
//#define XSLT_TEST
//#define DATE_TEST
//#define LAUNCH_GPSAR_TEST

#import <Cocoa/Cocoa.h>

#import "VTDeviceLoader.h"
#import "VTDevice.h"
#import "VTCommand.h"
#import "VTRecord.h"
#import "VTDateTime.h"
#import "VTFloat.h"
#import "VTFirmwareFile.h"
#import "VTTrackpointElement.h"
#import "VTTrackpointsElement.h"
#import "VTBoundaryElement.h"
#import "VTCapturedTrackElement.h"
#import "VTVccRootElement.h"
#import "VTVccXmlDoc.h"
#import "VTProgressTracker.h"
#import "VTGlobals.h"
#import "VTFirmwareUpdateOperation.h"
#import "VTXmlDate.h"

void testFirmwareUpdate(VTDevice *device);

void testDeviceSettings(VTDevice *device);

void testTrackpointSave(VTDevice *device);

void testFirmwareFileRead(NSString *fileName);
unsigned char getCharFromDataObject(int charNumber,NSData *dataObject);

void testSerialNumberRead(VTDevice *testDevice);
void testFirmwareVersionRead(VTDevice *testDevice);
void testTrackpointLogRead(VTDevice *testDevice);
void testVTFloatClass(void);

void testTrackpointsRead(VTDevice *testDevice);

void testTrackpointReadCommandParameter(VTDevice *testDevice);

void testProgressTracker();

void testDate();

void testXslt();

void testGpsarLaunch();

NSString* createXMLDateString(NSDate *date);
NSString* removeGMTFromDateString(NSString *dateString);


int main (int argc, const char * argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	

	
#ifdef ALL_DEVICES
  VTDeviceLoader *loader = [VTDeviceLoader loader];

  for (VTDevice *device in [loader devices]) {

    NSLog(@"%@ (%@ v.%@)\n%@",
          [device model],
          [device serial],
          [device firmwareVersion],
          [device deviceSettings]
          );
  }
#endif

#ifdef LOAD_DEVICE
	VTDevice *testDevice;
	
	NSString *testUnitSerialNumber;
	
	//NOTE: Make sure this corresponds to a corrected device.  For a SpeedPuck this will match the number on the sticker
	//inside the battery compartment.  This number is not the same as the number on the sticker inside an SC-1
	testUnitSerialNumber = @"VT000632";
		
	VTDeviceLoader *loader;
	
	loader = [VTDeviceLoader loader];
	
	testDevice = [loader deviceForSerialNumber:testUnitSerialNumber];
#endif
	
#ifdef DATE_TEST
	
	testDate();
	
#endif
	
#ifdef TRACKPOINT_SAVE
	testTrackpointSave(testDevice);
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
	
#ifdef DEVICE_SETTINGS
	
	testDeviceSettings(testDevice);
	
#endif

#ifdef FILE_READ
	testFirmwareFileRead(@"/Users/alec/Code/sandbox/speedtrack/Velocitool/fake_firmware.hex");
#endif
	
#ifdef FIRMWARE_UPDATE
	
	testFirmwareUpdate(testDevice);
	
#endif
	
#ifdef PROGRESS_TRACKER
	testProgressTracker();
#endif
	
#ifdef XSLT_TEST
	
	testXslt();
	
#endif
	
#ifdef LAUNCH_GPSAR_TEST
	
	testGpsarLaunch();
	
#endif
	
	

    
    [pool drain];
    return 0;
}

void testGpsarLaunch()
{
	
	

	NSArray *arguments = [NSArray arrayWithObjects:@"-jar", 
						  @"/Users/alec/Desktop/distributionGPSAR/gpsar.jar", 
						  @"/Users/alec/Dropbox/Code/Test VCC File Output/around_the_block_gpx.gpx",
						  nil
						  ];
	
	NSURL *javaUrl = [NSURL fileURLWithPath:@"/usr/bin/java"];
	
	NSDictionary *configuration = [NSDictionary dictionaryWithObjectsAndKeys:
								   arguments, NSWorkspaceLaunchConfigurationArguments, nil];
	
	[[NSWorkspace sharedWorkspace] launchApplicationAtURL:javaUrl
												  options:NSWorkspaceLaunchDefault 
											configuration:configuration 
													error:NULL];
	
	
}

void testDate()
{
	//NSLog(@"hello world");
	
	//NSDate *rightNow = [NSDate date];
	
	//NSLog(@"current date time is: %@",rightNow);
	
	//VTXmlDate *xmlNow;
	
	NSString *now = [VTXmlDate vccNow];
	
	NSLog(@"current date time in vcc format is: %@",now);
	
	VTXmlDate *xmlNow = [VTXmlDate xmlDateWithVccDateString:@"2010-07-20T20:52:42-07:00"];
	

	
	NSString *nowInVccGmtFormat = [xmlNow vccGmtDateString];
	
	NSLog(@"current date time in vcc gmt format is: %@",nowInVccGmtFormat);
	
	
}


void testXslt()
{
	
	//NSURL *xsltFileLocation = [NSURL fileURLWithPath:@"/Users/alec/Dropbox/Code/Velocitool/TrackpointsToKml.xslt"];
	NSURL *gpxXsltFileLocation = [NSURL fileURLWithPath:@"/Users/alec/Dropbox/Code/Velocitool/TrackpointsToGpx.xslt"];
	
	NSURL *vccFileLocation = [NSURL fileURLWithPath:@"/Users/alec/Dropbox/Code/Velocitool/demo_vcc.vcc"];
	
	//NSURL *kmlFileLocation = [NSURL fileURLWithPath:@"/Users/alec/Dropbox/Code/Velocitool/demo_kml.kml"];
	
	NSURL *gpxFileLocation = [NSURL fileURLWithPath:@"/Users/alec/Dropbox/Code/Velocitool/demo_gpx.gpx"];
	
	
	
	NSXMLDocument *vccDoc = [[[NSXMLDocument alloc] initWithContentsOfURL:vccFileLocation options:0 error:NULL] autorelease];
	
	//NSData *kmlTransformation= [NSData dataWithContentsOfURL:xsltFileLocation];
	NSData *gpxTransformation= [NSData dataWithContentsOfURL:gpxXsltFileLocation];
	
	
	
	//NSXMLDocument *kmlDocument = [vccDoc objectByApplyingXSLT:kmlTransformation arguments:nil error:NULL];
	NSXMLDocument *gpxDocument = [vccDoc objectByApplyingXSLT:gpxTransformation arguments:nil error:NULL];
	
	
	
	NSLog(@"%@",gpxDocument);
	
	
	
	
	//NSData *kmlData = [kmlDocument XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSData *gpxData = [gpxDocument XMLDataWithOptions:NSXMLNodePrettyPrint];
	
	
	
	
	//NSFileWrapper *kmlFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:kmlData];
	NSFileWrapper *gpxFileWrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:gpxData] autorelease];
	
	
	
	
	/*[kmlFileWrapper writeToURL:kmlFileLocation
						options:NSFileWrapperWritingWithNameUpdating 
			originalContentsURL:nil 
						  error:NULL];
	 */
	
	
	[gpxFileWrapper writeToURL:gpxFileLocation
					   options:NSFileWrapperWritingWithNameUpdating 
		   originalContentsURL:nil 
						 error:NULL];
	 		
}

void testFirmwareUpdate(VTDevice *device)
{

	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	
	VTFirmwareUpdateOperation *firmwareUpdateOperation = [[[VTFirmwareUpdateOperation alloc] initWithDevice:device] autorelease];
	
	while([firmwareUpdateOperation success] != YES)
	{
		
		[firmwareUpdateOperation setDone:NO];
		
		[queue addOperation:firmwareUpdateOperation];		
		
		while ([firmwareUpdateOperation done] != YES) 
		{
			
		}
	
	}
		
	[firmwareUpdateOperation release];
			
	
}

void testDeviceSettings(VTDevice *device)
{
	NSLog(@"Starting Device Settings Test %@",[device description]);
	
	NSDictionary *deviceSettings = [device deviceSettings];
	
	NSLog(@"%@",[deviceSettings description]);
	
	NSMutableDictionary *mutableSettings = [deviceSettings mutableCopy];
	
	[mutableSettings setObject:[NSNumber numberWithInt:129] forKey:VTDeclinationPref];
	
	NSLog(@"mutableSettings: %@",[mutableSettings description]);
	
	[device setDeviceSettings:(NSDictionary *)mutableSettings]; 
	
	NSDictionary *newDeviceSettings = [device deviceSettings];
	
	
	NSLog(@"%@",[newDeviceSettings description]);
}

void testProgressTracker()
{
	VTProgressTracker* progressTracker = [[[VTProgressTracker alloc] init] autorelease];
	
	[progressTracker setCurrentProgress:0];
	[progressTracker setGoal:500];
	
	int i;
	for(i = 0; i < 500; i++)
	{
		[progressTracker incrementProgress];
		NSLog(@"%@",[progressTracker progressPercentageToDisplay]);
	}
		
}


void testTrackpointSave(VTDevice* device)
{
	
	VTTrackpointRecord *testTrackpoint = [[VTTrackpointRecord alloc] init];
	
	NSDate *timeStamp = [NSDate dateWithString:@"2010-04-27 17:30:50 -1000"];

	[testTrackpoint set_timestamp:timeStamp];
	[testTrackpoint set_latitude:20.917650];
	[testTrackpoint set_longitude:-156.1234567890123456];
	[testTrackpoint set_speed: 2.5];
	[testTrackpoint set_heading:180.0];
	
	VTTrackpointRecord *testTrackpoint2 = [[VTTrackpointRecord alloc] init];
	
	NSDate *timeStamp2 = [NSDate dateWithString:@"2010-04-27 17:30:52 -1000"];
	
	[testTrackpoint2 set_timestamp:timeStamp2];
	[testTrackpoint2 set_latitude:20.1234];
	[testTrackpoint2 set_longitude:-156.54321];
	[testTrackpoint2 set_speed: 2.8];
	[testTrackpoint2 set_heading:175.0];
	
	
	NSMutableArray *trackpoints = [[NSMutableArray alloc] init];
	
	[trackpoints addObject:testTrackpoint];
	[trackpoints addObject:testTrackpoint2];
	
		
	VTCapturedTrackElement *capturedTrackElement = [VTCapturedTrackElement capturedTrackElementWithTrackPointsAndDevice:trackpoints device:device];
	
	//VTVccRootElement *rootElement = [VTVccRootElement generateVccRootElement];
	
	//[rootElement addChild:capturedTrackElement];
	
	//capturedTrackElementWithTrackPointsAndDevice:trackpoints device:device];
	
		
			
	//VTVccXmlDoc *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:rootElement];
	
	VTVccXmlDoc *xmlDoc = [VTVccXmlDoc vccXmlDocWithCapturedTrack:capturedTrackElement];
	
	[xmlDoc saveAsVccFile];
			
}


void testFirmwareFileRead(NSString *filePath)
{
	

	
	VTFirmwareFile *firmwareFile = [VTFirmwareFile vtFirmwareFileWithFilePath:filePath];
	
	NSLog(@"%@", [[firmwareFile firmwareData] description] );
 
	
}



void testTrackpointsRead(VTDevice *testDevice)
{
	
	
	NSDate *beginningOfFirstLog = [NSDate dateWithString:@"2010-06-06 23:01:15 -1000"];
								   
	NSDate *endOfLastLog = [NSDate dateWithString:@"2010-06-06 28:08:57 -1000"];
	
	
	
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
	
	NSDate *beginningOfFirstLog = [firstLog start];
	NSDate *endOfLastLog = [lastLog end];
	
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
