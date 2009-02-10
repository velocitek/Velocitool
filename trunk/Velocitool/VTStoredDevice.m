//
//  VTStoredDevice.m
//  Velocitool
//
//  Created by Eric Noyau on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VTStoredDevice.h"
#import "VTDevice.h"
#import "VTDeviceLoader.h"


@implementation VTStoredDevice

- (void)_updateFromConnectedDevice {
    VTDevice *device = [[VTDeviceLoader loader] deviceForSerialNumber:[self serial]];

    if (![self name]) {
        [self setName:[self serial]];
    }
    [self setIdentity:[NSString stringWithFormat:@"%@ (%@)", [device model], [device firmwareVersion]]];
    
    NSString *path = nil;
    for (NSString *ext in [NSArray arrayWithObjects:@"icns", @"jpg", nil]) {
        path = [[NSBundle mainBundle] pathForResource:[device model] ofType:ext];
        NSLog(@"path for ext/Model %@/%@ %@", ext, [device model], path);
        if (path) {
            break;
        }
    }
    [self setImagePath:path];
    NSLog(@"All updated! %@ %@", [self identity], [self imagePath]);
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self _updateFromConnectedDevice];
}

- (void)setSerial:(NSString *)value 
{
    [self willChangeValueForKey:@"serial"];
    [self setPrimitiveValue:value forKey:@"serial"];
    [self didChangeValueForKey:@"serial"];
    [self _updateFromConnectedDevice];
}

@end



