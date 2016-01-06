//
//  MainWindowController.h
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

//State Definitions
#define READY 0
#define DOWNLOADING_TRACK_LOGS 1
#define TRACK_LOG_VIEW 2
#define DOWNLOADING_TRACK 3
#define FILE_VIEW 4




#import <Cocoa/Cocoa.h>
@class TrackLogViewController;
@class TrackFileViewController;
@class DeviceSettingsController;


@interface MainWindowController : NSWindowController
{
	IBOutlet NSBox *box;

    IBOutlet NSButton *viewSwitchButton;
	
    IBOutlet NSProgressIndicator *trackLogsDownloadingProgressIndicator;
    
	unsigned int currentState;
	
	DeviceSettingsController *deviceSettingsController;
	
    TrackLogViewController *trackLogViewController;
	
    TrackFileViewController *trackFileViewController;
}

@property (readwrite) unsigned int currentState;

@property (readonly) TrackLogViewController *trackLogViewController;

@property (readonly) TrackFileViewController *trackFileViewController;


- (IBAction)switchViews:(id)sender;


@end
