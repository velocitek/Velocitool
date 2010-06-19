//
//  MainWindowController.m
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "MainWindowController.h"
#import "TrackLogViewController.h"
#import "TrackFileViewController.h"

#import "VTDevice.h"
#import "VTTrackDownloadOperation.h"

#import "VTAppDelegate.h"

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

@interface MainWindowController (private)

-(void)displayViewController:(NSViewController *)vc;
-(void)registerForNotifications;
-(void)runStateMachine:(unsigned int)currentEvent;


@end



@implementation MainWindowController



@synthesize currentState;
@synthesize trackLogViewController;	
@synthesize trackFileViewController;


- (IBAction)switchViews:(id)sender
{
	NSLog(@"switchViews button pressed");
	[self runStateMachine:EV_FILE_CLOSED];	
	
}



-(id)init
{
	
	if(![super initWithWindowNibName:@"MainWindow"])
		return nil;
	
	[self registerForNotifications];
	
	trackLogViewController = [[TrackLogViewController alloc] init];			
	trackFileViewController = [[TrackFileViewController alloc] init];
	
	[self showWindow:nil];
		
	[self setCurrentState:READY];
	[self runStateMachine:EV_ENTRY];
		
	return self;
}



-(void)runStateMachine:(unsigned int)currentEvent
{
   	
	BOOL makeTransition = NO;/* are we making a state transition? */
	unsigned int nextState;	
	
	nextState = currentState;
	
	switch (currentState)
	{
			
		case READY:
			
			switch (currentEvent)
		{
				
			case EV_ENTRY:
				
				[self displayViewController:trackLogViewController];								
				NSLog(@"Just changed to READY state.");
				
				//Wait for the main window to resize and check to see if any Velocitek devices are connected to the Mac			
				[trackLogViewController performSelector: @selector(lookForAlreadyConnectedDevices) withObject: nil afterDelay: 0.25];					
				
				break;
				
				
			case EV_STARTED_ESTABLISHING_CONNECTION:
				
				nextState = DOWNLOADING_TRACK_LOGS;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				break;
				
			case EV_FILE_OPENED:
				
				nextState = FILE_VIEW;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				break;
				
			case EV_EXIT:
				
				break;
				
		}         
			break;
			
			
		case DOWNLOADING_TRACK_LOGS:
			
			switch (currentEvent)
		{
			case EV_ENTRY:
				
				NSLog(@"Just changed to DOWNLOADING TRACK LOGS state.");
				
				[trackLogsDownloadingProgressIndicator setUsesThreadedAnimation:YES];
				[trackLogsDownloadingProgressIndicator startAnimation:self];
				
				break; 
				
			case EV_TRACKLOGS_FINISHED_DOWNLOADING:
				
				nextState = TRACK_LOG_VIEW;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				break;
				
			case EV_CONNECTION_INTERRUPTED:
				
				nextState = READY;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				break;
				
			case EV_EXIT:
				
				break;
				
		}         
			break;
			
		case TRACK_LOG_VIEW:
			
			switch (currentEvent)
		{
			case EV_ENTRY:
				
				NSLog(@"Just changed to TRACK LOG VIEW state.");
				
				break;
				
			case EV_DOWNLOAD_BUTTON_PRESSED:
				
				nextState = DOWNLOADING_TRACK;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				break;
				
			case EV_FIRST_DEVICE_REMOVED:
				
				nextState = READY;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				break;
				
			case EV_FILE_OPENED:
				
				nextState = FILE_VIEW;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				break;
				
			case EV_EXIT:
				
				break;
				
		}         
			break;
			
		case DOWNLOADING_TRACK:
			
			switch (currentEvent)
		{
			case EV_ENTRY:
				
				NSLog(@"Just changed to DOWNLOADING TRACK state.");
				
				[trackFileViewController setDevice:[trackLogViewController firstConnectedDevice]];
				[trackFileViewController setTrackLogs:[trackLogViewController trackpointLogs]];
				
				[trackFileViewController downloadTrackFromDevice];
				
				break;
				
			case EV_TRACK_FINISHED_DOWNLOADING:
				
				nextState = FILE_VIEW;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				
				//Remove the connection with the first connected device
				[trackLogViewController removeAllDevices];
				
				//Initialize the trackFileViewController's currentTrack member using the downloaded track
				[trackFileViewController initializeCurrentFileFromTrack];
				
				break;
				
			case EV_CONNECTION_INTERRUPTED:
				
				nextState = READY;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				break;
			
			case EV_EXIT:
				
				break;	
				
		}         
			break;
			
		case FILE_VIEW:
			
			switch (currentEvent)
		{
			case EV_ENTRY:								
				
				[self displayViewController:trackFileViewController];
				NSLog(@"Just changed to TRACK FILE VIEW state.");
												
				break;
				
			case EV_FILE_OPENED:								
				
				
				break;
				
			case EV_FILE_CLOSED:
				nextState = READY;//Decide what the next state will be
				makeTransition = TRUE; //mark that we are taking a transition
				break;
				
			case EV_EXIT:
				[trackFileViewController setCurrentFile:nil];
												
				break;
				
		}         
			break;		            
			
	}
	
	
	//   If we are making a state transition
	if (makeTransition == YES)
	{
		
		//   Execute entry functions for old state
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
			   name:VTFileOpenSelectedNotification
			 object:nil];
}


//Convert notifications into events for the state machine to process
-(void)handleDownloadButtonPress:(NSNotification *)note
{
	NSLog(@"Received notification: %@", [note name]);		
	[self runStateMachine:EV_DOWNLOAD_BUTTON_PRESSED];
	
}

-(void)handleTrackFinishedDownloading:(NSNotification *)note
{
	NSLog(@"Received notification: %@", [note name]);	
	[self runStateMachine:EV_TRACK_FINISHED_DOWNLOADING];

}

-(void)handleStartedEstablishingConnectionWithDevice:(NSNotification *)note
{
	NSLog(@"Received notification: %@", [note name]);
	[self runStateMachine:EV_STARTED_ESTABLISHING_CONNECTION];
	
}

-(void)handleTrackLogsFinishedDownloading:(NSNotification *)note
{
	NSLog(@"Received notification: %@", [note name]);
	[self runStateMachine:EV_TRACKLOGS_FINISHED_DOWNLOADING];
	
}

-(void)handleFirstConnectedDeviceRemoved:(NSNotification *)note
{
	NSLog(@"Received notification: %@", [note name]);
	[self runStateMachine:EV_FIRST_DEVICE_REMOVED];
	
}

- (void)handleFileOpenSelected:(NSNotification*)note
{
	
	NSLog(@"Main window controller received notification: %@", [note name]);
	
	int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"vcc"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAllowedFileTypes:fileTypes];
	
    result = [oPanel runModal];
	
    if (result == NSOKButton) {			
	
		[trackFileViewController initializeCurrentFileFromURL:[oPanel URL]];
		[self runStateMachine:EV_FILE_OPENED];
	
	}
	
}

-(void)displayViewController:(NSViewController *)vc
{
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
		animate:YES];
	
	//Put the view in the box
	[box setContentView:v];
}

-(void)dealloc
{
	
	[trackLogViewController release];
	[trackFileViewController release];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
	
}



@end
