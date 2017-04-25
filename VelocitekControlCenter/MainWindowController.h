//
//  MainWindowController.h
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

// State Definitions:
// The currentState property is tied via bindings to the status
// view shown at the bottom of the main window, so the defined
// values of those states is important.

#define READY 0
#define DOWNLOADING_TRACK_LOGS 1
#define TRACK_LOG_VIEW 2
#define DOWNLOADING_TRACK 3
#define FILE_VIEW 4
#define UPLOADING_FIRMWARE 5
#define NO_STATE_CHANGE 6




#import <Cocoa/Cocoa.h>
@class TrackLogViewController;
@class TrackFileViewController;
@class DeviceSettingsController;
@class FirmwareUpdateViewController;

@interface MainWindowController : NSWindowController {
	
	IBOutlet NSBox *box;
	IBOutlet NSButton *viewSwitchButton;
	IBOutlet NSProgressIndicator *trackLogsDownloadingProgressIndicator;
    IBOutlet NSButton *firwareUpdateButton;

    NSOperationQueue * queue;

	unsigned int currentState;
	
	DeviceSettingsController *deviceSettingsController;
	TrackLogViewController *trackLogViewController;	
	TrackFileViewController *trackFileViewController;
    FirmwareUpdateViewController * firmwareUpdateViewController;
    
    NSString * speedPuckFirmwareFilePath;
    NSString * proStartFirmwareFilePath;
	    
}

@property (nonatomic, readwrite) unsigned int currentState;
@property (nonatomic, readonly) TrackLogViewController *trackLogViewController;	
@property (nonatomic, readonly) TrackFileViewController *trackFileViewController;

- (IBAction)switchViews:(id)sender;
- (NSAlert*) getAlertWithMessage:(NSString*)message informativeText:(NSString*) informativeText;

+ (NSURL*) getFileDirectoryFromPrefs;
+ (void) setFileDirectoryInPrefs: (NSURL *) url;
+ (bool) isSetFileDirectoryInPrefs;

@end
