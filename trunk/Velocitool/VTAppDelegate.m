#import "VTAppDelegate.h"
#import "VTDeviceLoader.h"
#import "MainWindowController.h"

NSString *VTFileSaveSelectedNotification = @"VTFileSaveSelectedNotification";
NSString *VTFileOpenSelectedNotification = @"VTFileOpenSelectedNotification";
NSString *VTFileCloseSelectedNotification = @"VTFileCloseSelectedNotification";
NSString *VTFileExportGPXSelectedNotification = @"VTFileExportGPXSelectedNotification";
NSString *VTFileExportKMLSelectedNotification = @"VTFileExportKMLSelectedNotification";

NSString *VTSetupUpdateDeviceSettingsSelectedNotification = @"VTSetupUpdateDeviceSettingsSelectedNotification";
NSString *VTSetupEraseAllSelectedNotification = @"VTSetupEraseAllSelectedNotification";
NSString *VTSetupUpdateDeviceFirmwareSelectedNotification = @"VTSetupUpdateDeviceFirmwareSelectedNotification";

NSString *VTHelpTutorialVideoSelectedNotification = @"VTHelpTutorialVideoSelectedNotification";

@implementation VTAppDelegate

/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "Velocitool" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Velocitool"];
}


// Actions for main menu
- (IBAction)fileSave:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that File > Save has been selected by the user.");
	[notificationCenter postNotificationName:VTFileSaveSelectedNotification object:self];
		
}

- (IBAction)fileOpen:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that File > Open has been selected by the user.");
	[notificationCenter postNotificationName:VTFileOpenSelectedNotification object:self];
	
}


- (IBAction)fileClose:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that File > Close has been selected by the user.");
	[notificationCenter postNotificationName:VTFileCloseSelectedNotification object:self];
	
}

- (IBAction)fileExportGPX:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that File > Export > GPX has been selected by the user.");
	[notificationCenter postNotificationName:VTFileExportGPXSelectedNotification object:self];
	
}

- (IBAction)fileExportKML:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that File > Export > KML has been selected by the user.");
	[notificationCenter postNotificationName:VTFileExportKMLSelectedNotification object:self];
	
}

- (IBAction)setupUpdateDeviceSettings:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that Setup > Update Device Settings has been selected by the user.");
	[notificationCenter postNotificationName:VTSetupUpdateDeviceSettingsSelectedNotification object:self];
	
}

- (IBAction)setupEraseAll:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that Setup > Erase All has been selected by the user.");
	[notificationCenter postNotificationName:VTSetupEraseAllSelectedNotification object:self];
	
}

- (IBAction)setupUpdateDeviceFirmware:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that Setup > Update Device Firmware has been selected by the user.");
	[notificationCenter postNotificationName:VTSetupUpdateDeviceFirmwareSelectedNotification object:self];
	
}

- (IBAction)helpTutorialVideo:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that Help>Tutorial Video has been selected by the user.");
	[notificationCenter postNotificationName:VTHelpTutorialVideoSelectedNotification object:self];
	
}


/**
 Primes the USB watch for new devices and launches the the main window
 */

// This is called for user switching, there is a need to release the devices then...
- (void)_switchHandler:(NSNotification*) notification {
    // Get the device loader to clear the USB devices asap.
    if ([[notification name] isEqualToString:NSWorkspaceSessionDidResignActiveNotification]) {
        // FIXME Perform deactivation tasks here.
    } else {
        // FIXME Perform activation tasks here.
    }    
}

- (void)applicationDidFinishLaunching:sender {
    
	// If fast user switching is used I need to release the USB devices. Or at least stop talking to them...
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_switchHandler:) name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_switchHandler:) name:NSWorkspaceSessionDidResignActiveNotification object:nil];

	// prime it
    _loader = [VTDeviceLoader loader]; // No need to retain: singleton
	
	// Create the main window
	MainWindowController *mainWindowController = [MainWindowController alloc];	
	[mainWindowController init];		
}

/**
 I can't believe I'm doing this.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}



/**
 Implementation of dealloc, to release the retained variables.
 */

- (void) dealloc {
    
    _loader = nil;
    
    [super dealloc];
}


@end
