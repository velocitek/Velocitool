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
	NSUInteger numTrackpoints;
	VTCapturedTrackElement *capturedTrackXMLElement;
		
	NSOperationQueue *queue;

}

@property (nonatomic, readonly) VTDevice *device;
@property (nonatomic, readonly) NSMutableArray *selectedTrackLogs;
@property (nonatomic, readwrite, retain) NSMutableArray *trackpoints;
@property (nonatomic, readwrite) NSUInteger numTrackpoints;
@property (nonatomic, readwrite, retain) VTCapturedTrackElement *capturedTrackXMLElement;

- (id)initWithDeviceAndTrackLogs:(VTDevice *)device trackLogs:(NSMutableArray *)trackLogs;

@end
