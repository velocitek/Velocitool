//
//  VTDeclinationValue.m
//  Velocitool
//
//  Created by Alec Stewart on 6/27/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTDeclinationValue.h"


@implementation VTDeclinationValue

@synthesize sliderValue;
@synthesize numericalValue;

@synthesize hidden;

+ (id)declinationValueWithNumericalValue:(NSNumber *)numVal
{
	VTDeclinationValue *declinationValue = [[self alloc] initWithNumericalValue:numVal];
	
    [declinationValue autorelease];
	
	return declinationValue;
}

- (id)initWithNumericalValue:(NSNumber *)numVal
{
	if (![super init])
		return nil;
	
	[self setNumericalValue:numVal];
	
	//Enable the declination slider by default
	[self setHidden:NO];
	
	return self;
}

- (void)setSliderValue:(NSNumber *)newValue
{
	[numericalValue autorelease];
	
    [sliderValue autorelease];
	
	sliderValue = [newValue retain];
	
	numericalValue = [[NSNumber numberWithInt:([sliderValue intValue] + 128)] retain];
}

- (void)setNumericalValue:(NSNumber *)newValue
{
	
	[numericalValue autorelease];
	[sliderValue autorelease];
	
	numericalValue = [newValue retain];	
	sliderValue = [[NSNumber numberWithInt:([numericalValue intValue] - 128)] retain];
}

- (void)selectDefaultValue
{
	[self setSliderValue:0];	
}


@end


@interface DeclinationValueTransformer: NSValueTransformer {}
@end

@implementation DeclinationValueTransformer
+ (Class)transformedValueClass
{
    return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(NSNumber *)sliderValue
{
	int numberToDisplay = [sliderValue intValue];
	
	if(numberToDisplay > 0)
	{
		return [NSString stringWithFormat:@"+%d°", numberToDisplay];
	}
	else 
	{
		return [NSString stringWithFormat:@"%d°", numberToDisplay];
	}
}

@end

