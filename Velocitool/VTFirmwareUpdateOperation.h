//
//  VTFirmwareUpdateOperation.h
//  Velocitool
//
//  Created by Alec Stewart on 6/28/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;


@interface VTFirmwareUpdateOperation : NSOperation 
{
	
	VTDevice *device;
	BOOL done;
	BOOL success;

}

@property (nonatomic, readwrite) BOOL done;
@property (nonatomic, readwrite) BOOL success;

- (id)initWithDevice:(VTDevice*)deviceToUpdate;

@end



