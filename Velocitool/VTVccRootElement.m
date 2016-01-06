//
//  VTVccRootElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/6/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTVccRootElement.h"
#import "VTCapturedTrackElement.h"
#import "VTXmlDate.h"

@interface VTVccRootElement (private)

- (void)addAttributes;

@end


@implementation VTVccRootElement

- (id)initRootElement
{		
	[super init];
	
	[self initWithKind:NSXMLElementKind];	
	[self setName:@"VelocitekControlCenter"];
	[self addAttributes];
	return self;
}

+ (id)generateVccRootElement
{
	VTVccRootElement *rootElement = [[self alloc] initRootElement];
    
	[rootElement autorelease];
	
    return rootElement;
}	

- (void)addAttributes
{
	//add attribute with name "xmlns:xsi" and value "http://www.w3.org/2001/XMLSchema-instance"
	[self addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	
    //add attribute with name "xmlns:xsd" and value "http://www.w3.org/2001/XMLSchema"
	[self addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
	
    //add attribute with name "createdOn" and the current time represented as an xml string
	[self addAttribute:[NSXMLNode attributeWithName:@"createdOn" stringValue:[VTXmlDate vccNow]]];
	
    //add attribute with name "xmlns" and value "http://www.velocitekspeed.com/VelocitekControlCenter"
	[self addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.velocitekspeed.com/VelocitekControlCenter"]];	
}

@end
