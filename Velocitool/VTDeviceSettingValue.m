//
//  VTDeviceSettingValue.m
//  Velocitool
//
//  Created by Alec Stewart on 6/27/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTDeviceSettingValue.h"


@implementation VTDeviceSettingValue

@synthesize displayValue;
@synthesize numericalValue;


- (id)initWithDisplayAndNumericalValues:(NSString *)dispVal numericalValue:(NSNumber *)numVal
{
	if (![super init])
		return nil;
	
	[self setDisplayValue:dispVal];
	
    [self setNumericalValue:numVal];
	
    return self;
}

+ (id)deviceSettingValueWithDisplayAndNumericalValues:(NSString *)dispVal numericalValue:(NSNumber *)numVal;
{
	VTDeviceSettingValue *deviceSettingValue = [[self alloc] initWithDisplayAndNumericalValues:dispVal numericalValue:numVal];

    [deviceSettingValue autorelease];
	
	return deviceSettingValue;
}

- (NSString *)description
{
	return displayValue;
}

- (void)dealloc
{
	[numericalValue release];
	
    [displayValue release];
	
    [super dealloc];
}


@end
