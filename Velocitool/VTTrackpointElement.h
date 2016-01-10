//
//  VTTrackpointElement.h
//  Velocitool
//
//  Created by Alec Stewart on 6/1/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTTrackpointRecord;

/*
 
 Members:
 - trackpointXMLElement
 - trackpoint
 
 Methods (Public):
 - initWithTrackpoint
 - trackpointElementWithTrackpoint
 
 Methods (Private):
 - addAttributesToTrackpointElement
 - setAttributeValues
 - createDateTimeAttributeValue 
 */


@interface VTTrackpointElement : NSXMLElement {
	
	//NSXMLElement *trackpointXMLElement;
	
	VTTrackpointRecord *trackpoint;
	
	NSString *dateString;
	NSString *headingString;
	NSString *speedString;
	NSString *latString;
	NSString *longString;
	
}

@property (nonatomic, readonly) VTTrackpointRecord *trackpoint;

+ (id)trackpointElementWithTrackpointRecord:(VTTrackpointRecord*) trackpointRecord;

- (id)initWithTrackpoint: (VTTrackpointRecord*) trackpointRecord;


@end
