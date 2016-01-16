//
//  VTTrackpointElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/1/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTTrackpointElement.h"
#import "VTRecord.h"
#import "VTXmlDate.h"

@interface VTTrackpointElement (private) 	


- (void)addAttributes;

- (void)findAttributeStringValues;
- (void)findDateTimeStringValue;

@end


@implementation VTTrackpointElement

@synthesize trackpoint;

+ (id)trackpointElementWithTrackpointRecord:(VTTrackpointRecord*) trackpointRecord
{
	VTTrackpointElement *trackpointElement = [[self alloc] initWithTrackpoint:trackpointRecord];
	[trackpointElement autorelease];
	return trackpointElement;
}

- (id)initWithTrackpoint:(VTTrackpointRecord *)trackpointRecord {
  if ((self = [super initWithKind:NSXMLElementKind])) {
    [self setName:@"Trackpoint"];
    trackpoint = [trackpointRecord retain];
    [self addAttributes];
  }
  return self;
}

- (void)addAttributes
{
	[self findAttributeStringValues];
	
	[self addAttribute:[NSXMLNode attributeWithName:@"dateTime" stringValue:dateString]];
	
	[self addAttribute:[NSXMLNode attributeWithName:@"heading" stringValue:headingString]];
	
	[self addAttribute:[NSXMLNode attributeWithName:@"speed" stringValue:speedString]];
	
	[self addAttribute:[NSXMLNode attributeWithName:@"latitude" stringValue:latString]];
	
	[self addAttribute:[NSXMLNode attributeWithName:@"longitude" stringValue:longString]];
	
}
	 

- (void)findAttributeStringValues
{
	[self findDateTimeStringValue];
	headingString = [[NSString alloc] initWithFormat:@"%.2f", [trackpoint _heading]];
	speedString = [[NSString alloc] initWithFormat:@"%.3f", [trackpoint _speed]];
	latString = [[NSString alloc] initWithFormat:@"%.15f", [trackpoint _latitude]];
	longString = [[NSString alloc] initWithFormat:@"%.14f", [trackpoint _longitude]];
	
}

- (void)findDateTimeStringValue
{

	VTXmlDate *vccDate = [VTXmlDate xmlDateWithDate:[trackpoint _timestamp]];
	
	dateString = [vccDate vccDateString];
}

@end
