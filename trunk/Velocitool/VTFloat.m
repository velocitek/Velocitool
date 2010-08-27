//
//  VTFloat.m
//  Velocitool
//
//  Created by Alec Stewart on 3/26/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTFloat.h"


@implementation VTFloat

@synthesize floatingPointNumber;
@synthesize picFloatRepresentation;

+ (id)vtFloatWithPicBytes:(NSData *)bytes
{
	
	VTFloat *velocitekFloat = [[self alloc] init];
	
	[velocitekFloat setPicFloatRepresentation:bytes];
	
	[velocitekFloat autorelease];
	
	return velocitekFloat;
}

+ (id)vtFloatWithFloat:(float)f
{
	VTFloat *velocitekFloat = [[self alloc] init];
	
	[velocitekFloat setFloatingPointNumber:f];
	
	[velocitekFloat autorelease];
	
	return velocitekFloat;
	 
}

- (id) init
{
	[super init];	
	return self;
}

- (void)dealloc
{
	
	[picFloatRepresentation release];
	[super dealloc];
}

- (NSString *)description
{
	NSString *description_string;
	NSString *floatDescriptionString;
	NSString *picRepresentationDescriptionString;
	
	floatDescriptionString = [NSString stringWithFormat:@"Float value: %f", floatingPointNumber];
	picRepresentationDescriptionString = [NSString stringWithFormat:@"Representation on PIC: %@", [picFloatRepresentation description]];
	
	description_string = [NSString stringWithFormat:@"%@\n%@\n", floatDescriptionString, picRepresentationDescriptionString];
	
	return description_string;
	
}	

-(void)setFloatingPointNumber:(float)f
{
	floatingPointNumber = f;
	
	//Now define the representation of the float in the PIC (GPS device microcontroller) memory	
	unsigned char result[NUM_BYTES_IN_PIC_FLOAT];
	unsigned char floatAsBytes[NUM_BYTES_IN_PIC_FLOAT];

	//This pointer points to the first of the four constituent bytes that make up the float
	unsigned char *pointerToFirstConstituentByte = (unsigned char*)(&floatingPointNumber);

	//Put the values of each of the four bytes that make up the float into the floatAsBytes array
	int i;
	for(i = 0; i < NUM_BYTES_IN_PIC_FLOAT; i++)
	{
		
		floatAsBytes[i] = *(pointerToFirstConstituentByte + i);
		
	}

	
	unsigned char signBit = floatAsBytes[3] & 0x80;
	unsigned char exponent = ((floatAsBytes[3] & 0x7F) << 1) + ((floatAsBytes[2] & 0x80) >> 7);
	
	result[0] = exponent;
	result[1] = signBit + (floatAsBytes[2] & 0x7F);
	result[2] = floatAsBytes[1];
	result[3] = floatAsBytes[0];

	[picFloatRepresentation release];
	
	picFloatRepresentation = [NSData dataWithBytes:result length:NUM_BYTES_IN_PIC_FLOAT];
	
	[picFloatRepresentation retain];
	
}

-(void)setPicFloatRepresentation:(NSData *)dataFromPic
{
	[dataFromPic retain];
	[picFloatRepresentation release];
	picFloatRepresentation = dataFromPic;
	
	//Now adjust the floatingPointNumber property to match this new picFloatRepresentation
	unsigned char bytesFromPic[NUM_BYTES_IN_PIC_FLOAT];	
	unsigned char floatingPointNumberBytes[NUM_BYTES_IN_PIC_FLOAT];
	
	
	[dataFromPic getBytes:bytesFromPic length:NUM_BYTES_IN_PIC_FLOAT];
	
	unsigned char exponent = bytesFromPic[0];
	unsigned char signBit = bytesFromPic[1] & 0x80;
	
	//Rearrange the bytes to convert from the PIC representation of a float to the IEEE-754 single precision representation
	floatingPointNumberBytes[3] = signBit + ((exponent & 0xFE) >> 1);
	floatingPointNumberBytes[2] = ((exponent & 0x01) << 7) + (bytesFromPic[1] & 0x7F);
	floatingPointNumberBytes[1] = bytesFromPic[2];
	floatingPointNumberBytes[0] = bytesFromPic[3];
	
	float* pointerToFloat;
	
	//Set the pointer to the beginning of the array that contains the four bytes we want to make the floatingPointNumber from
	pointerToFloat = (float*)(floatingPointNumberBytes);
	
	floatingPointNumber = *pointerToFloat;
}



@end
