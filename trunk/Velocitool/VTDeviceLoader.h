//
//  DeviceLoader.h
//  Velocitool
//
//  Created by Eric Noyau on 07/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Triggered when at least one device is plugged in or disconnected. Call -devices to get them.
extern NSString *VTDeviceChangedNotification;

@interface VTDeviceLoader : NSObject {
    NSMutableDictionary *_devices;
}

+ loader;
- (NSArray *)devices; // Returns an array of currently pluged in VTDevices 

@end
