//
//  VTDeclinationValue.h
//  Velocitool
//
//  Created by Alec Stewart on 6/27/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VTDeclinationValue : NSObject {
	
	NSNumber *sliderValue;
	NSNumber *numericalValue;
	BOOL hidden;

}

- (void)selectDefaultValue;

@property (nonatomic, readwrite, strong) NSNumber *sliderValue;
@property (nonatomic, readwrite, strong) NSNumber *numericalValue;

@property (nonatomic, readwrite) BOOL hidden;

+ (id)declinationValueWithNumericalValue:(NSNumber *)numVal;
- (id)initWithNumericalValue:(NSNumber *)numVal;

@end


