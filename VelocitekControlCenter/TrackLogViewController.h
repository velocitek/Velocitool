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

@interface TrackLogViewController : NSViewController {
	
	
	IBOutlet NSArrayController *deviceController;
	IBOutlet NSArrayController *trackpointLogController;
	
	IBOutlet NSButton *openButton;
	IBOutlet NSButton *downloadButton;
	IBOutlet NSButton *updateFirmwareButton;

	IBOutlet NSButton *deviceSettingsButton;
	IBOutlet NSButton *eraseAllButton;	
	
	IBOutlet NSButton *helpTutorialVideo;
		
	NSMutableArray *devices;
	NSMutableArray *trackpointLogs;
	
	VTDevice *firstConnectedDevice;
	
}

@property (nonatomic, readwrite, strong) NSMutableArray *devices;
@property (nonatomic, readwrite, strong) NSMutableArray *trackpointLogs;
@property (nonatomic, readwrite, strong) VTDevice *firstConnectedDevice;

- (IBAction)fileOpen:(id)sender;
- (IBAction)updateDeviceSettings:(id)sender;
- (IBAction)eraseAll:(id)sender;
- (IBAction)updateFirmware:(id)sender;

/*Not currently implemented
- (IBAction)updateDeviceFirmware:(id)sender;
- (IBAction)helpTutorialVideo:(id)sender;
*/

- (IBAction)downloadDataFromDevice:(id)sender;


- (void)lookForAlreadyConnectedDevices;
- (void)armNotifications;
- (VTDevice *)firstConnectedDevice;
- (void)removeAllDevices;


@end
