//
//  VTVccFile.h
//  Velocitool
//
//  Created by Alec Stewart on 6/16/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTXmlDoc;
@class VTTrackFromDevice;

@interface VTVccFile : NSObject {

	VTXmlDoc *vccFormatXmlDoc;
	
	NSXMLDocument *vccGmtFormatXmlDoc;
	NSXMLDocument *gpxFormatXmlDoc;
	NSXMLDocument *kmlFormatXmlDoc;
	
	
	NSFileWrapper *vccFileWrapper;
	NSFileWrapper *kmlFileWrapper;
	NSFileWrapper *gpxFileWrapper;
	
	NSString *numTrackpoints;
	BOOL fileSaved;	
}

@property(readwrite, retain) NSFileWrapper *vccFileWrapper;
@property(readwrite, retain) NSFileWrapper *kmlFileWrapper;
@property(readwrite, retain) NSFileWrapper *gpxFileWrapper;

@property(readwrite, retain) NSString *numTrackpoints;
@property(readwrite) BOOL fileSaved;	

+ (id)vccFileWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice;
+ (id)vccFileWithURL:(NSURL*)fileLocation;
- (id)initWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice;
- (id)initWithURL:(NSURL*)fileLocation;
- (void)save;
-(void)saveAsGpx;
-(void)saveAsKml;
-(void)launchReplayInGpsar;

@end
