//
//  VTVccFile.m
//  Velocitool
//
//  Created by Alec Stewart on 6/16/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#define TEMP_GPX_FILENAME @"temporaryGpxFile.gpx"

#define VELOCITEK_FILES_DIR @"~/Documents/MyVelocitekFiles"

#import "VTVccFile.h"
#import "VTVccXmlDoc.h"
#import "VTVccRootElement.h"
#import "VTCapturedTrackElement.h"
#import "VTTrackFromDevice.h"
#import "VTXmlDate.h"




@interface VTVccFile (private)

- (void)getNumTrackpointsFromXML;

- (void)createVccGmtXmlDoc;
- (void)createGpxXmlDoc;
- (void)createKmlXmlDoc;

- (void)setVccTrackName:(NSString*)trackName;
- (void)setKmlTrackName:(NSString*)trackName;
- (void)setGpxTrackName:(NSString*)trackName;

- (void)convertDownloadedOnTimeToVccGmtFormat;
- (void)convertTrackpointTimestampsToVccGmtFormat;

- (void)fillFileWrapper;
- (void)fillGpxFileWrapper;
- (void)fillKmlFileWrapper;

- (NSString *)convertVccDateStringToVccGmtDateString:(NSString *)vccDateString;
- (NSString *)removeVccExtensionFromFileName:(NSString *)fileNameWithVccExtension;

- (void)setFileWrapperFilenames:(NSString*)fileNameWithoutExtension;

@end


@implementation VTVccFile

@synthesize vccFileWrapper;
@synthesize kmlFileWrapper;
@synthesize gpxFileWrapper;

@synthesize numTrackpoints;
@synthesize fileSaved;	

+ (id)vccFileWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice
{
	VTVccFile *vccFile = [[self alloc] initWithTrackFromDevice:trackFromDevice];
	return vccFile;	
}

+ (id)vccFileWithURL:(NSURL*)fileLocation
{
	VTVccFile *vccFile = [[self alloc] initWithURL:fileLocation];
	return vccFile;	

}

- (id)initWithTrackFromDevice:(VTTrackFromDevice *)trackFromDevice {
  if ((self = [super init])) {
    // use vccXmlDocWithCapturedTrack to set the value of the vccFormatXmlDoc
    // member using the capturedTrackXMLElement member of trackFromDevice
    vccFormatXmlDoc = [VTVccXmlDoc
        vccXmlDocWithCapturedTrack:[trackFromDevice capturedTrackXMLElement]];

    vccFileWrapper = [[NSFileWrapper alloc] init];
    gpxFileWrapper = [[NSFileWrapper alloc] init];
    kmlFileWrapper = [[NSFileWrapper alloc] init];

    [self fillFileWrapper];

    NSString *fileName = [trackFromDevice
        valueForKeyPath:@"capturedTrackXMLElement.defaultTrackName"];

    [self setFileWrapperFilenames:fileName];

    // use getNumTrackpointsFromXML to define the value of numTrackpoints
    [self getNumTrackpointsFromXML];

    // set fileSaved to NO
    [self setFileSaved:NO];
  }
  return self;
}

- (id)initWithURL:(NSURL *)fileLocation {
  if ((self = [super init])) {
    vccFileWrapper =
        [[NSFileWrapper alloc] initWithURL:fileLocation
                                   options:NSFileWrapperReadingImmediate
                                     error:NULL];
    gpxFileWrapper = [[NSFileWrapper alloc] init];
    kmlFileWrapper = [[NSFileWrapper alloc] init];

    NSString *fileNameWithoutExtension =
        [self removeVccExtensionFromFileName:[vccFileWrapper filename]];
    [self setFileWrapperFilenames:fileNameWithoutExtension];

    vccFormatXmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileLocation
                                                           options:0
                                                             error:NULL];
    // TODO: create error if file is corrupt
    [self getNumTrackpointsFromXML];
    [self setFileSaved:YES];
  }
  return self;
}

- (void)dealloc {
    
	 vccFormatXmlDoc = nil;
}

- (void)setFileWrapperFilenames:(NSString*)fileNameWithoutExtension
{
	NSString *fileNameWithVccExtension = [fileNameWithoutExtension stringByAppendingString:@".vcc"];
	NSString *fileNameWithKmlExtension = [fileNameWithoutExtension stringByAppendingString:@".kml"];
	NSString *fileNameWithGpxExtension = [fileNameWithoutExtension stringByAppendingString:@".gpx"];
	
	[vccFileWrapper setPreferredFilename:fileNameWithVccExtension];
	[vccFileWrapper setFilename:[vccFileWrapper preferredFilename]];
	
	[kmlFileWrapper setPreferredFilename:fileNameWithKmlExtension];
	[kmlFileWrapper setFilename:[kmlFileWrapper preferredFilename]];
	
	[gpxFileWrapper setPreferredFilename:fileNameWithGpxExtension];
	[gpxFileWrapper setFilename:[gpxFileWrapper preferredFilename]];
	
}


- (void)save
{

	//create an instance of NSSavePanel called svPanel
	NSSavePanel *svPanel = [NSSavePanel savePanel];
	
    //define an array with one element: the string "vcc" to use as a parameter for savePanel's setAllowedFileTypes method
	NSArray* fileTypes = [NSArray arrayWithObject:@"vcc"];
	
	//call  savePanel's setAllowedFileTypes method
	[svPanel setAllowedFileTypes:fileTypes];
		
	//call setCanCreateDirectories to Yes
	[svPanel setCanCreateDirectories:YES];
	
	[svPanel setNameFieldStringValue:[vccFileWrapper filename]];
    
    [self createMyVelocitekFilesDirIfNeeded];
    
    [svPanel setDirectoryURL:[NSURL URLWithString:[VELOCITEK_FILES_DIR stringByExpandingTildeInPath]]];
		
	//call setDirectoryURL to NSHomeDirectory()
	//[svPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
		
	//call runModal method of save panel to display the panel, record the result of the call
	NSInteger runResult = [svPanel runModal];
	
	//if the user selected the save button
	if(runResult == NSFileHandlingPanelOKButton)
	{
		
		NSString *fileNameWithoutExtension = [svPanel nameFieldStringValue];
		[self setVccTrackName:fileNameWithoutExtension];
		
		NSString *fileName = [fileNameWithoutExtension stringByAppendingString:@".vcc"];		
		[self setValue:fileName forKeyPath:@"vccFileWrapper.filename"];	
		
		//fillVccFileWrapper
		[self fillFileWrapper];
		
		if([vccFileWrapper writeToURL:[svPanel URL] options:NSFileWrapperWritingWithNameUpdating originalContentsURL:nil error:NULL]) {
			
			[self setFileSaved:YES];
			[self setFileWrapperFilenames:fileNameWithoutExtension];
								
		}
		
		else {
			
			NSBeep();
			
		}

				
	}
							
}

- (void) createMyVelocitekFilesDirIfNeeded {
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[VELOCITEK_FILES_DIR stringByExpandingTildeInPath]]) {
        
        NSError * error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[VELOCITEK_FILES_DIR stringByExpandingTildeInPath]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error != nil) {
            NSLog(@"Error creating directory: %@", error);
        }
        
    }

    
}

-(void)saveAsGpx
{
	[self createGpxXmlDoc];	
    
    //create an instance of NSSavePanel called svPanel
	NSSavePanel *svPanel = [NSSavePanel savePanel];
    
    //define an array with one element: the string "gpx" to use as a parameter for savePanel's setAllowedFileTypes method
	NSArray* fileTypes = [NSArray arrayWithObject:@"gpx"];
	
	//call  savePanel's setAllowedFileTypes method
	[svPanel setAllowedFileTypes:fileTypes];
	
	//call setCanCreateDirectories to Yes
	[svPanel setCanCreateDirectories:YES];
	
	[svPanel setNameFieldStringValue:[gpxFileWrapper filename]];
	
    [self createMyVelocitekFilesDirIfNeeded];
    
    [svPanel setDirectoryURL:[NSURL URLWithString:[VELOCITEK_FILES_DIR stringByExpandingTildeInPath]]];

	//call setDirectoryURL to NSHomeDirectory()
	//[svPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
	
	//call runModal method of save panel to display the panel, record the result of the call
	NSInteger runResult = [svPanel runModal];
	
	//if the user selected the save button
	if(runResult == NSFileHandlingPanelOKButton)
	{
		NSString *fileNameWithoutExtension = [svPanel nameFieldStringValue];
		[self setGpxTrackName:fileNameWithoutExtension];
		
		NSString *fileName = [fileNameWithoutExtension stringByAppendingString:@".gpx"];		
		[self setValue:fileName forKeyPath:@"gpxFileWrapper.filename"];	
		
		//fillGpxFileWrapper
		[self fillGpxFileWrapper];
		
		if([gpxFileWrapper writeToURL:[svPanel URL] options:NSFileWrapperWritingWithNameUpdating originalContentsURL:nil error:NULL]) {						
			
			
			
		}
		
		else {
			
			NSBeep();
			
		}
		
		
	}
	
	
}

-(void)saveAsKml
{
	[self createKmlXmlDoc];
	
	//create an instance of NSSavePanel called svPanel
	NSSavePanel *svPanel = [NSSavePanel savePanel];
	
    //define an array with one element: the string "kml" to use as a parameter for savePanel's setAllowedFileTypes method
	NSArray* fileTypes = [NSArray arrayWithObject:@"kml"];
	
	//call  savePanel's setAllowedFileTypes method
	[svPanel setAllowedFileTypes:fileTypes];
	
	//call setCanCreateDirectories to Yes
	[svPanel setCanCreateDirectories:YES];
	
	[svPanel setNameFieldStringValue:[kmlFileWrapper filename]];
    
    [self createMyVelocitekFilesDirIfNeeded];
    
    [svPanel setDirectoryURL:[NSURL URLWithString:[VELOCITEK_FILES_DIR stringByExpandingTildeInPath]]];
	
	
	//call runModal method of save panel to display the panel, record the result of the call
	NSInteger runResult = [svPanel runModal];
	
	//if the user selected the save button
	if(runResult == NSFileHandlingPanelOKButton)
	{
		
		NSString *fileNameWithoutExtension = [svPanel nameFieldStringValue];
		[self setKmlTrackName:fileNameWithoutExtension];
		
		NSString *fileName = [fileNameWithoutExtension stringByAppendingString:@".kml"];		
		[self setValue:fileName forKeyPath:@"kmlFileWrapper.filename"];	
		
		//fillKmlFileWrapper
		[self fillKmlFileWrapper];
		
		if([kmlFileWrapper writeToURL:[svPanel URL] options:NSFileWrapperWritingWithNameUpdating originalContentsURL:nil error:NULL]) {
															
		}
		
		else {
			
			NSBeep();
			
		}
		
		
	}
	
	
}
- (NSString*) stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}
-(void)launchReplayInGpsar
{
    NSLog(@"VTLOG: [VTVccFile, launchReplayInGpsar]");  // VTLOG for debugging
    
    //create gpx format xml representation of the current file	
	[self createGpxXmlDoc];
	
	NSData *xmlData = [gpxFormatXmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *uniqueFileName = [[self stringWithUUID] stringByAppendingFormat:TEMP_GPX_FILENAME];
    NSString *tempGpxFilePath = [NSString pathWithComponents:[NSArray arrayWithObjects:tempDirectory, uniqueFileName, nil]];
     
	if([xmlData writeToFile:tempGpxFilePath atomically:YES])
    {
        NSString *gpsarPath = [[NSBundle mainBundle] pathForResource:@"GPS-Action-Replay" ofType:@"app"];
        NSURL *gpsarUrl = [NSURL fileURLWithPath:gpsarPath];

        //launch the gpx file in GPS Action Replay using NSWorkspace	
		NSArray *arguments = [NSArray arrayWithObjects:tempGpxFilePath,nil];
		
        
		NSDictionary *configuration = [NSDictionary dictionaryWithObjectsAndKeys:
									   arguments, NSWorkspaceLaunchConfigurationArguments, nil];
		
		
		[[NSWorkspace sharedWorkspace] launchApplicationAtURL:gpsarUrl
													  options:NSWorkspaceLaunchDefault | NSWorkspaceLaunchNewInstance
												configuration:configuration 
														error:NULL];
	}
		
}



- (void)createGpxXmlDoc
{
	//createVccGmtDoc
	[self createVccGmtXmlDoc];

	
	//transform vccGmtXmlDoc with TrackpointsToGpx.xslt to create gpxFormatXmlDoc
	
	NSString *trackpointsToGpxPath = [[NSBundle mainBundle] pathForResource:@"TrackpointsToGpx.xslt" 
																	 ofType:@""];
	
	NSURL *xsltFileLocation = [NSURL fileURLWithPath:trackpointsToGpxPath];
	
	NSData *gpxTransformation= [NSData dataWithContentsOfURL:xsltFileLocation];
	
	gpxFormatXmlDoc = [vccGmtFormatXmlDoc objectByApplyingXSLT:gpxTransformation arguments:nil error:NULL];
	
	
}


- (void)createKmlXmlDoc
{
	//transform vccFormatXmlDoc with TrackpointsToKml.xslt to create kmlFormatXmlDoc
	NSString *trackpointsToKmlPath = [[NSBundle mainBundle] pathForResource:@"TrackpointsToKml.xslt" 
																	 ofType:@""];
	
	NSURL *xsltFileLocation = [NSURL fileURLWithPath:trackpointsToKmlPath];
	
	NSData *kmlTransformation= [NSData dataWithContentsOfURL:xsltFileLocation];
	
	kmlFormatXmlDoc = [vccFormatXmlDoc objectByApplyingXSLT:kmlTransformation arguments:nil error:NULL];
}

- (void)createVccGmtXmlDoc
{

	//start out by making vccGmtFormatXmlDoc a copy of vccFormatXmlDoc
	vccGmtFormatXmlDoc = [vccFormatXmlDoc copy];
	
	//convert the downloaded on time to the vccGmt format
	[self convertDownloadedOnTimeToVccGmtFormat];
	
	//convert the trackpoint timestamps to the vccGmt format
	[self convertTrackpointTimestampsToVccGmtFormat];
	
}

- (void)setVccTrackName:(NSString*)trackName
{
	
	//get the root element of vccFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [vccFormatXmlDoc rootElement];
	
	//get the captured track element of the root element using the root element's elementsForName method
	NSArray *elementsArray = [rootElement elementsForName:@"CapturedTrack"];	
	NSXMLElement *capturedTrack = [elementsArray objectAtIndex:0];
	
	//get the captruedTrack element's name attribute as a NSXMLNode object using capturedTrack's attributeForName method
	NSXMLNode *numberTrkptsAttribute = [capturedTrack attributeForName:@"name"];
	
	//set the string value of the name attribute to the desired track name
	[numberTrkptsAttribute setStringValue:trackName];
	
}

- (void)setKmlTrackName:(NSString*)trackName
{		
	
	//get the root element of kmlFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [kmlFormatXmlDoc rootElement];
	
	//get the Placemark element of the root element using the root element's elementsForName method
	NSArray *arrayContainingPlacemarkElement = [rootElement elementsForName:@"Placemark"];	
	NSXMLElement *placemark = [arrayContainingPlacemarkElement objectAtIndex:0];
	
	//get the name element of the Placemark element using the Placemark element's elementsForName method
	NSArray *arrayContainingNameElement = [placemark elementsForName:@"name"];
	NSXMLElement *name = [arrayContainingNameElement objectAtIndex:0];
	
	//set the string value of the name element to the desired track name
	[name setStringValue:trackName];
	
}

- (void)setGpxTrackName:(NSString*)trackName
{	
	
	//get the root element of gpxFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [gpxFormatXmlDoc rootElement];
    
	//get the name element of the root element using the root element's elementsForName method
	NSArray *arrayContainingRootsNameElement = [rootElement elementsForName:@"name"];	
	NSXMLElement *rootsNameElement = [arrayContainingRootsNameElement objectAtIndex:0];
	
	//set the string value of the name element to the desired track name
	[rootsNameElement setStringValue:trackName];
	
	//get the trk element of the root element using the root element's elementsForName method
	NSArray *arrayContainingTrkElement = [rootElement elementsForName:@"trk"];
	NSXMLElement *trk = [arrayContainingTrkElement objectAtIndex:0];
	
	//get the name element of the trk element using the trk element's elementsForName method
	NSArray *arrayContainingTrksNameElement = [trk elementsForName:@"name"];
	NSXMLElement *trksNameElement = [arrayContainingTrksNameElement objectAtIndex:0];
	
	//set the string value of the name element to the desired track name
	[trksNameElement setStringValue:trackName];
	
}


- (void)convertDownloadedOnTimeToVccGmtFormat
{
	
	//get the root element of vccGmtFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [vccGmtFormatXmlDoc rootElement];
	
	//get the captured track element of the root element using the root element's elementsForName method
	NSArray *arrayContainingCapturedTrackElement = [rootElement elementsForName:@"CapturedTrack"];	
	NSXMLElement *capturedTrack = [arrayContainingCapturedTrackElement objectAtIndex:0];
	
	//get the capturedTrack element's downloadedOn attribute as a NSXMLNode object using capturedTrack's attributeForName method
	NSXMLNode *downloadedOn = [capturedTrack attributeForName:@"downloadedOn"];
	    
	//get the downloadedOn date as a string using the stringValue method of the NSXMLNode
	NSString *downloadedOnVccString = [downloadedOn stringValue];
	
	//convert the VCC string to VCC GMT string
	NSString *downloadedOnVccGmtString = [self convertVccDateStringToVccGmtDateString:downloadedOnVccString];
	
	//set the value of the downloadedOn attribute using setStringValue
	[downloadedOn setStringValue:downloadedOnVccGmtString];
	
}

- (void)convertTrackpointTimestampsToVccGmtFormat
{
			
	//get the root element of vccGmtFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [vccGmtFormatXmlDoc rootElement];
	
	//get the captured track element of the root element using the root element's elementsForName method
	NSArray *arrayContainingCapturedTrackElement = [rootElement elementsForName:@"CapturedTrack"];	
	NSXMLElement *capturedTrack = [arrayContainingCapturedTrackElement objectAtIndex:0];
	
	//get the Trackpoints element using the capturedTrack element's elementsForName method
	NSArray *arrayContainingTrackpointsElement = [capturedTrack elementsForName:@"Trackpoints"];	
	NSXMLElement *trackpoints = [arrayContainingTrackpointsElement objectAtIndex:0];
	
	//get an array of Trackpoint element by using the Trackpoints element's elementsForName method
	NSArray *trackpointElements = [trackpoints elementsForName:@"Trackpoint"];
	
	//for each element in the array of Trackpoint elements
	for (NSXMLElement *trackpoint in trackpointElements)
	{
	
		//get the Trackpoint element's dateTime attribute as a NSXMLNode object using the Trackpoint element's attributeForName method
		NSXMLNode *dateTime = [trackpoint attributeForName:@"dateTime"];
		
		//get the dateTime attribute as a string using the stringValue method of the NSXMLNode
		NSString *vccDateString = [dateTime stringValue];
		
		//convert the VCC string to VCC GMT string
		NSString *vccGmtDateString = [self convertVccDateStringToVccGmtDateString:vccDateString];
		
		//set the value of the downloadedOn attribute using setStringValue
		[dateTime setStringValue:vccGmtDateString];
		
	}
	
}

- (void)fillGpxFileWrapper
{
	//serialize the data in gpxFormatXmlDoc using its XMLDataWithOptions method
    NSData *xmlData = [gpxFormatXmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
	
	//use gpxFileWrapper's initWithSerializedRepresentation method to put the data in the file wrapper
	[gpxFileWrapper initRegularFileWithContents:xmlData];
}

- (void)fillKmlFileWrapper
{
	//serialize the data in kmlFormatXmlDoc using its XMLDataWithOptions method
    NSData *xmlData = [kmlFormatXmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
	
	//use kmlFileWrapper's initWithSerializedRepresentation method to put the data in the file wrapper
	[kmlFileWrapper initRegularFileWithContents:xmlData];
	
}

//This method converts a standard VCC-style date string into a
//date expressed in the GMT timezone, without a timezone offset.
//This is done to facilitate the transformation of a VCC file into a GPX file.
//2010-07-20T20:52:42-07:00 becomes 2010-07-21T03:52:42
- (NSString *)convertVccDateStringToVccGmtDateString:(NSString *)vccDateString
{
	//NSLog(@"%@",vccDateString);
	
	//create a VTXmlDate object using xmlDateWithVccDateString
	VTXmlDate *dateToConvert = [VTXmlDate xmlDateWithVccDateString:vccDateString]; 
	
	//return the result of calling the VTXmlDate object's vccGmtDateString method
	return [dateToConvert vccGmtDateString];
	
}


- (void)fillFileWrapper
{
	//serialize the data in vccFormatXmlDoc using its XMLDataWithOptions method
    NSData *xmlData = [vccFormatXmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];	
	
	//use vccFileWrapper's initWithSerializedRepresentation method to put the data in the file wrapper
	[vccFileWrapper initRegularFileWithContents:xmlData];
	
}

// This method parses vccFormatXmlDoc to get the value of the numberTrkpts element of the CapturedTrack element
- (void)getNumTrackpointsFromXML
{
	//get the root element of vccFormatXmlDoc using its rootElement method
	NSXMLElement *rootElement = [vccFormatXmlDoc rootElement];
	
    //get the captured track element of the root element using the root element's elementsForName method
	NSArray *elementsArray = [rootElement elementsForName:@"CapturedTrack"];	
	NSXMLElement *capturedTrack = [elementsArray objectAtIndex:0];
	
    //get the captruedTrack element's numberTrkpts attribute as a NSXMLNode object using capturedTrack's attributeForName method
	NSXMLNode *numberTrkptsAttribute = [capturedTrack attributeForName:@"numberTrkpts"];
	
    //get the number of trackpoints as a string using the stringValue method of the NSXMLNode
	//set numTrackpoints equal to this value
	[self setNumTrackpoints:[numberTrkptsAttribute stringValue]];
	
    	
}

- (NSString *)removeVccExtensionFromFileName:(NSString *)fileNameWithVccExtension
{
	return [fileNameWithVccExtension stringByReplacingOccurrencesOfString:@".vcc" 
															   withString:@""];
}


@end
