//
//  DeviceSettingsController.m
//  Velocitool
//
//  Created by Alec Stewart on 6/21/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "DeviceSettingsController.h"
#import "VTDevice.h"
#import "VTDeclinationValue.h"
#import "VTDeviceSettingValue.h"
#import "VTDeviceSettingMenu.h"
#import "VTGlobals.h"

@interface DeviceSettingsController (private)

- (void)bindPopUpButtonAndLabelToMenu:(NSPopUpButton *)button labelText:(NSTextField *)label menuTobind:(VTDeviceSettingMenu *)menu;
- (void)bindPopupButtonsAndLabelsToMenus;

- (void)addMenuToDictionaryAndSetDefaultValue:(NSDictionary*)possibleValuesDictionary 
								 defaultValue:(NSString*)defaultVal
							menuDictionaryKey:(NSString*)dictKey;

- (void)addOperatingModeMenuToMenuDictionary;

- (void)addRecordRateMenuToMenuDictionary;
- (void)addSpeedUnitOfMeasurementMenuToMenuDictionary;
- (void)addMaxSpeedModeMenuToMenuDictionary;

- (void)addSpeedDampingMenuToMenuDictionary;
- (void)addCompassDampingMenuToMenuDictionary;
- (void)addBarGraphMenuToMenuDictionary;

- (void)chooseWhichMenusToEnable;

@end



@implementation DeviceSettingsController

@synthesize declinationValue;
@synthesize menus;


- (id)initWithDevice:(VTDevice*)deviceToUpdate
{
	if (![super initWithWindowNibName:@"DeviceSettings"])
		return nil;
	
	device = deviceToUpdate;
	
	menus = [[NSMutableDictionary alloc] init];			
	
	[self addOperatingModeMenuToMenuDictionary];
	
	[self addRecordRateMenuToMenuDictionary];
	[self addSpeedUnitOfMeasurementMenuToMenuDictionary];
	[self addMaxSpeedModeMenuToMenuDictionary];
	[self addSpeedDampingMenuToMenuDictionary];
	[self addCompassDampingMenuToMenuDictionary];
	[self addBarGraphMenuToMenuDictionary];
			
	[self updateMenusWithSettingsFromDevice];
	
	
	
	return self;
}

- (void)windowDidLoad
{
	//NSLog(@"Device Settings Nib file is loaded");
	
	//Bind the device setting pop-up buttons to the array controllers in the
	//different VTDeviceSettingMenu objects.	
	[self bindPopupButtonsAndLabelsToMenus];
	
}

- (void)bindPopupButtonsAndLabelsToMenus
{
	
	[self bindPopUpButtonAndLabelToMenu:operatingModeButton 
							  labelText:operatingModeLabel
							 menuTobind:[menus objectForKey:VTPuckModePref]];	
	
	[self bindPopUpButtonAndLabelToMenu:recordRateButton 
							  labelText:recordRateLabel
							 menuTobind:[menus objectForKey:VTRecordRatePref]];
	
	[self bindPopUpButtonAndLabelToMenu:speedUnitButton
							  labelText:speedUnitLabel
							 menuTobind:[menus objectForKey:VTSpeedUnitPref]];
	
	[self bindPopUpButtonAndLabelToMenu:maxSpeedButton 
							  labelText:maxSpeedLabel
							 menuTobind:[menus objectForKey:VTMaxSpeedPref]];
	
	[self bindPopUpButtonAndLabelToMenu:speedDampingButton 
							  labelText:speedDampingLabel
							 menuTobind:[menus objectForKey:VTSpeedDampingPref]];
	
	[self bindPopUpButtonAndLabelToMenu:compassDampingButton
							  labelText:compassDampingLabel
							 menuTobind:[menus objectForKey:VTHeadingDampingPref]];
	
	[self bindPopUpButtonAndLabelToMenu:barGraphButton
							  labelText:barGraphLabel
							 menuTobind:[menus objectForKey:VTBarGraphPref]];
			
}

- (void)bindPopUpButtonAndLabelToMenu:(NSPopUpButton *)button labelText:(NSTextField *)label menuTobind:(VTDeviceSettingMenu *)menu
{
	[button bind:@"content" 
				toObject:menu 
			 withKeyPath:@"possibleValuesArrayController.arrangedObjects" 
				 options:nil];
	
	[button bind:@"selectedObject" 
				toObject:menu
			 withKeyPath:@"selectedDeviceSetting" 
				 options:nil];
	
	[button bind:@"hidden"
		toObject:menu
	 withKeyPath:@"hidden"
		 options:nil];
	
	[label bind:@"hidden"
	   toObject:menu 
	withKeyPath:@"hidden" 
		options:nil];
	
}

- (void)addMenuToDictionaryAndSetDefaultValue:(NSDictionary*)possibleValuesDictionary 
								 defaultValue:(NSString*)defaultVal 
							menuDictionaryKey:(NSString*)dictKey
{
	
	VTDeviceSettingMenu *newMenu = [VTDeviceSettingMenu deviceSettingMenuWithPossibleValues:possibleValuesDictionary];					
	
	[newMenu setDefaultValue:defaultVal];	
	
	[menus setObject:newMenu forKey:dictKey];	
	

}

- (void)addOperatingModeMenuToMenuDictionary
{
	// For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [DeviceSettingsController self]);
	
}

- (void)addRecordRateMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInt:VTRecordRateAll], @"Once a second", 
											  [NSNumber numberWithInt:VTRecordRateEveryTwo], @"Every two seconds", 
											  [NSNumber numberWithInt:VTRecordRateEveryFour], @"Every four seconds", 											  
											  nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Every two seconds" 
							  menuDictionaryKey:VTRecordRatePref];
	
}


- (void)addSpeedUnitOfMeasurementMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTSpeedUnitKnots], @"Knots",
									[NSNumber numberWithInt:VTSpeedUnitMilesPerHour], @"mph", 
									[NSNumber numberWithInt:VTSpeedUnitKilometersPerHour], @"km/h", 
									[NSNumber numberWithInt:VTSpeedUnitMetersPerSecond], @"m/s",
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Knots" 
							  menuDictionaryKey:VTSpeedUnitPref];
			
}

- (void)addMaxSpeedModeMenuToMenuDictionary
{
	
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTMaxSpeedInstant], @"Display Max Speed",
									[NSNumber numberWithInt:VTMaxSpeed10Second], @"Display Best 10 sec. Avg. Speed", 
									[NSNumber numberWithInt:VTMaxSpeedBoth], @"Flash Between Both", 
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Display Best 10 sec. Avg. Speed" 
							  menuDictionaryKey:VTMaxSpeedPref];
	
}

- (void)addSpeedDampingMenuToMenuDictionary
{
	
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTDampingNoDamping], @"No Damping",
									[NSNumber numberWithInt:VTDampingOneSecond], @"1 second", 
									[NSNumber numberWithInt:VTDampingTwoSecond], @"2 seconds", 
									[NSNumber numberWithInt:VTDampingFiveSecond], @"5 seconds",
									[NSNumber numberWithInt:VTDampingTenSecond], @"10 seconds",
									[NSNumber numberWithInt:VTDampingThirtySecond], @"30 seconds",
									[NSNumber numberWithInt:VTDampingOneMinute], @"1 minute", 
									[NSNumber numberWithInt:VTDampingTwoMinutes], @"2 minutes",
									[NSNumber numberWithInt:VTDampingFourMinutes], @"4 minutes",
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"1 second" 
							  menuDictionaryKey:VTSpeedDampingPref];
}

- (void)addCompassDampingMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTDampingNoDamping], @"No Damping",
									[NSNumber numberWithInt:VTDampingOneSecond], @"1 second", 
									[NSNumber numberWithInt:VTDampingTwoSecond], @"2 seconds", 
									[NSNumber numberWithInt:VTDampingFiveSecond], @"5 seconds",
									[NSNumber numberWithInt:VTDampingTenSecond], @"10 seconds",
									[NSNumber numberWithInt:VTDampingThirtySecond], @"30 seconds",
									[NSNumber numberWithInt:VTDampingOneMinute], @"1 minute", 
									[NSNumber numberWithInt:VTDampingTwoMinutes], @"2 minutes",
									[NSNumber numberWithInt:VTDampingFourMinutes], @"4 minutes",
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"1 second" 
							  menuDictionaryKey:VTHeadingDampingPref];
}

- (void)addBarGraphMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTBarGraphDisplayHeaderLiftAngle], @"Display Header / Lift Angle",
									[NSNumber numberWithInt:VTBarGraphDisabled], @"Disable bar graph", 
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Display Header / Lift Angle" 
							  menuDictionaryKey:VTBarGraphPref];
}

- (void)chooseWhichMenusToEnable
{
	// For subclassers to implement
    VTRaiseAbstractMethodException(self, _cmd, [DeviceSettingsController self]);
	
}


- (void)updateMenusWithSettingsFromDevice
{
	//settingsFromDevice = result of call to device's deviceSettings method
	settingsFromDevice = [device deviceSettings];
	
	VTDeclinationValue *declinationFromDevice = [VTDeclinationValue declinationValueWithNumericalValue:[settingsFromDevice valueForKey:@"declination"]];
	
    //set the numericalValue property of declinationValue to the value in the settingsFromDevice dictionary that corresponds with the key "declination"
	[self setDeclinationValue:declinationFromDevice];
	
    //for each key in settingsFromDevice
	for(NSString *key in settingsFromDevice)
	{
	
		VTDeviceSettingMenu *menu = [menus valueForKey:key];
		
		//if an element in the menus array with a matching key member can be found:
		if (menu) 
		{			
			//call the menu's selectOptionWithMatchingNumericalValue method with the value corresponding to the key in settingsFrom Device
			[menu selectOptionWithMatchingNumericalValue:[settingsFromDevice valueForKey:key]];
		}
		else 
		{
			if (key != VTDeclinationPref) {
			
				//Send error message to terminal
				//[NSException raise:@"VTError" 
				//			format:@"A VTDeviceSettingMenu object with the key member %@ could not be found in the menus array",key];		
				
				NSLog(@"A VTDeviceSettingMenu object with the key member %@ could not be found in the menus array",key);
			}
						
		}
	
	}
	
	[self chooseWhichMenusToEnable];
}

- (void) updateDeviceSettingsWithMenuSelections
{
	
	settingsToSendDevice = [[NSMutableDictionary alloc] initWithDictionary:settingsFromDevice];
	
	[settingsToSendDevice removeObjectForKey:@"declination"];	
	[settingsToSendDevice setObject:[declinationValue numericalValue] forKey:@"declination"];
				
    
	for(NSString *key in menus)
	{		
        
		VTDeviceSettingMenu *menu = [menus valueForKey:key];
		
		if(menu)
		{
			
			[settingsToSendDevice removeObjectForKey:key];				
			[settingsToSendDevice setObject:[menu valueForKeyPath:@"selectedDeviceSetting.numericalValue"] forKey:key];			
			
		}
		
	}
	
	//call device's setDeviceSettings method to update the device's settings.
	[device setDeviceSettings:settingsToSendDevice];	
}


-(IBAction)deviceOperationModeButtonSelected:(id)sender
{
	//NSLog(@"device operation mode changed");
	[self chooseWhichMenusToEnable];
}


- (IBAction)closePanelAndSaveDeviceSettings:(id)sender
{
	//NSLog(@"OK button selected");
	[self updateDeviceSettingsWithMenuSelections];
	[self close];
}

- (IBAction)closePanelWithoutSavingDeviceSettings:(id)sender
{
	//NSLog(@"Cancel button selected");
	[self close];
}

- (IBAction)restoreDefaults:(id)sender
{
	//NSLog(@"Restore Defaults button selected");
		
		
	for(NSString *key in menus)
	{		
        
		VTDeviceSettingMenu *menu = [menus valueForKey:key];		
		[menu selectDefaultValue];
		
	}
	
	[declinationValue selectDefaultValue];
	
	[self chooseWhichMenusToEnable];
	
	
}

@end


@implementation SpeedPuck1_3DeviceSettingsController

- (void)addOperatingModeMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTPuck1_3ModeNormal], @"Sailing (speed and heading)", 									
									[NSNumber numberWithInt:VTPuck1_3ModeMotor], @"Motor Sports (speed only)",
									[NSNumber numberWithInt:VTPuck1_3ModeBlank], @"Simple Data Logger (blank display)",
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Sailing (speed and heading)" 
							  menuDictionaryKey:VTPuckModePref];
	
}

- (void)chooseWhichMenusToEnable
{
	VTDeviceSettingMenu *operatingModeMenu = [menus objectForKey:VTPuckModePref];
	
	VTDeviceSettingMenu *recordRateMenu = [menus objectForKey:VTRecordRatePref];
	VTDeviceSettingMenu *speedUnitMenu = [menus objectForKey:VTSpeedUnitPref];
	VTDeviceSettingMenu *maxSpeedMenu = [menus objectForKey:VTMaxSpeedPref];
	VTDeviceSettingMenu *speedDampingMenu = [menus objectForKey:VTSpeedDampingPref];
	VTDeviceSettingMenu *compassDampingMenu = [menus objectForKey:VTHeadingDampingPref];
	VTDeviceSettingMenu *barGraphMenu = [menus objectForKey:VTBarGraphPref];
	
	VTDeclinationValue *declination = [self declinationValue];
	
	int currentlySelectedOperatingMode = [[operatingModeMenu valueForKeyPath:@"selectedDeviceSetting.numericalValue"] intValue];								  
	
	switch (currentlySelectedOperatingMode) {
			
		case VTPuck1_3ModeNormal:
			
			[recordRateMenu setHidden:NO];
			[speedUnitMenu setHidden:NO];
			[maxSpeedMenu setHidden:NO];
			[speedDampingMenu setHidden:NO];
			[compassDampingMenu setHidden:NO];
			[barGraphMenu setHidden:NO];
			[declination setHidden:NO];
			
			break;					
			
		case VTPuck1_3ModeMotor:
			
			[recordRateMenu setHidden:NO];
			[speedUnitMenu setHidden:NO];
			[maxSpeedMenu setHidden:NO];
			[speedDampingMenu setHidden:NO];
			
			[compassDampingMenu setHidden:YES];
			[barGraphMenu setHidden:YES];
			[declination setHidden:YES];
			
			break;
			
		case VTPuck1_3ModeBlank:
			
			[recordRateMenu setHidden:NO];
			
			[speedUnitMenu setHidden:YES];
			[maxSpeedMenu setHidden:YES];
			[speedDampingMenu setHidden:YES];
			[compassDampingMenu setHidden:YES];
			[barGraphMenu setHidden:YES];
			[declination setHidden:YES];
			
			break;
						
	}
}

@end




@implementation SpeedPuck1_4DeviceSettingsController

- (void)addOperatingModeMenuToMenuDictionary
{
	NSDictionary *possibleValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:VTPuck1_4ModeNormal], @"Sailing (speed and heading)", 
									[NSNumber numberWithInt:VTPuck1_4ModeRace], @"Race (heading only)", 
									[NSNumber numberWithInt:VTPuck1_4ModeMotor], @"Motor Sports (speed only)",
									[NSNumber numberWithInt:VTPuck1_4ModeBlank], @"Simple Data Logger (blank display)",
									nil];											  				
	
	[self addMenuToDictionaryAndSetDefaultValue:possibleValues 
								   defaultValue:@"Sailing (speed and heading)" 
							  menuDictionaryKey:VTPuckModePref];
	
}

- (void)chooseWhichMenusToEnable
{
	VTDeviceSettingMenu *operatingModeMenu = [menus objectForKey:VTPuckModePref];
	
	VTDeviceSettingMenu *recordRateMenu = [menus objectForKey:VTRecordRatePref];
	VTDeviceSettingMenu *speedUnitMenu = [menus objectForKey:VTSpeedUnitPref];
	VTDeviceSettingMenu *maxSpeedMenu = [menus objectForKey:VTMaxSpeedPref];
	VTDeviceSettingMenu *speedDampingMenu = [menus objectForKey:VTSpeedDampingPref];
	VTDeviceSettingMenu *compassDampingMenu = [menus objectForKey:VTHeadingDampingPref];
	VTDeviceSettingMenu *barGraphMenu = [menus objectForKey:VTBarGraphPref];
	
	VTDeclinationValue *declination = [self declinationValue];
	
	int currentlySelectedOperatingMode = [[operatingModeMenu valueForKeyPath:@"selectedDeviceSetting.numericalValue"] intValue];								  
	
	switch (currentlySelectedOperatingMode)
    {
		case VTPuck1_4ModeNormal:
			
			[recordRateMenu setHidden:NO];
			[speedUnitMenu setHidden:NO];
			[maxSpeedMenu setHidden:NO];
			[speedDampingMenu setHidden:NO];
			[compassDampingMenu setHidden:NO];
			[barGraphMenu setHidden:NO];
			[declination setHidden:NO];
			
			break;
			
		case VTPuck1_4ModeRace:
			
			[recordRateMenu setHidden:NO];									
			[compassDampingMenu setHidden:NO];
			[declination setHidden:NO];
			
			
			[speedUnitMenu setHidden:YES];
			[maxSpeedMenu setHidden:YES];
			[speedDampingMenu setHidden:YES];
			[barGraphMenu setHidden:YES];
			
			
			break;
			
		case VTPuck1_4ModeMotor:
			
			[recordRateMenu setHidden:NO];
			[speedUnitMenu setHidden:NO];
			[maxSpeedMenu setHidden:NO];
			[speedDampingMenu setHidden:NO];
			
			[compassDampingMenu setHidden:YES];
			[barGraphMenu setHidden:YES];
			[declination setHidden:YES];
			
			break;
			
		case VTPuck1_4ModeBlank:
			
			[recordRateMenu setHidden:NO];
			
			[speedUnitMenu setHidden:YES];
			[maxSpeedMenu setHidden:YES];
			[speedDampingMenu setHidden:YES];
			[compassDampingMenu setHidden:YES];
			[barGraphMenu setHidden:YES];
			[declination setHidden:YES];
			
			break;
			
			
	}
}

@end


