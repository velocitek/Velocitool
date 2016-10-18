//
//  TrackFileViewController.m
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//


#import "TrackFileViewController.h"


#import "VTGlobals.h"
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


- (IBAction)fileSave:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTSaveButtonSelectedNotification object:self];
	
}

- (IBAction)fileOpen:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTOpenButtonSelectedNotification object:self];
	
}


- (IBAction)fileClose:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTCloseButtonPressedNotification object:self];
	
}

- (IBAction)fileExportGPX:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTExportGPXButtonSelectedNotification object:self];
	
}

- (IBAction)fileExportKML:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTExportKMLButtonSelectedNotification object:self];
	
}


- (IBAction)launchReplay:(id)sender
{
	[currentFile launchReplayInGpsar];
}

- (IBAction)returnToDeviceView:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTCloseButtonPressedNotification object:self];
}

- (id)init {
	
	if((self = [super initWithNibName:@"TrackFileView" bundle:nil])) {
    [self registerForNotifications];
  }
	return self;
	
}



-(void)registerForNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(handleFileSaveSelected:)
			   name:VTSaveButtonSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileOpenSelected:)
			   name:VTOpenButtonSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileCloseSelected:)
			   name:VTCloseButtonPressedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileExportGPXSelected:)
			   name:VTExportGPXButtonSelectedNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(handleFileExportKMLSelected:)
			   name:VTExportKMLButtonSelectedNotification
			 object:nil];		
	
	/*[nc addObserver:self
		   selector:@selector(handleSetupUpdateDeviceFirmwareSelected:)
			   name:VTSetupUpdateDeviceFirmwareSelectedNotification
			 object:nil];
	 */
	
	
	/*[nc addObserver:self
		   selector:@selector(handleHelpTutorialVideoSelected:)
			   name:VTHelpTutorialVideoSelectedNotification
			 object:nil];
	 */
	 
		
}

- (void)handleFileSaveSelected:(NSNotification*)note
{
	
	[currentFile save];
	
}

- (void)handleFileOpenSelected:(NSNotification*)note
{
	
	
}
- (void)handleFileCloseSelected:(NSNotification*)note
{
	
	
}

- (void)handleFileExportGPXSelected:(NSNotification*)note
{
	[currentFile saveAsGpx];
}

- (void)handleFileExportKMLSelected:(NSNotification*)note
{
    [currentFile saveAsKml];
}


- (void)handleSetupUpdateDeviceFirmwareSelected:(NSNotification*)note
{
		
}

- (void)handleHelpTutorialVideoSelected:(NSNotification*)note
{
	
	
}


- (void)downloadTrackFromDevice
{
	[self setTrackFromDevice:[[VTTrackFromDevice alloc] initWithDeviceAndTrackLogs:device trackLogs:trackLogs]];
}

- (void) cancelDownload {
    
}

- (void)initializeCurrentFileFromTrack
{		
		
	[self setCurrentFile:[VTVccFile vccFileWithTrackFromDevice:trackFromDevice]];	
	
}

- (void)initializeCurrentFileFromURL:(NSURL*)url
{

	[self setCurrentFile:[VTVccFile vccFileWithURL:url]];
	 
}

   
@end
