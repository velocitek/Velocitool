//
//  TrackLogViewController.h
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;

extern NSString *VTStartedEstablishingConnectionWithDeviceNotification;
extern NSString *VTTrackLogsFinishedDownloadingNotification;
extern NSString *VTFirstConnectedDeviceRemovedNotification;

extern NSString *VTDownloadButtonPressedNotification;

@interface TrackLogViewController : NSViewController {
	
	IBOutlet NSArrayController *deviceController;
	IBOutlet NSArrayController *trackpointLogController;
	
	IBOutlet NSButton *downloadButton;
		
	NSMutableArray *devices;
	NSMutableArray *trackpointLogs;
	
	VTDevice *firstConnectedDevice;

}

@property(readwrite, retain) NSMutableArray *devices;
@property(readwrite, retain) NSMutableArray *trackpointLogs;
@property(readwrite, retain) VTDevice *firstConnectedDevice;

- (IBAction)downloadDataFromDevice:(id)sender;

- (void)lookForAlreadyConnectedDevices;
- (void)armNotifications;
- (VTDevice *)firstConnectedDevice;
- (void)removeAllDevices;


@end
