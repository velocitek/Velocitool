//
//  VTTrackDownloadOperation.h
//  Velocitool
//
//  Created by Alec Stewart on 6/12/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTTrackFromDevice;
@class VTDevice;

extern NSString *VTTrackFinishedDownloadingNotification;

@interface VTTrackDownloadOperation : NSOperation {
	
	VTTrackFromDevice *trackFromDevice;
	VTDevice *device;
	NSMutableArray *selectedTrackLogs;
	NSMutableArray *trackpoints;
	
}

- (id)initWithTrackObject:(VTTrackFromDevice*)track;


@end
