/*
 * This class is a first draft and currently UNUSED! See VTConnection instead.
 */

#import "VTConvert.h"
#import "VTGlobals.h"

typedef struct enum_struct {
    char value;
    BOOL active;
    NSString *description;
} EnumStruct;

static EnumStruct recordRate[] = { 
    { 1, NO,  @"All"},
    { 2, YES, @"Every two"},
    { 4, YES, @"Every four"},
    { 8, YES, @"Every eight"},
    {16, YES, @"Every sixteen"},
};

static EnumStruct speedUnits[] = { 
    { 1, YES, @"Knots"},
    { 2, YES, @"Miles per hour"},
    { 3, YES, @"Kilometers per hour"},
    { 4, YES, @"Meters per seconds"},
};

static EnumStruct barGraphMode[] = { 
    { 0, YES, @"Disabled"},
    { 1, YES, @"Enabled"},
};

static EnumStruct deviceOperation[] = { 
    { 0, YES, @"Normal"},
    { 1, YES, @"Motor sport"},
    { 2, YES, @"Blank"},
};

static EnumStruct maxSpeedMode[] = { 
    { 0, YES, @"Max"},
    { 1, YES, @"Ten second Average"},
    { 2, YES, @"Both"},
};


@implementation VTSettings : NSObject

+ (NSDictionary *)supportedSettingValues {
    VTRaiseAbstractMethodException(self, _cmd, [VTSettings self]);
    return nil;
}

+ (NSData *)dataForSettingsDictionary:(NSDictionary *)settings {
    VTRaiseAbstractMethodException(self, _cmd, [VTSettings self]);
    return nil;
}

+ (NSDictionary *)settingsDictionaryForData:(NSData *)settings {
    VTRaiseAbstractMethodException(self, _cmd, [VTSettings self]);
    return nil;
}

+ (NSDictionary *)trackpointLogDictionaryForData:(NSData *)log {
    VTRaiseAbstractMethodException(self, _cmd, [VTSettings self]);
    return nil;
}

@end

@implementation VTPuckSettings : VTSettings 

+ (NSDictionary *)settingsDictionaryForData:(NSData *)settings {
    
    if (settings && [settings length] == 8) {
        const unsigned char *bytes = [settings bytes];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedChar:bytes[0]],  @"recordRate",
                              [NSNumber numberWithChar:(char)bytes[1]],    @"declination",
                              [NSNumber numberWithUnsignedChar:bytes[2]],  @"speedUnitOfMeasurement",
                              [NSNumber numberWithUnsignedChar:bytes[3]],  @"speedDamping",
                              [NSNumber numberWithUnsignedChar:bytes[4]],  @"headingDamping",
                              [NSNumber numberWithUnsignedChar:bytes[5]],  @"maxSpeedMode",
                              [NSNumber numberWithBool:(BOOL)bytes[6]],    @"barGraphOption",
                              [NSNumber numberWithUnsignedChar:bytes[7]],  @"deviceOperationOption",
                              nil
        ];
        return dict;
    }
    return nil;
}


+ (NSData *)dataForSettingsDictionary:(NSDictionary *)settings {
    unsigned char buffer[8];
    
    NSMutableDictionary *fullSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedChar:4],  @"recordRate",
        [NSNumber numberWithChar:0],    @"declination",
        [NSNumber numberWithUnsignedChar:1],  @"speedUnitOfMeasurement",
        [NSNumber numberWithUnsignedChar:1],  @"speedDamping",
        [NSNumber numberWithUnsignedChar:1],  @"headingDamping",
        [NSNumber numberWithUnsignedChar:1],  @"maxSpeedMode",
        [NSNumber numberWithBool:YES],    @"barGraphOption",
        [NSNumber numberWithUnsignedChar:0],  @"deviceOperationOption",
        nil
    ];
    
    if (settings) {
        [fullSettings addEntriesFromDictionary:settings];
    }
    int ii = 0;
    buffer[ii++] = [[fullSettings objectForKey:@"recordRate"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"declination"] charValue];
    buffer[ii++] = [[fullSettings objectForKey:@"speedUnitOfMeasurement"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"speedDamping"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"headingDamping"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"maxSpeedMode"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"barGraphOption"] unsignedCharValue];
    buffer[ii++] = [[fullSettings objectForKey:@"deviceOperationOption"] unsignedCharValue];
    
    return [NSData dataWithBytes:buffer length:8];
}


+ (NSDictionary *)trackpointLogDictionaryForData:(NSData *)log {
    VTRaiseAbstractMethodException(self, _cmd, [VTSettings self]);
    if (log && [log length] == 19) {
        const unsigned char *bytes = [log bytes];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedChar:bytes[0]],  @"logIndex",
                              [NSNumber numberWithUnsignedChar:(((int)bytes[1]) << 8) + bytes[2]],  @"trackpointCount",
                              [NSNumber numberWithChar:(char)bytes[1]],    @"starttime",
                              [NSNumber numberWithUnsignedChar:bytes[2]],  @"endtime",
                              [NSNumber numberWithUnsignedChar:bytes[3]],  @"speedDamping",
                              [NSNumber numberWithUnsignedChar:bytes[4]],  @"headingDamping",
                              [NSNumber numberWithUnsignedChar:bytes[5]],  @"maxSpeedMode",
                              [NSNumber numberWithBool:(BOOL)bytes[6]],    @"barGraphOption",
                              [NSNumber numberWithUnsignedChar:bytes[7]],  @"deviceOperationOption",
                              nil
                              ];
        return dict;
    }
    return nil;
}



@end

