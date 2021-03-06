//
//  TrackLogViewController.m
//  Velocitool
//
//  Created by Alec Stewart on 5/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "TrackLogViewController.h"
#import "VTGlobals.h"

#import "VTDevice.h"
#import "VTDeviceLoader.h"
#import "VTRecord.h"

@interface TrackLogViewController (private)

- (void)setFirstConnectedDevice:(VTDevice *)newDevice;
- (void)setFirstConnectedAndTriggerNotification:(VTDevice *)newDevice;

- (void)removeFirstConnectedDevice;

@end

NSString *VTStartedEstablishingConnectionWithDeviceNotification = @"VTStartedEstablishingConnectionWithDeviceNotification";
NSString *VTTrackLogsFinishedDownloadingNotification = @"VTTrackLogsFinishedDownloadingNotification";
NSString *VTFirstConnectedDeviceRemovedNotification = @"VTFirstConnectedDeviceRemovedNotification";

@implementation TrackLogViewController

@synthesize devices;
@synthesize trackpointLogs;
@synthesize firstConnectedDevice;

- (NSButton*) getDownloadButton {
    return downloadButton;
}

- (IBAction)updateFirmware:(id)sender
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTUpdateFirmwareNotification object:self];
}

- (IBAction)fileOpen:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTOpenButtonSelectedNotification object:self];
}

- (IBAction)setDefaultFileDirectory:(id)sender
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTDefaultDirectoryButtonSelectedNotification object:self];
}

- (IBAction)updateDeviceSettings:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTUpdateDeviceSettingsButtonSelectedNotification object:self];
}

- (IBAction)eraseAll:(id)sender
{
	NSAlert *eraseAllAlert = [NSAlert alertWithMessageText:@"Erase all GPS data on connected device?" 
											 defaultButton:@"Cancel"
										   alternateButton:@"OK"
											   otherButton:nil
								 informativeTextWithFormat:@""];
	
	NSInteger alertResult = [eraseAllAlert runModal];
	
	if (alertResult == NSAlertAlternateReturn) 
	{
		[firstConnectedDevice eraseAll];
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:VTEraseAllConfirmedNotification object:self];
			
		
		
	}
												   	
	
}

/*Not currently implemented
- (IBAction)helpTutorialVideo:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTHelpTutorialVideoSelectedNotification object:self];
}

- (IBAction)updateDeviceFirmware:(id)sender
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTSetupUpdateDeviceFirmwareSelectedNotification object:self];
	
}
*/


- (IBAction)downloadDataFromDevice:(id)sender
{
		
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTDownloadButtonPressedNotification object:self];
	
}


- (id)init {
  if((self = [super initWithNibName:@"TrackLogView" bundle: nil])) {
    devices = [[NSMutableArray alloc] init];
    trackpointLogs = [[NSMutableArray alloc] init];

    [self armNotifications];
  }
	return self;
}

- (void)awakeFromNib
{
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO]];
	
	[trackpointLogController setSortDescriptors:sortDescriptors];
}


- (void)armNotifications
{
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceAdded:) name:VTDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceRemoved:) name:VTDeviceRemovedNotification object:nil];
	
}

- (void)removeAllDevices
{

	while ([devices count] > 0) {
		
		[deviceController removeObjectAtArrangedObjectIndex:([devices count] - 1)]; 
		
	}								            													
	
	[self removeFirstConnectedDevice];
	
}

- (void)setFirstConnectedDevice:(VTDevice *)newDevice
{
	firstConnectedDevice = newDevice;
	
	if (firstConnectedDevice)
	{
		//sleep(1);		
		for (VTTrackpointLogRecord *trackpointLog in [firstConnectedDevice trackpointLogs])
		{
			[trackpointLogController addObject:trackpointLog];
			
			//Rearrange the objects to retain proper sorting
			[trackpointLogController rearrangeObjects];
			
		}
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:VTTrackLogsFinishedDownloadingNotification object:self];
	}	
}

- (void)setFirstConnectedAndTriggerNotification:(VTDevice *)newDevice
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTStartedEstablishingConnectionWithDeviceNotification object:self];
	
	//Give the UI a chance to change state in response to the notification before connecting to the device
	[self performSelector: @selector(setFirstConnectedDevice:) withObject:newDevice afterDelay: .1];
				
}

- (void)removeFirstConnectedDevice
{
	for (VTTrackpointLogRecord *trackpointLog in trackpointLogs)
	{
		[trackpointLogController removeObject:trackpointLog];
		
	}
	
	[self setFirstConnectedDevice:nil];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTFirstConnectedDeviceRemovedNotification object:self];
	
}

- (void)reenumerateFirstConnectedDevice
{
    for (VTTrackpointLogRecord *trackpointLog in trackpointLogs)
    {
        [trackpointLogController removeObject:trackpointLog];
        
    }
    
    VTDevice * dev = firstConnectedDevice;
    
    [self setFirstConnectedDevice:nil];
    
    [dev reenumerateDevice];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTFirstConnectedDeviceRemovedNotification object:self];
    
}

- (void)lookForAlreadyConnectedDevices
{
	
	//Remove any devices objects that might be in the devicesController array controller
	if (firstConnectedDevice) 
	{
		[self removeAllDevices];
	}
	
	//Look for any devices already connected to the Mac and add them to the array controller
	VTDeviceLoader *deviceLoader = [VTDeviceLoader loader];
	
	NSArray *devicesAlreadyConnected = [deviceLoader devices];	
	
	for (VTDevice *deviceToAdd in devicesAlreadyConnected)
	{
		[deviceController addObject:deviceToAdd];		
		
		if ([devices count] == 1)
			[self setFirstConnectedAndTriggerNotification:deviceToAdd];
	}			
}

- (void)_deviceAdded:(NSNotification *)note {
    
    NSString *serial = [[note userInfo] objectForKey:@"serial"];
    
    if(serial) 
	{
		//Wait 1s to give the device microcontroller a chance to initialize (if the device did not have batteries installed
		//it will have just powered up when it was connected to the USB cable)
		sleep(1);
		
		VTDeviceLoader *deviceLoader = [VTDeviceLoader loader];
		
		VTDevice *newDevice = [deviceLoader deviceForSerialNumber:serial];
		
		[deviceController addObject:newDevice];
        
        if ([devices count] == 1) {
            [self setFirstConnectedAndTriggerNotification:newDevice];
        }
		
		
    }
	
	
}

- (void)_deviceRemoved:(NSNotification *)note {
    NSString *serial = [[note userInfo] objectForKey:@"serial"];
    
    if(serial) {
		
		for (VTDevice *device in [deviceController arrangedObjects]) {
			
            if ([[device serial] isEqual:serial]) 
			{                
				[deviceController removeObject:device];
				
				if ([[device serial] isEqual:[firstConnectedDevice serial]]) 
				
					[self removeFirstConnectedDevice];
				
				break;
            }
        }		
		
    }
}

- (void) setUpdateFirmwareButtonEnabled:(bool) enabled{
    [updateFirmwareButton setEnabled:enabled];
}
- (void) setDownloadButtonEnabled:(bool) enabled {
    [downloadButton setEnabled:enabled];
}

- (void) setEraseAllTracksButtonEnabled:(bool) enabled {
    [eraseAllButton setEnabled:enabled];
}

@end


@interface DeviceHasNoDeviceSettingsValueTransformer: NSValueTransformer {}
@end

@implementation DeviceHasNoDeviceSettingsValueTransformer
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(VTDevice *)device
{
		
	if([[device model] isEqual:@"SpeedPuck"])
	{
		return [NSNumber numberWithBool:NO];		
	}
	else 
	{
		return [NSNumber numberWithBool:YES];
	}
	
}

@end
