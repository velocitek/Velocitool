//
//  VTDeviceSettingMenu.m
//  Velocitool
//
//  Created by Alec Stewart on 6/28/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTDeviceSettingMenu.h"
#import "VTDeviceSettingValue.h"

@interface VTDeviceSettingMenu (private)

- (void)createMenuOptionsFromPossibleValuesDictionary:(NSDictionary*)possibleValues;
//- (NSArray *)createPossibleValuesArrayFromDisplayA

@end



@implementation VTDeviceSettingMenu

@synthesize possibleValuesContentArray;
@synthesize possibleValuesArrayController;
@synthesize hidden;


+ (id)deviceSettingMenuWithPossibleValues:(NSDictionary*)possibleVals
{
	VTDeviceSettingMenu *deviceSettingMenu = [[self alloc] initWithPossibleValues:possibleVals];
		
	return deviceSettingMenu;
	
}

- (id)initWithPossibleValues:(NSDictionary *)possibleVals {
  if ((self = [super init])) {
    // Allocate possible values content array
    possibleValuesContentArray = [[NSMutableArray alloc] init];

    possibleValuesArrayController =
        [[NSArrayController alloc] initWithContent:nil];

    [possibleValuesArrayController bind:@"contentArray"
                               toObject:self
                            withKeyPath:@"possibleValuesContentArray"
                                options:nil];

    [self createMenuOptionsFromPossibleValuesDictionary:possibleVals];

    // Enable the menu by default
    [self setHidden:NO];
  }
  return self;
}

- (VTDeviceSettingValue *)selectedDeviceSetting
{
	
	NSArray *selectedObjects = [possibleValuesArrayController selectedObjects];
	
	return [selectedObjects objectAtIndex:0];
}

- (void)setSelectedDeviceSetting:(VTDeviceSettingValue *)selectedSetting
{
	selectedDeviceSetting = selectedSetting;
	[possibleValuesArrayController setSelectedObjects:[NSArray arrayWithObject:selectedSetting]];	

}

- (void)createMenuOptionsFromPossibleValuesDictionary:(NSDictionary*)possibleValues
{	    
	
	NSArray *displayValuesArray = [possibleValues keysSortedByValueUsingSelector:@selector(compare:)];
	
	//for each possible value in possibleValues
	for(NSString *displayValue in displayValuesArray)
	{			
        
		NSNumber *numVal = [possibleValues objectForKey:displayValue];
		
		VTDeviceSettingValue *menuOption = [VTDeviceSettingValue deviceSettingValueWithDisplayAndNumericalValues:displayValue 																								  numericalValue:numVal];																												  

        //add possible value to possibleValues array controller
		[possibleValuesArrayController addObject:menuOption];
		
	}
	
}

-(void)setDefaultValue:(NSString*)displayValueOfDesiredDefault
{
	
	BOOL matchingValueFound = NO;
	
    //for each device setting value in possibleValuesContentArray
	for(VTDeviceSettingValue *value in possibleValuesContentArray)
	{
		if([displayValueOfDesiredDefault compare:[value displayValue]] == NSOrderedSame)
		{            
			defaultValue = value;
            matchingValueFound = YES;
			
		}

	}
	
	//if matching value found is still NO
	if(matchingValueFound == NO)
	{			
		
		//send error message to terminal 
		[NSException raise:@"VTError" 
					format:@"setDefaultValue has been asked to set %@ as the default menu option for a menu.  Unfortunately, %@ is not a valid menu option for this menu",displayValueOfDesiredDefault, displayValueOfDesiredDefault];		
		
	}
	
	
}

- (void)selectDefaultValue
{
	[self setSelectedDeviceSetting:defaultValue];
}


- (void)selectOptionWithMatchingNumericalValue:(NSNumber*)numVal
{
	
	BOOL matchingValueFound = NO;
	
    //for each device setting value in possibleValuesContentArray
	for(VTDeviceSettingValue *value in possibleValuesContentArray)
	{
        //if the numerical value property of the the device setting value matches value
		if([numVal isEqualToNumber:[value numericalValue]])
		{
            //set the device setting value as the possibleValuesArrayController's selection
			[self setSelectedDeviceSetting:value];
			
            matchingValueFound = YES;
			
		}
					
		
	}
	
	//if matching value found is still NO
	if(matchingValueFound == NO)
	{			
						
		//send error message to terminal 
		DDLogError(@"An option with the requested numerical value of %@ could not be found.  Using default value of %@ (%@) instead.",numVal, [defaultValue numericalValue], [defaultValue displayValue]);
		 
		[self setSelectedDeviceSetting:defaultValue];
		
	}
		
}

@end
