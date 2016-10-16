it//
//  MainWindowController.m
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "MainWindowController.h"

#import "VTGlobals.h"

#import "TrackLogViewController.h"
#import "TrackFileViewController.h"

#import "VTDevice.h"
#import "VTTrackDownloadOperation.h"

#import "VTAppDelegate.h"
#import "DeviceSettingsController.h"
#import "VTFirmwareUpdateOperation.h"
#import "FirmwareUpdateViewController.h"

//Events processed by state machine
#define EV_ENTRY 0
#define EV_EXIT 1

#define EV_STARTED_ESTABLISHING_CONNECTION 2
#define EV_TRACKLOGS_FINISHED_DOWNLOADING 3
#define EV_DOWNLOAD_BUTTON_PRESSED 4
#define EV_TRACK_FINISHED_DOWNLOADING 5
#define EV_FIRST_DEVICE_REMOVED 6
#define EV_FILE_OPENED 7
#define EV_FILE_CLOSED 8
#define EV_CONNECTION_INTERRUPTED 9
#define EV_ERASE_ALL_CONFIRMED 10
#define EV_UPDATE_FIRMWARE_SELECTED 11
#define EV_UPDATE_FIRMWARE_UPDATE_SUCCESS 12
#define EV_UPDATE_FIRMWARE_UPDATE_FAILURE 13
#define EV_TRACK_DOWNLOAD_CANCELED 14
#define EV_UPDATE_FIRMWARE_UPDATE_CANCELLED 15

#define PROSTART_FIRMWARE_FILE @"Velocitek_ProStart_1-6"
#define SPEEDPUCK_FIRMWARE_FILE @"Velocitek_SpeedPuck_1-51"

@interface MainWindowController (private)

-(void)displayViewController:(NSViewController *)vc;
-(void)openDeviceSettingsPanel;
-(void)registerForNotifications;
-(void)runStateMachine:(unsigned int)currentEvent;
- (NSAlert*) getAlertWithMessage:(NSString*)message informativeText:(NSString*) informativeText;

@end

@implementation MainWindowController

@synthesize currentState;
@synthesize trackLogViewController;
@synthesize trackFileViewController;


- (IBAction)switchViews:(id)sender
{
    
    [self runStateMachine:EV_FILE_CLOSED];
    
}



-(id)init
{
    
    if((self = [super initWithWindowNibName:@"MainWindow"])) {
        
        [self registerForNotifications];
        
        trackLogViewController = [[TrackLogViewController alloc] init];
        trackFileViewController = [[TrackFileViewController alloc] init];
        firmwareUpdateViewController = [[FirmwareUpdateViewController alloc] init];
        
        [self showWindow:nil];
        
        [self setCurrentState:READY];
        [self runStateMachine:EV_ENTRY];
        
        queue = [[NSOperationQueue alloc] init];
        
        proStartFirmwareFilePath = [[NSBundle mainBundle] pathForResource:PROSTART_FIRMWARE_FILE ofType:@"hex"];
        speedPuckFirmwareFilePath = [[NSBundle mainBundle] pathForResource:SPEEDPUCK_FIRMWARE_FILE ofType:@"hex"];

        NSAssert(proStartFirmwareFilePath, @"ProStart firmware file not found with name: %@", PROSTART_FIRMWARE_FILE);
        NSAssert(proStartFirmwareFilePath, @"SpeedPuck firmware file not found with name: %@", SPEEDPUCK_FIRMWARE_FILE);
        
    }
    
    return self;
}

/******************************************************************
    READY STATE
 ******************************************************************/

- (unsigned int) handleStateReady:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;
    
    switch (currentEvent)
    {
            
        case EV_ENTRY:
            
            NSLog(@"VTLOG: READY, EV_ENTRY");  // VTLOG for debugging
            
            [self performSelectorOnMainThread:@selector(displayViewController:) withObject:trackLogViewController waitUntilDone:YES];
            //[self displayViewController:trackLogViewController];
            //NSLog(@"Just changed to READY state.");
            
            //Wait for the main window to resize and check to see if any Velocitek devices are connected to the Mac
            [trackLogViewController performSelector: @selector(lookForAlreadyConnectedDevices) withObject: nil afterDelay: 0.5];
            
            break;
            
            
        case EV_STARTED_ESTABLISHING_CONNECTION:
            
            NSLog(@"VTLOG: READY, EV_STARTED_ESTABLISHING_CONNECTION");  // VTLOG for debugging
            
            nextState = DOWNLOADING_TRACK_LOGS;//Decide what the next state will be
            
            break;
            
        case EV_FILE_OPENED:
            
            NSLog(@"VTLOG: READY, EV_FILE_OPENED");  // VTLOG for debugging
            
            nextState = FILE_VIEW;//Decide what the next state will be
            
            break;
            
        case EV_UPDATE_FIRMWARE_SELECTED:
            
            NSLog(@"VTLOG: READY, EV_UPDATE_FIRMWARE_SELECTED");  // VTLOG for debugging
            
            nextState = UPLOADING_FIRMWARE; //Decide what the next state will be
            
            break;
            
        case EV_EXIT:
            //                NSLog(@"VTLOG: READY, EV_EXIT");  // VTLOG for debugging
            break;
            
    }
    
    return nextState;

}


/******************************************************************
 DOWNLOADING TRACK LOGS STATE
 ******************************************************************/

- (unsigned int) handleStateDownloadingTrackLogs:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;

    switch (currentEvent)
    {
        case EV_ENTRY:
            NSLog(@"VTLOG: DOWNLOADING_TRACK_LOGS, EV_ENTRY");  // VTLOG for debugging
            //NSLog(@"Just changed to DOWNLOADING TRACK LOGS state.");
            NSAssert([NSThread isMainThread], @"Should be on main thread!");
            [trackLogsDownloadingProgressIndicator setUsesThreadedAnimation:YES];
            [trackLogsDownloadingProgressIndicator startAnimation:self];
            break;
            
        case EV_TRACKLOGS_FINISHED_DOWNLOADING:
            NSLog(@"VTLOG: DOWNLOADING_TRACK_LOGS, EV_TRACKLOGS_FINISHED_DOWNLOADING");  // VTLOG for debugging
            nextState = TRACK_LOG_VIEW;//Decide what the next state will be
            break;
            
        case EV_CONNECTION_INTERRUPTED:
            NSLog(@"VTLOG: DOWNLOADING_TRACK_LOGS, EV_CONNECTION_INTERRUPTED");  // VTLOG for debugging
            nextState = READY;//Decide what the next state will be
            break;
            
        case EV_EXIT:
            break;
    }
    
    return nextState;
    
}

/******************************************************************
 TRACK LOG VIEW STATE
 ******************************************************************/

- (unsigned int) handleStateTrackLogView:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;
    
    switch (currentEvent)
    {
        case EV_ENTRY:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_ENTRY");  // VTLOG for debugging
            //NSLog(@"Just changed to TRACK LOG VIEW state.");
            break;
            
        case EV_DOWNLOAD_BUTTON_PRESSED:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_DOWNLOAD_BUTTON_PRESSED");  // VTLOG for debugging
            nextState = DOWNLOADING_TRACK;//Decide what the next state will be
            break;
            
        case EV_FIRST_DEVICE_REMOVED:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_FIRST_DEVICE_REMOVED");  // VTLOG for debugging
            nextState = READY;//Decide what the next state will be
            break;
            
        case EV_ERASE_ALL_CONFIRMED:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_ERASE_ALL_CONFIRMED");  // VTLOG for debugging
            nextState = READY;//Decide what the next state will be
            break;
            
        case EV_FILE_OPENED:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_FILE_OPENED");  // VTLOG for debugging
            nextState = FILE_VIEW;//Decide what the next state will be
            break;
            
        case EV_UPDATE_FIRMWARE_SELECTED:
            NSLog(@"VTLOG: TRACK_LOG_VIEW, EV_UPDATE_FIRMWARE_SELECTED");  // VTLOG for debugging
            nextState = UPLOADING_FIRMWARE;
            
        case EV_EXIT:
            break;
    }
    
    return nextState;
    
}

/******************************************************************
 DOWNLOADING TRACK STATE
 ******************************************************************/

- (unsigned int) handleStateDownloadingTrack:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;
    
    switch (currentEvent)
    {
        case EV_ENTRY:
            NSLog(@"VTLOG: DOWNLOADING_TRACK, EV_ENTRY");  // VTLOG for debugging
            //NSLog(@"Just changed to DOWNLOADING TRACK state.");
            [trackLogViewController setDownloadButtonEnabled:NO];
            [trackFileViewController setDevice:[trackLogViewController firstConnectedDevice]];
            [trackFileViewController setTrackLogs:[trackLogViewController trackpointLogs]];
            [trackFileViewController downloadTrackFromDevice];
            break;
            
            
        case EV_TRACK_FINISHED_DOWNLOADING:
            NSLog(@"VTLOG: DOWNLOADING_TRACK, EV_TRACK_FINISHED_DOWNLOADING");  // VTLOG for debugging
            
            nextState = FILE_VIEW;//Decide what the next state will be

            //Remove the connection with the first connected device
            [trackLogViewController removeAllDevices];
            
            //Initialize the trackFileViewController's currentTrack member using the downloaded track
            [trackFileViewController initializeCurrentFileFromTrack];
            
            [trackLogViewController setDownloadButtonEnabled:YES];

            break;
            
        case EV_CONNECTION_INTERRUPTED:
            NSLog(@"VTLOG: DOWNLOADING_TRACK, EV_CONNECTION_INTERRUPTED");  // VTLOG for debugging
            nextState = READY;//Decide what the next state will be
            [trackLogViewController setDownloadButtonEnabled:YES];
            break;
            
        case EV_EXIT:
            [trackLogViewController setDownloadButtonEnabled:YES];
            break;
            
    }
    
    return nextState;
    
}

/******************************************************************
 FILE VIEW STATE
 ******************************************************************/

- (unsigned int) handleStateFileView:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;
    
    switch (currentEvent)
    {
        case EV_ENTRY:
            NSLog(@"VTLOG: FILE_VIEW, EV_ENTRY");  // VTLOG for debugging
            [self performSelectorOnMainThread:@selector(displayViewController:) withObject:trackFileViewController waitUntilDone:YES];
            //[self displayViewController:trackFileViewController];
            //NSLog(@"Just changed to TRACK FILE VIEW state.");
            break;
            
        case EV_FILE_OPENED:
            NSLog(@"VTLOG: FILE_VIEW, EV_FILE_OPENED");  // VTLOG for debugging
            break;
            
        case EV_FILE_CLOSED:
            NSLog(@"VTLOG: FILE_VIEW, EV_FILE_CLOSED");  // VTLOG for debugging
            nextState = READY;//Decide what the next state will be
            break;
            
        case EV_EXIT:
            [trackFileViewController setCurrentFile:nil];
            break;
    }
    
    return nextState;
    
}

/******************************************************************
 FIRMWARE UPDATE STATE
 ******************************************************************/

- (void) firmwareUpdateSuccessHelper {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert * alert;
        alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Firware update succeeded!"];
        [alert setInformativeText:@"Please disconnect, power off and back on, and reconnect the device to ensure proper function."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
        
        [trackLogViewController setUpdateFirmwareButtonEnabled:true];
        [trackLogViewController setDownloadButtonEnabled:true];
        [trackLogViewController setEraseAllTracksButtonEnabled:true];
    });
}

-(void) firmwareUpdateFailureHelper {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert * alert;
        alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Firware update failed."];
        [alert setInformativeText:@"Please try to update the firmware again."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
        [trackLogViewController setUpdateFirmwareButtonEnabled:true];
        [trackLogViewController setDownloadButtonEnabled:true];
        [trackLogViewController setEraseAllTracksButtonEnabled:true];
    });
    
}

- (unsigned int) handleFirmwareUpdate:(unsigned int) currentEvent {
    
    unsigned int nextState = NO_STATE_CHANGE;
    
    switch (currentEvent)
    {
        case EV_ENTRY:
            NSLog(@"VTLOG: EV_UPDATE_FIRMWARE_SELECTED, EV_ENTRY");  // VTLOG for debugging
            [trackLogViewController setUpdateFirmwareButtonEnabled:NO];
            [trackLogViewController setDownloadButtonEnabled:NO];
            [trackLogViewController setEraseAllTracksButtonEnabled:NO];
            nextState = [self doUpdateFirmware];
            break;
            
        case EV_UPDATE_FIRMWARE_UPDATE_SUCCESS:
            
            NSLog(@"EV_UPDATE_FIRMWARE_UPDATE_SUCCESS");

            [self firmwareUpdateSuccessHelper];
            
            [firmwareUpdateViewController showSuccessTab];

            break;
            
        case EV_UPDATE_FIRMWARE_UPDATE_FAILURE:
            
            NSLog(@"EV_UPDATE_FIRMWARE_UPDATE_FAILURE");
            
            [self firmwareUpdateFailureHelper];

            nextState = READY;
            
            break;
            
        case EV_FIRST_DEVICE_REMOVED:
            
            nextState = READY;
            
            break;
            
        case EV_EXIT:
            
            break;
    }
    
    return nextState;
}


- (unsigned int) doUpdateFirmware
{
    
    VTDevice * dev = [trackLogViewController firstConnectedDevice];
    
    /*
    NSInteger result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"hex"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowedFileTypes:fileTypes];
    
    result = [oPanel runModal];
    
    [oPanel close];
    
    if (result != NSOKButton) {
        return READY;
    }
     
     NSString * firmwareFilePath = [[oPanel URL] path];

    */
    
    NSString * firmwareFilePath;
    
    NSString* model = [dev model];
    
    if ([model isEqualToString:@"SpeedPuck"]) {
        firmwareFilePath = speedPuckFirmwareFilePath;
    }
    else if ([model isEqualToString:@"ProStart"]) {
        firmwareFilePath = proStartFirmwareFilePath;
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Unsupported device model"];
        [alert setInformativeText:[NSString stringWithFormat:@"Device model should be ProStart or SpeedPuck. Your model not recognized: %@", model]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return READY;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Firmware update will erase all previous recorded data on your device.\n\nAre you sure you would like to update the firmware with the following file?"];
    [alert setInformativeText:[firmwareFilePath lastPathComponent]];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertSecondButtonReturn) {
        [trackLogViewController setUpdateFirmwareButtonEnabled:true];
        return READY;
    }
    
    [self performSelectorOnMainThread:@selector(displayViewController:) withObject:firmwareUpdateViewController waitUntilDone:YES];
    [firmwareUpdateViewController showInProgressTab];
    
    NSLog(@"Updating firmware with file at path: %@", firmwareFilePath);
    
    VTFirmwareUpdateOperation * operation = [[VTFirmwareUpdateOperation alloc] initWithDevice:dev path:firmwareFilePath];
    
    [queue addOperation:operation];
    
    return NO_STATE_CHANGE;
}


/******************************************************************
 
 STATE MACHINE MAIN SWITCH
 
    General flow: events are fired, which are caught by handlers
    below. These handlers call the runStateMachine() method with
    a new event. This event is sent to the current state method
    where the event is handled, potentially resulting in a new
    state or in actions that trigger more events.
 
    The currentState property is tied via bindings to the status
    view shown at the bottom of the main window, so the defined
    values of those states is important.
 
 ******************************************************************/


-(void)runStateMachine:(unsigned int)currentEvent
{
   	
    unsigned int nextState;
    
    switch (currentState)
    {
        case READY:
            nextState = [self handleStateReady:currentEvent];
            break;
            
        case DOWNLOADING_TRACK_LOGS:
            nextState = [self handleStateDownloadingTrackLogs:currentEvent];
            break;
            
        case TRACK_LOG_VIEW:
            nextState = [self handleStateTrackLogView:currentEvent];
            break;
            
        case DOWNLOADING_TRACK:
            nextState = [self handleStateDownloadingTrack:currentEvent];
            break;
            
        case FILE_VIEW:
            nextState = [self handleStateFileView:currentEvent];
            break;
            
        case UPLOADING_FIRMWARE:
            nextState = [self handleFirmwareUpdate:currentEvent];
            break;
    }
    
    //   If we are making a state transition
    if (nextState != NO_STATE_CHANGE)
    {
        //   Execute exit functions for old state
        [self runStateMachine:EV_EXIT];
        
        [self setCurrentState:nextState]; //Modify state variable
        
        //   Execute entry functions for new state
        [self runStateMachine:EV_ENTRY];
    }
    
}

-(void)registerForNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(handleDownloadButtonPress:)
               name:VTDownloadButtonPressedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleTrackFinishedDownloading:)
               name:VTTrackFinishedDownloadingNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleStartedEstablishingConnectionWithDevice:)
               name:VTStartedEstablishingConnectionWithDeviceNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleTrackLogsFinishedDownloading:)
               name:VTTrackLogsFinishedDownloadingNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleFirstConnectedDeviceRemoved:)
               name:VTFirstConnectedDeviceRemovedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleFileOpenSelected:)
               name:VTOpenButtonSelectedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleSetupUpdateDeviceSettingsSelected:)
               name:VTUpdateDeviceSettingsButtonSelectedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleReturnToDeviceViewButtonPressed:)
               name:VTCloseButtonPressedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleEraseAllConfirmed:)
               name:VTEraseAllConfirmedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleUpdateFirmwareNotification:)
               name:VTUpdateFirmwareNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleUpdateFirmwareFinishedNotification:)
               name:VTUpdateFirmwareFinishedNotification
             object:nil];
    
}

- (void)handleUpdateFirmwareNotification:(NSNotification *)note {
    [self runStateMachine:EV_UPDATE_FIRMWARE_SELECTED];
}

- (void)handleUpdateFirmwareFinishedNotification:(NSNotification*)note {
    
    bool success = ((VTFirmwareUpdateOperation*)note.object).success;
    
    if (success) {
        [self runStateMachine:EV_UPDATE_FIRMWARE_UPDATE_SUCCESS];
    }
    else {
        [self runStateMachine:EV_UPDATE_FIRMWARE_UPDATE_FAILURE];
    }
}

//Convert notifications into events for the state machine to process
-(void)handleDownloadButtonPress:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", [note name]);
    [self runStateMachine:EV_DOWNLOAD_BUTTON_PRESSED];
    
}

-(void)handleTrackFinishedDownloading:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", [note name]);
    [self runStateMachine:EV_TRACK_FINISHED_DOWNLOADING];
    
}

-(void)handleStartedEstablishingConnectionWithDevice:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", [note name]);
    [self runStateMachine:EV_STARTED_ESTABLISHING_CONNECTION];
    
}

-(void)handleTrackLogsFinishedDownloading:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", [note name]);
    [self runStateMachine:EV_TRACKLOGS_FINISHED_DOWNLOADING];
    
}

-(void)handleFirstConnectedDeviceRemoved:(NSNotification *)note
{
    //NSLog(@"Received notification: %@", [note name]);
    [self runStateMachine:EV_FIRST_DEVICE_REMOVED];
    
}

- (void)handleFileOpenSelected:(NSNotification*)note
{
    
    //NSLog(@"Main window controller received notification: %@", [note name]);
    
    NSInteger result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"vcc"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowedFileTypes:fileTypes];
    
    result = [oPanel runModal];
    
    if (result == NSOKButton) {
        
        [trackFileViewController initializeCurrentFileFromURL:[oPanel URL]];
        [self runStateMachine:EV_FILE_OPENED];
        
    }
    
}

- (void)handleSetupUpdateDeviceSettingsSelected:(NSNotification*)note
{
    [self openDeviceSettingsPanel];
}

- (void)handleReturnToDeviceViewButtonPressed:(NSNotification*)note
{
    [self runStateMachine:EV_FILE_CLOSED];
}

- (void)handleEraseAllConfirmed:(NSNotification*)note
{
    [self runStateMachine:EV_ERASE_ALL_CONFIRMED];
}


-(void)openDeviceSettingsPanel
{
    
    VTDevice *device = [trackLogViewController firstConnectedDevice];
    NSString *firmwareVersion = [device firmwareVersion];
    NSString *model = [device model];
    
    if ([model compare:@"SpeedPuck"] == NSOrderedSame) {
        
        if ([firmwareVersion compare:@"1.3"] == NSOrderedSame) {
            
            deviceSettingsController = [[SpeedPuck1_3DeviceSettingsController alloc] initWithDevice:[trackLogViewController firstConnectedDevice]];
            [deviceSettingsController showWindow:self];
            
        }
        
        else if([firmwareVersion compare:@"1.4"] == NSOrderedSame || [firmwareVersion compare:@"1.5"] == NSOrderedSame) {
            
            deviceSettingsController = [[SpeedPuck1_4DeviceSettingsController alloc] initWithDevice:[trackLogViewController firstConnectedDevice]];
            [deviceSettingsController showWindow:self];
            
        }
        else {
            NSString * message = [NSString stringWithFormat:@"I'm sorry the SpeedPuck is running an unsupported firmware version: %@", firmwareVersion];
            NSAlert * alert = [self getAlertWithMessage:message informativeText:@"Supported versions: 1.3, 1.4, 1.5."];
            [alert runModal];
        }
        
        
    }
    else {
        NSString * message = [NSString stringWithFormat:@"Unrecognized device model: %@", model];
        NSAlert * alert = [self getAlertWithMessage:message informativeText:NULL];
        [alert runModal];
    }
    
}

- (NSAlert*) getAlertWithMessage:(NSString*)message informativeText:(NSString*) informativeText {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    if (informativeText != NULL) [alert setInformativeText:informativeText];
    [alert setAlertStyle:NSWarningAlertStyle];
    return alert;
}


-(void)displayViewController:(NSViewController *)vc
{
    NSAssert([NSThread isMainThread], @"Should be on main thread!");

    //Try to end editing
    NSWindow *w = [box window];
    
    BOOL ended = [w makeFirstResponder:w];
    
    if(!ended) {
        NSBeep();
        return;
    }
    
    NSView *v = [vc view];
    
    //Compute the new window frame
    NSSize currentSize = [[box contentView] frame].size;
    NSSize newSize = [v frame].size;
    float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    
    NSRect windowFrame = [w frame];
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    
    //Clear the box for resizing
    [box setContentView:nil];
    
    [w setFrame:windowFrame
        display:YES
        animate:NO];
    
    //Put the view in the box
    [box setContentView:v];
}

-(void)dealloc
{
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    
}



@end
