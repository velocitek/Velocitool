//
//  VTDeviceSettingsController.h
//  Velocitool
//
//  Created by Alec Stewart on 6/21/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;
@class VTDeclinationValue;


@interface DeviceSettingsController : NSWindowController {
	
	VTDevice *device;
	
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *restoreDefaultsButton;
	
	IBOutlet NSPopUpButton *operatingModeButton;
	IBOutlet NSPopUpButton *recordRateButton;
	IBOutlet NSPopUpButton *speedUnitButton;
	IBOutlet NSPopUpButton *maxSpeedButton;
	IBOutlet NSPopUpButton *speedDampingButton;
	IBOutlet NSPopUpButton *compassDampingButton;
	IBOutlet NSPopUpButton *barGraphButton;
	
	IBOutlet NSTextField *operatingModeLabel;
	IBOutlet NSTextField *recordRateLabel;
	IBOutlet NSTextField *speedUnitLabel;
	IBOutlet NSTextField *maxSpeedLabel;
	IBOutlet NSTextField *speedDampingLabel;
	IBOutlet NSTextField *compassDampingLabel;
	IBOutlet NSTextField *barGraphLabel;
	
	NSMutableDictionary *menus;
	VTDeclinationValue *declinationValue;
	
	NSMutableDictionary *settingsToSendDevice;
	NSDictionary *settingsFromDevice;

}

@property (nonatomic, readwrite, retain) VTDeclinationValue *declinationValue;
@property (nonatomic, readwrite, retain) NSMutableDictionary *menus;


- (IBAction)closePanelAndSaveDeviceSettings:(id)sender;		
- (IBAction)closePanelWithoutSavingDeviceSettings:(id)sender;	
- (IBAction)restoreDefaults:(id)sender;	

-(IBAction)deviceOperationModeButtonSelected:(id)sender;

- (id)initWithDevice:(VTDevice*)deviceToUpdate;

- (void)updateDeviceSettingsWithMenuSelections;
- (void)updateMenusWithSettingsFromDevice;

@end

@interface SpeedPuck1_4DeviceSettingsController:DeviceSettingsController {} @end

@interface SpeedPuck1_3DeviceSettingsController:DeviceSettingsController {} @end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
