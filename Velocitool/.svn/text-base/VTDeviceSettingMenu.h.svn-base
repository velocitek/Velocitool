//
//  VTDeviceSettingMenu.h
//  Velocitool
//
//  Created by Alec Stewart on 6/28/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDeviceSettingValue;


@interface VTDeviceSettingMenu : NSObject {
		
	int indexOfDefaultValue;
	
	NSArrayController *possibleValuesArrayController;
	NSMutableArray *possibleValuesContentArray;
	
	VTDeviceSettingValue *defaultValue;
	
	VTDeviceSettingValue *selectedDeviceSetting;
	
	BOOL hidden;

}

@property (readwrite, retain) NSArrayController *possibleValuesArrayController;
@property (readwrite, retain) NSMutableArray *possibleValuesContentArray;

@property (readwrite, retain) VTDeviceSettingValue *selectedDeviceSetting;

@property (readwrite) BOOL hidden;

+ (id)deviceSettingMenuWithPossibleValues:(NSDictionary*)possibleVals;
- (id)initWithPossibleValues:(NSDictionary*)possibleVals;
-(void)setDefaultValue:(NSString*)displayValueOfDesiredDefault;

- (void)selectDefaultValue;
- (void)selectOptionWithMatchingNumericalValue:(NSNumber*)numVal;

@end
