//
//  VTVccXmlDoc.m
//  Velocitool
//
//  Created by Alec Stewart on 6/6/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTVccXmlDoc.h"
#import "VTVccRootElement.h"
#import "VTCapturedTrackElement.h"


@implementation VTVccXmlDoc

- (id)initWithCapturedTrack: (VTCapturedTrackElement*)capturedTrack
{
	[super init];
	
	//create VCC root element
	VTVccRootElement *rootElement = [VTVccRootElement generateVccRootElement];
	
	//add capturedTrack to rootElement as child
	[rootElement addChild:capturedTrack];
	
	//Convert to canonical for compatibility with xslt transformations
	NSString *canonicalFormString = [rootElement canonicalXMLStringPreservingComments:YES];
	    
    //add VCC root element to self as root element
	[self initWithXMLString:canonicalFormString options:NSXMLDocumentTidyXML error:NULL];
	[self setVersion:@"1.0"];
	[self setCharacterEncoding:@"utf-8"];
	
	return self;
	
    
}

+ (id)vccXmlDocWithCapturedTrack: (VTCapturedTrackElement*) capturedTrack
{
	VTVccXmlDoc *xmlDoc = [[[self alloc] initWithCapturedTrack:capturedTrack] autorelease];
	return xmlDoc;
}

- (void)saveAsVccFile
{
	
	NSString *fileName = [NSString stringWithString:@"testVCCFile.vcc"];
	
	NSData *xmlData = [self XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![xmlData writeToFile:fileName atomically:YES]) {
        NSBeep();
        NSLog(@"Could not write document out...");
        
    }
	else{
		 NSLog(@"Saved VCC file");
	}
    

}

@end
