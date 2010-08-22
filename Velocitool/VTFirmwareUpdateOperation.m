//
//  VTFirmwareUpdateOperation.m
//  Velocitool
//
//  Created by Alec Stewart on 6/28/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTFirmwareUpdateOperation.h"
#import "VTDevice.h"


@implementation VTFirmwareUpdateOperation

@synthesize done;
@synthesize success;

- (id)initWithDevice:(VTDevice*)deviceToUpdate
{
	
	if (![super init]) return nil;
	
	device = [deviceToUpdate retain];
	
	[self setDone: NO];
	[self setSuccess: NO];
	
	return self;
	
}

 

- (void)main 
{
    
	NSLog(@"Hello World!");
		
	//NOTE: Make sure this is the absolute path to where the firmware file is on your machine
	if([device updateFirmware:@"/Users/alec/Dropbox/Code/Velocitool/Velocitek_SpeedPuck_1-4.hex"])
	{
				
		NSLog(@"Success!");
		[self setSuccess: YES];
		
	}
	else 
	{
		NSLog(@"Failure... boo hoo!");
	}
	 
	[self setDone:YES];
	
	
}


@end
