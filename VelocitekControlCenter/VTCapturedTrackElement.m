//
//  VTCapturedTrackElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTCapturedTrackElement.h"
#import "VTDevice.h"
#import "VTRecord.h"
#import "VTXmlDate.h"
#import "VTDeviceInfoElement.h"
#import "VTBoundaryElement.h"
#import "VTTrackpointsElement.h"

@interface VTCapturedTrackElement (private)

- (void)addAttributes;
- (void)constructDefaultTrackName;
- (void)addChildren;

@end

@implementation VTCapturedTrackElement

@synthesize defaultTrackName;
@synthesize trackpoints;
@synthesize device;

+ (id)capturedTrackElementWithTrackPointsAndDevice:(NSMutableArray *)trackpointArray device:(VTDevice *)sourceDevice
{
	VTCapturedTrackElement *capturedTrackElement = [[self alloc] initWithTrackpointsAndDevice:trackpointArray device:sourceDevice];
	return capturedTrackElement;
	
	
}

- (id)initWithTrackpointsAndDevice:(NSMutableArray *)trackpointArray
                            device:(VTDevice *)sourceDevice {
  if ((self = [super initWithKind:NSXMLElementKind])) {
    [self setName:@"CapturedTrack"];

    [self setTrackpoints:trackpointArray];
    [self setDevice:sourceDevice];

    [self addAttributes];
    [self addChildren];
  }
  return self;
}

- (void)addChildren
{
	
	//use boundaryElement class to create a MinLatitude element	    
    //add the MinLatitude element to self as a child node
	[self addChild:[VTBoundaryElement boundaryElementWithTrackPointArray:trackpoints whichBoundary:MINIMUM whichCoord:LATITUDE]];
	
    //MaxLatitude
    [self addChild:[VTBoundaryElement boundaryElementWithTrackPointArray:trackpoints whichBoundary:MAXIMUM whichCoord:LATITUDE]];
	
	//MinLongitude
	[self addChild:[VTBoundaryElement boundaryElementWithTrackPointArray:trackpoints whichBoundary:MINIMUM whichCoord:LONGITUDE]];
	
    //MaxLongitude
	[self addChild:[VTBoundaryElement boundaryElementWithTrackPointArray:trackpoints whichBoundary:MAXIMUM whichCoord:LONGITUDE]];
	
    //used deviceInfoElement class to create a DeviceInfo element
    //add the DeviceInfo element to self as a child node
	[self addChild:[VTDeviceInfoElement deviceInfoElementWithDevice:device]];
	
	//Trackpoints
	[self addChild:[VTTrackpointsElement trackpointsElementWithTrackpointsArray:trackpoints]];
	
}

- (void)addAttributes
{	
	//add name attribute and set its value equal to defaultTrackName
	[self constructDefaultTrackName];
	[self addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:defaultTrackName]];
	
	//add downloadedOn attribute and set its value equal to the current date as an vccDate string
	[self addAttribute:[NSXMLNode attributeWithName:@"downloadedOn" stringValue:[VTXmlDate vccNow]]];
	
	//add numberTrkpts attribute and set its value equal to the size of the trackpoints array
	NSString *numTrackpoints = [NSString stringWithFormat:@"%lu", (unsigned long)[trackpoints count]];
	[self addAttribute:[NSXMLNode attributeWithName:@"numberTrkpts" stringValue:numTrackpoints]]; 
}

- (void)constructDefaultTrackName
{
	//get the first element of the trackpoints array
	VTTrackpointRecord *firstTrackpoint = [trackpoints objectAtIndex:0];
	
	//get the timestamp from the trackpoint
	NSDate *trackStartTime = firstTrackpoint.timestamp;
	
    
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	//format the string like this example for April 2, 2010, 6:46pm and 55 second: 100427_184655
	[dateFormatter setDateFormat:@"MMMdd_yyyy_hmma"];
	
	[self setDefaultTrackName:[dateFormatter stringFromDate:trackStartTime]];
	
}
@end
