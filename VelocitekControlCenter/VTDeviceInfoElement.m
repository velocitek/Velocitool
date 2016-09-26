//
//  VTDeviceInfoElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTDeviceInfoElement.h"
#import "VTDevice.h"

@implementation VTDeviceInfoElement

+deviceInfoElementWithDevice:(VTDevice *) device
{
	VTDeviceInfoElement *deviceInfoElement = [[self alloc] initWithDevice:device];
	return deviceInfoElement;
	
}

- initWithDevice:(VTDevice *)device {
  if ((self = [super initWithKind:NSXMLElementKind])) {
    [self setName:@"DeviceInfo"];

    [self addAttribute:[NSXMLNode attributeWithName:@"ftdiSerialNumber"
                                        stringValue:[device serial]]];
  }
  return self;
}

@end
