//
//  VTDeviceInfoElement.h
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;

@interface VTDeviceInfoElement : NSXMLElement {

}

+deviceInfoElementWithDevice:(VTDevice *) device;

- initWithDevice:(VTDevice *) device;


@end
