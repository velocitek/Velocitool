//
//  TrackFileViewController.m
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "TrackFileViewController.h"
#import "VTTrackFromDevice.h"
#import "VTVccXmlDoc.h"
#import "VTCapturedTrackElement.h"
#import "VTAppDelegate.h"
#import "VTVccFile.h"



@interface TrackFileViewController (private)

-(void)registerForNotifications;

@end

@implementation TrackFileViewController

@synthesize trackLogs;
@synthesize device;
@synthesize trackFromDevice;
@synthesize currentFile;

- (id)init {
	
	if(![super initWithNibName:@"TrackFileView" bundle:nil])
		return nil;
	
	[self registerForNotifications];
	
	return self;
	
}

-(void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(handleFileSaveSelected:)
			   name:VTFileSaveSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileOpenSelected:)
			   name:VTFileOpenSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileCloseSelected:)
			   name:VTFileCloseSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileExportGPXSelected:)
			   name:VTFileExportGPXSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileExportKMLSelected:)
			   name:VTFileExportKMLSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleSetupUpdateDeviceSettingsSelected:)
			   name:VTSetupUpdateDeviceSettingsSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleSetupEraseAllSelected:)
			   name:VTSetupEraseAllSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleSetupUpdateDeviceFirmwareSelected:)
			   name:VTSetupUpdateDeviceFirmwareSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleHelpTutorialVideoSelected:)
			   name:VTHelpTutorialVideoSelectedNotification
			 object:nil];
		
}

- (void)handleFileSaveSelected:(NSNotification*)note
{
	
	[currentFile save];
	
}

- (void)handleFileOpenSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}
- (void)handleFileCloseSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}

- (void)handleFileExportGPXSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}

- (void)handleFileExportKMLSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}

- (void)handleSetupUpdateDeviceSettingsSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);		
}

- (void)handleSetupEraseAllSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}

- (void)handleSetupUpdateDeviceFirmwareSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}

- (void)handleHelpTutorialVideoSelected:(NSNotification*)note
{
	
	NSLog(@"Received notification: %@", [note name]);	
	
}


- (void)downloadTrackFromDevice
{
	[self setTrackFromDevice:[[VTTrackFromDevice alloc] initWithDeviceAndTrackLogs:device trackLogs:trackLogs]];		
}

- (void)initializeCurrentFileFromTrack
{		
		
	[self setCurrentFile:[VTVccFile vccFileWithTrackFromDevice:trackFromDevice]];	
	
}

- (void)initializeCurrentFileFromURL:(NSURL*)url
{

	[self setCurrentFile:[VTVccFile vccFileWithURL:url]];
	 
}

- (void)dealloc
{
	
	[super dealloc];
}
   
@end
