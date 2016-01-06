#import "VTPuckSettings.h"
#import "VTGlobals.h"

@implementation VTPuckSettings

- recordRate {
    return [_settings objectForKey:VTRecordRatePref];
}
- (void)setRecordRate:value {
    [_settings setObject:value forKey:VTRecordRatePref];
}

- declination {
    if ([self compassEnabled]) {
        return [_settings objectForKey:VTDeclinationPref];
    } else {
        return [NSNumber numberWithInt:0];
    }
}
- (void)setDeclination:value {
    [_settings setObject:value forKey:VTDeclinationPref];
}

- speedUnitOfMeasurement {
    return [_settings objectForKey:VTSpeedUnitPref];
}
- (void)setSpeedUnitOfMeasurement:value {
    [_settings setObject:value forKey:VTSpeedUnitPref];
}

-  speedDamping {
    return [_settings objectForKey:VTSpeedDampingPref];
}
- (void)setSpeedDamping:value {
    [_settings setObject:value forKey:VTSpeedDampingPref];
}

- headingDamping {
    if ([self compassEnabled]) {
        return [_settings objectForKey:VTHeadingDampingPref];
    } else {
        return [NSNumber numberWithInt:0];
    }
}
- (void)setHeadingDamping:value {
    [_settings setObject:value forKey:VTHeadingDampingPref];
}

- maxSpeedMode {
    return [_settings objectForKey:VTMaxSpeedPref];
}
- (void)setMaxSpeedMode:value {
    [_settings setObject:value forKey:VTMaxSpeedPref];
}

- barGraphEnabled {
    return [_settings objectForKey:VTBarGraphPref];
}
- (void)setBarGraphEnabled:value {
    [_settings setObject:value forKey:VTBarGraphPref];
}

- deviceOperationOption {
    return [_settings objectForKey:VTPuckModePref];
}
- (void)setDeviceOperationOption:value {
    [_settings setObject:value forKey:VTPuckModePref];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *set = nil;
    
    if ([key isEqual:@"barGraphLabel"] || [key isEqual:@"barGraphState"] || 
        [key isEqual:@"compassEnabled"] || [key isEqual:@"everythingOff"] ||
        [key isEqual:@"declination"]  || [key isEqual:@"headingDamping"]) {
        
        set = [NSSet setWithObjects:@"deviceOperationOption",  nil];
    }
    return set;
}

- (NSString *)barGraphLabel {
    switch ([[self deviceOperationOption] intValue]) {
        case VTPuck1_4ModeNormal:
            return @"Show lift/header indicator";
            break;
        case VTPuck1_4ModeMotor:
            return @"Speed bars enabled";
            break;
        default:
            return @"Bar graph visibility";
            break;
    }
}

- (BOOL)barGraphState {
    return [[self deviceOperationOption] intValue] != VTPuck1_4ModeBlank;
}

- (BOOL)compassEnabled {
    return [[self deviceOperationOption] intValue] == VTPuck1_4ModeNormal;
}

- (BOOL)everythingOff {
    return [[self deviceOperationOption] intValue] == VTPuck1_4ModeBlank;
}

+ (VTPuckSettings *)settingsWithDictionary:(NSDictionary *)settings {
    VTPuckSettings *ps = [[[VTPuckSettings alloc] init] autorelease];
    
    ps->_settings = [settings mutableCopy];
    return ps;
}

- (NSDictionary *)settingsDictionary {
    return _settings;
}

- (void)dealloc {
    [_settings release]; _settings = nil;
    [super dealloc];
}

@end
