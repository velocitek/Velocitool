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
#import "ChartedSailsConnection.h"

@interface TrackFileViewController (private)

-(void)registerForNotifications;

@end

@implementation TrackFileViewController

@synthesize trackLogs;
@synthesize device;
@synthesize trackFromDevice;
@synthesize currentFile;


- (id)init {
	if((self = [super initWithNibName:@"TrackFileView" bundle:nil])) {
       
    }
	return self;
}

- (void) viewDidLoad
{
    self->uploadProgressIndicator.hidden = TRUE;
    self->unsavedTextField.hidden = currentFile.fileSaved;
}


#pragma mark actions

- (IBAction)fileOpen:(id)sender
{
    // Let the main view handle this.
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTOpenButtonSelectedNotification object:self];
}

- (IBAction)fileSave:(id)sender
{
	[currentFile save];
    self->unsavedTextField.hidden = currentFile.fileSaved;
}

- (IBAction)returnToDeviceView:(id)sender
{
    // Let the main view handle this.
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTCloseButtonPressedNotification object:self];
}

- (IBAction)fileExportGPX:(id)sender
{
	[currentFile saveAsGpx];
}

- (IBAction)fileExportKML:(id)sender
{
    [currentFile saveAsKml];
}

- (IBAction)launchReplay:(id)sender
{
    uploadProgressIndicator.hidden = FALSE;
    replayButton.hidden = TRUE;
    
    DDLogDebug(@"Launching ChartedSails replay");
    // If the file has not been saved yet. Ask user to save.
    if (![currentFile fileSaved]) {
        [currentFile save];
        
        if (![currentFile fileSaved])
            return;
    }

    self->unsavedTextField.hidden = currentFile.fileSaved;

    [[ChartedSailsConnection connection] uploadTrack:currentFile.fileURL completionHandler:^void (NSURL * _Nullable redirectURL, NSString * _Nullable errorMessage) {
        if (errorMessage) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"An error occured"];
            [alert setInformativeText:[NSString stringWithFormat:@"Please contact Velocitek support with error message: %@", errorMessage]];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
            self->uploadProgressIndicator.hidden = TRUE;
            self->replayButton.hidden = FALSE;
        }
        else {
            [[NSWorkspace sharedWorkspace] openURL:redirectURL];
            self->uploadProgressIndicator.hidden = TRUE;
            self->replayButton.hidden = FALSE;
        }
    }];
}

#pragma mark internal

- (void)downloadTrackFromDevice
{
	[self setTrackFromDevice:[[VTTrackFromDevice alloc] initWithDeviceAndTrackLogs:device trackLogs:trackLogs]];
}

- (void) cancelDownload {
}

- (void)initializeCurrentFileFromTrack
{
	[self setCurrentFile:[VTVccFile vccFileWithTrackFromDevice:trackFromDevice]];
    self->unsavedTextField.hidden = currentFile.fileSaved;
}

- (void)initializeCurrentFileFromURL:(NSURL*)url
{
	[self setCurrentFile:[VTVccFile vccFileWithURL:url]];
    self->unsavedTextField.hidden = currentFile.fileSaved;
}

   
@end
