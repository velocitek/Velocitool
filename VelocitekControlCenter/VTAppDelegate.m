#import "VTAppDelegate.h"
#import "VTDeviceLoader.h"
#import "MainWindowController.h"
#import "DeviceSettingsController.h"
#import "VTDefines.h"
#import "VTConnection.h"
#include "ftd2xx.h"

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

- (void) setupLogging {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
#ifdef DEBUG
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
#endif
    
}

- (void)applicationDidFinishLaunching:sender {
    
    [self setupLogging];
    
    // Checking operating system version...
    NSOperatingSystemVersion systemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    DDLogError(@"Current OSx Version = %ld.%ld.%ld", (long)systemVersion.majorVersion, (long)systemVersion.minorVersion, (long)systemVersion.patchVersion);
    
    if ( systemVersion.majorVersion < 10 || ( systemVersion.majorVersion == 10 && systemVersion.minorVersion < 7 ) ) {
        NSString * sMessage = [NSString stringWithFormat:@"%@ It is compatible with 10.8.0 and later.", kErrorIncompatibleMessage];
        NSAlert *eraseAllAlert = [NSAlert alertWithMessageText:sMessage
                                                 defaultButton:@"OK"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@""];
        
        NSInteger alertResult = [eraseAllAlert runModal];
        
        if (alertResult == NSAlertAlternateReturn)
        {
            abort();
        }
    }
    
	// If fast user switching is used I need to release the USB devices. Or at least stop talking to them...
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_switchHandler:) name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(_switchHandler:) name:NSWorkspaceSessionDidResignActiveNotification object:nil];
    
	// prime it
    _loader = [VTDeviceLoader loader]; // No need to retain: singleton
	
	// Create the main window
    mainWindowController = [[MainWindowController alloc] init];

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
    
}


@end
