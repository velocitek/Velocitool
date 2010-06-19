//
//  VTTrackFromDevice.h
//  Velocitool
//
//  Created by Alec Stewart on 5/27/10.
//  Copyright 2010 Velocitek. All rights reserved.
//




#import <Cocoa/Cocoa.h>
@class VTDevice;
@class VTCapturedTrackElement;

@interface VTTrackFromDevice : NSObject {
	
	VTDevice *device;
	NSMutableArray *selectedTrackLogs;
	NSMutableArray *trackpoints;
	int numTrackpoints;
	VTCapturedTrackElement *capturedTrackXMLElement;
		
	NSOperationQueue *queue;

}

@property(readonly) VTDevice *device;
@property(readonly) NSMutableArray *selectedTrackLogs;
@property(readwrite, retain) NSMutableArray *trackpoints;
@property(readwrite) int numTrackpoints;
@property(readwrite, retain) VTCapturedTrackElement *capturedTrackXMLElement;

- (id)initWithDeviceAndTrackLogs:(VTDevice *)device trackLogs:(NSMutableArray *)trackLogs;

@end
