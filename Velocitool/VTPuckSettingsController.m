//
//  VTPuckSettingsController.m
//  Velocitool
//
//  Created by Eric Noyau on 02/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VTPuckSettingsController.h"
#import "VTGlobals.h"

@implementation VTPuckSettingsController

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *set;
    
    if ([key isEqual:@"barGraphLabel"] || [key isEqual:@"barGraphEnabled"] || 
        [key isEqual:@"declinationEnabled"] || [key isEqual:@"everythingOff"])
    
        set = [NSSet setWithObjects:
               @"selection",
               VTPuckModePref,
               [NSString stringWithFormat:@"%@.%@", @"selection", VTPuckModePref],
               nil
        ];
    else {
        set = [super keyPathsForValuesAffectingValueForKey:key];
    }
    
    NSLog(@"keys for key %@: %@", key, set);

    return set;
}



- (NSString *)barGraphLabel {
    switch ([[[self content] objectForKey:VTPuckModePref] intValue]) {
        case VTPuckModeNormal:
            return @"Show lift/header indicator";
            break;
        case VTPuckModeMotor:
            return @"Speed bars enabled";
            break;
        default:
            return @"Bar graph not visible";
            break;
    }
}

- (BOOL)barGraphEnabled {
    return [[[self content] objectForKey:VTPuckModePref] intValue] != VTPuckModeBlank;
}

- (BOOL)declinationEnabled {
    return [[[self content] objectForKey:VTPuckModePref] intValue] == VTPuckModeNormal;
}

- (BOOL)everythingOff {
    return [[[self content] objectForKey:VTPuckModePref] intValue] == VTPuckModeBlank;
}

@end
