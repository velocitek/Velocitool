//
//  VTConvert.m
//  Velocitool
//
//  Created by Eric Noyau on 20/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
                              [NSNumber numberWithChar:(char)bytes[1]],    @"declinaison",
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
        [NSNumber numberWithChar:0],    @"declinaison",
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
    buffer[ii++] = [[fullSettings objectForKey:@"declinaison"] charValue];
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


/*
 float conversion use ldexp(), frexp().
 NAME
 ldexp -- multiply by integer power of 2
 
 SYNOPSIS
 #include <math.h>
 
 double
 ldexp(double x, int n);
 
 long double
 ldexpl(long double x, int n);
 
 float
 ldexpf(float x, int n);
 
 DESCRIPTION
 The ldexp() functions multiply x by 2 to the power n.
 
 SPECIAL VALUES
 ldexp(+-0, n) returns +-0.
 
 ldexp(x, 0) returns x.
 
 ldexp(+-infinity, n) returns +-infinity.
 
 SEE ALSO
 math(3), scalbn(3)
 
 STANDARDS
 The ldexp() functions conform to ISO/IEC 9899:1999(E).
 
 
 
 On both Intel and PPC macs, the type float corresponds to IEEE-754 single
 precision.  A single-precision number is represented in 32 bits, and has a
 precision of 24 significant bits, roughly like 7 significant decimal dig-
 its.  8 bits are used to encode the exponent, which gives an exponent range
 from -126 to 127, inclusive.
 
 The header <float.h> defines several useful constants for the float type:
 FLT_MANT_DIG - The number of binary digits in the significand of a float.
 FLT_MIN_EXP - One more than the smallest exponent available in the float
 type.
 FLT_MAX_EXP - One more than the largest exponent available in the float
 type.
 FLT_DIG - the precision in decimal digits of a float.  A decimal value with
 this many digits, stored as a float, always yields the same value up to
 this many digits when converted back to decimal notation.
 FLT_MIN_10_EXP - the smallest n such that 10**n is a non-zero normal number
 as a float.
 FLT_MAX_10_EXP - the largest n such that 10**n is finite as a float.
 FLT_MIN - the smallest positive normal float.
 FLT_MAX - the largest finite float.
 FLT_EPSILON - the difference between 1.0 and the smallest float bigger than
 1.0.
 
 */

@end

