//
//  VTCapturedTrackElement.h
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;

@interface VTCapturedTrackElement : NSXMLElement {
	
	NSMutableArray *trackpoints;
	VTDevice *device;
	NSString *defaultTrackName;

}

@property (nonatomic, readwrite, retain) NSString *defaultTrackName;
@property (nonatomic, readwrite, retain) NSMutableArray *trackpoints;
@property (nonatomic, readwrite, retain) VTDevice *device;

+ (id)capturedTrackElementWithTrackPointsAndDevice:(NSMutableArray *)trackpointArray device:(VTDevice *)sourceDevice;
- (id)initWithTrackpointsAndDevice:(NSMutableArray *)trackpointArray device:(VTDevice *)sourceDevice;

@end
