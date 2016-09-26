//
//  VTVccFile.h
//  Velocitool
//
//  Created by Alec Stewart on 6/16/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTTrackFromDevice;

@interface VTVccFile : NSObject {

	NSXMLDocument *vccFormatXmlDoc;
	
	NSXMLDocument *vccGmtFormatXmlDoc;
	NSXMLDocument *gpxFormatXmlDoc;
	NSXMLDocument *kmlFormatXmlDoc;
	
	
	NSFileWrapper *vccFileWrapper;
	NSFileWrapper *kmlFileWrapper;
	NSFileWrapper *gpxFileWrapper;
	
	NSString *numTrackpoints;
	BOOL fileSaved;	
}

@property (nonatomic, readwrite, strong) NSFileWrapper *vccFileWrapper;
@property (nonatomic, readwrite, strong) NSFileWrapper *kmlFileWrapper;
@property (nonatomic, readwrite, strong) NSFileWrapper *gpxFileWrapper;

@property (nonatomic, readwrite, strong) NSString *numTrackpoints;
@property (nonatomic, readwrite) BOOL fileSaved;	

+ (id)vccFileWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice;
+ (id)vccFileWithURL:(NSURL*)fileLocation;
- (id)initWithTrackFromDevice:(VTTrackFromDevice*)trackFromDevice;
- (id)initWithURL:(NSURL*)fileLocation;
- (void)save;
-(void)saveAsGpx;
-(void)saveAsKml;
-(void)launchReplayInGpsar;

@end
