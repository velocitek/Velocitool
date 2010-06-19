//
//  VTVccFile.m
//  Velocitool
//
//  Created by Alec Stewart on 6/16/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTVccFile.h"
#import "VTVccXmlDoc.h"
#import "VTVccRootElement.h"
#import "VTCapturedTrackElement.h"
#import "VTTrackFromDevice.h"


@interface VTVccFile (private)

- (void)fillFileWrapper;
- (void)getNumTrackpointsFromXML;

@end

@implementation VTVccFile

@synthesize vccFileWrapper;
@synthesize numTrackpoints;
@synthesize fileSaved;	

+ (id)vccFileWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice
{
	VTVccFile *vccFile = [[self alloc] initWithTrackFromDevice:trackFromDevice];
	[vccFile autorelease];
	return vccFile;	
}

+ (id)vccFileWithURL:(NSURL*)fileLocation
{
	VTVccFile *vccFile = [[self alloc] initWithURL:fileLocation];
	[vccFile autorelease];
	return vccFile;	

}

- (id)initWithTrackFromDevice:(VTTrackFromDevice *)trackFromDevice
{
	//use vccXmlDocWithCapturedTrack to set the value of the xmlRepresentation member using the capturedTrackXMLElement member of trackFromDevice    
    xmlRepresentation = [VTVccXmlDoc vccXmlDocWithCapturedTrack:[trackFromDevice capturedTrackXMLElement]];
	
	//call fillFileWrapper
	[self fillFileWrapper];
	
	NSString* fileName = [trackFromDevice valueForKeyPath:@"capturedTrackXMLElement.defaultTrackName"];
	fileName = [fileName stringByAppendingString:@".vcc"];
	
	[vccFileWrapper setPreferredFilename:fileName];
	[vccFileWrapper setFilename:[vccFileWrapper preferredFilename]];
	
    //use getNumTrackpointsFromXML to define the value of numTrackpoints
	[self getNumTrackpointsFromXML];
	
    //set fileSaved to NO
	[self setFileSaved:NO];
	
	return self;
		
}


- (id)initWithURL:(NSURL*)fileLocation
{
	vccFileWrapper = [[NSFileWrapper alloc] initWithURL:fileLocation options:NSFileWrapperReadingImmediate error:NULL];
	
	xmlRepresentation = [[NSXMLDocument alloc] initWithContentsOfURL:fileLocation options:0 error:NULL];
	//TODO: create error if file is corrupt
	
	[self getNumTrackpointsFromXML];
	
	[self setFileSaved:YES];
	
	return self;	
	
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
		
	//call setDirectoryURL to NSHomeDirectory()
	//[svPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
		
	//call runModal method of save panel to display the panel, record the result of the call
	NSInteger runResult = [svPanel runModal];
		
	//if the user selected the save button
	if(runResult == NSFileHandlingPanelOKButton)
	{
		
		if([vccFileWrapper writeToURL:[svPanel URL] options:NSFileWrapperWritingWithNameUpdating originalContentsURL:nil error:NULL]) {
			
			[self setFileSaved:YES];
			
			NSString *fileName = [svPanel nameFieldStringValue];
			fileName = [fileName stringByAppendingString:@".vcc"];
			
			[self setValue:fileName forKeyPath:@"vccFileWrapper.filename"];
		
		}
		
		else {
			
			NSBeep();
			
		}

				
	}
	
	
					
}

- (void)fillFileWrapper
{
	//serialize the data in xmlRepresentation using its XMLDataWithOptions method
    NSData *xmlData = [xmlRepresentation XMLDataWithOptions:NSXMLNodePrettyPrint];
	
	vccFileWrapper = [NSFileWrapper alloc];
	
	//use vccFileWrapper's initWithSerializedRepresentation method to put the data in the file wrapper
	[vccFileWrapper initRegularFileWithContents:xmlData];
	
}

// This method parses xmlRepresentation to get the value of the numberTrkpts element of the CapturedTrack element
- (void)getNumTrackpointsFromXML
{
	//get the root element of xmlRepresentation using its rootElement method
	NSXMLElement *rootElement = [xmlRepresentation rootElement];
	
    //get the captured track element of the root element using the root element's elementsForName method
	NSArray *elementsArray = [rootElement elementsForName:@"CapturedTrack"];	
	NSXMLElement *capturedTrack = [elementsArray objectAtIndex:0];
	
    //get the captruedTrack element's numberTrkpts attribute as a NSXMLNode object using capturedTrack's attributeForName method
	NSXMLNode *numberTrkptsAttribute = [capturedTrack attributeForName:@"numberTrkpts"];
	
    //get the number of trackpoints as a string using the stringValue method of the NSXMLNode
	//set numTrackpoints equal to this value
	[self setNumTrackpoints:[numberTrkptsAttribute stringValue]];
	
    	
}


@end
