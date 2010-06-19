

#import <Cocoa/Cocoa.h>

@class VTDeviceLoader;

extern NSString *VTFileSaveSelectedNotification;
extern NSString *VTFileOpenSelectedNotification;
extern NSString *VTFileCloseSelectedNotification;
extern NSString *VTFileExportGPXSelectedNotification;
extern NSString *VTFileExportKMLSelectedNotification;

extern NSString *VTSetupUpdateDeviceSettingsSelectedNotification;
extern NSString *VTSetupEraseAllSelectedNotification;
extern NSString *VTSetupUpdateDeviceFirmwareSelectedNotification;

extern NSString *VTHelpTutorialVideoSelectedNotification;

@interface VTAppDelegate : NSObject 
{    
 	
    VTDeviceLoader *_loader;
	
	IBOutlet NSMenuItem *fileSave;
	IBOutlet NSMenuItem *fileOpen;
	IBOutlet NSMenuItem *fileClose;
	IBOutlet NSMenuItem *fileExportGPX;
	IBOutlet NSMenuItem *fileExportKML;
	
	IBOutlet NSMenuItem *setupUpdateDeviceSettings;
	IBOutlet NSMenuItem *setupEraseAll;
	IBOutlet NSMenuItem *setupUpdateDeviceFirmware;
	
	IBOutlet NSMenuItem *helpTutorialVideo;
	
	
}


- (IBAction)fileSave:(id)sender;
- (IBAction)fileOpen:(id)sender;
- (IBAction)fileClose:(id)sender;
- (IBAction)fileExportGPX:(id)sender;
- (IBAction)fileExportKML:(id)sender;

- (IBAction)setupUpdateDeviceSettings:(id)sender;
- (IBAction)setupEraseAll:(id)sender;
- (IBAction)setupUpdateDeviceFirmware:(id)sender;

- (IBAction)helpTutorialVideo:(id)sender;


@end
