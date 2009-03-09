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
#import "VTPuckSettings.h"


@implementation VTStoredDevice

- (VTDevice *)_getDevice {
    return [[VTDeviceLoader loader] deviceForSerialNumber:[self serial]];
}

- (void)_updateFromConnectedDevice {
    VTDevice *device = [self _getDevice] ;

    if (![self name]) {
        [self setName:[self serial]];
    }
    [self setIdentity:[NSString stringWithFormat:@"%@ (%@)", [device model], [device firmwareVersion]]];
    
    NSString *path = nil;
    for (NSString *ext in [NSArray arrayWithObjects:@"icns", @"jpg", nil]) {
        path = [[NSBundle mainBundle] pathForResource:[device model] ofType:ext];
        if (path) {
            break;
        }
    }
    [self setImagePath:path];
    
    deviceSettings = nil;
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


- (VTPuckSettings *)puckSettings {
    VTDevice *device = [self _getDevice];
    
    if (!deviceSettings && ([[device model] isEqual:@"SpeedPuck"] || [[device model] isEqual:@"FakeStuff"])) {
        deviceSettings = [[VTPuckSettings settingsWithDictionary:[device deviceSettings]] retain];
    }
    return deviceSettings ;
}

- (IBAction)saveSettings:target {
    VTDevice *device = [self _getDevice];

    [device setDeviceSettings:[deviceSettings settingsDictionary]];
}

- (IBAction)cancelSettings:target {
    [deviceSettings release]; deviceSettings = nil; // Will request them again.
}

- (void)dealloc {
    [deviceSettings release]; deviceSettings = nil;
    [super dealloc];
}


@end



