//
//  TrackFileViewController.h
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VTTrackFromDevice;
@class VTDevice;
@class VTVccFile;


@interface TrackFileViewController : NSViewController {
	VTTrackFromDevice *trackFromDevice;
	VTVccFile *currentFile;
	
	VTDevice *device;
	NSMutableArray *trackLogs;
	
	IBOutlet NSButton *openButton;
	IBOutlet NSButton *saveButton;
	IBOutlet NSMenuItem *fileExportGPX;
	IBOutlet NSMenuItem *fileExportKML;
	
	IBOutlet NSButton *replayButton;
	IBOutlet NSButton *returnToDeviceViewButton;
    IBOutlet NSTextField *unsavedTextField;
    IBOutlet NSProgressIndicator *uploadProgressIndicator;
}

@property (nonatomic, readwrite, strong) NSMutableArray *trackLogs;
@property (nonatomic, readwrite, strong) VTDevice *device;
@property (nonatomic, readwrite, strong) VTTrackFromDevice *trackFromDevice;
@property (nonatomic, readwrite, strong) VTVccFile *currentFile;

- (void)downloadTrackFromDevice;
- (void)initializeCurrentFileFromTrack;
- (void)initializeCurrentFileFromURL:(NSURL*)url;

- (IBAction)launchReplay:(id)sender;
- (IBAction)returnToDeviceView:(id)sender;

- (IBAction)fileSave:(id)sender;
- (IBAction)fileOpen:(id)sender;
- (IBAction)fileExportGPX:(id)sender;
- (IBAction)fileExportKML:(id)sender;

@end
