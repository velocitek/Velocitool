//
//  VTFloat.h
//  Velocitool
//
//  Created by Alec Stewart on 3/26/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#define NUM_BYTES_IN_PIC_FLOAT 4

#import <Cocoa/Cocoa.h>

@interface VTFloat : NSObject {
	
	float floatingPointNumber;
	NSData *picFloatRepresentation;

}

@property(readwrite, assign) float floatingPointNumber;
@property(readwrite, retain) NSData *picFloatRepresentation;

+ (id)vtFloatWithPicBytes:(NSData *)bytes;
+ (id)vtFloatWithFloat:(float)f;

@end
