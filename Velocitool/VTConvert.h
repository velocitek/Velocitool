//
//  Convert.h
//  Velocitool
//
//  Created by Eric Noyau on 20/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VTSettings : NSObject {
}
+ (NSDictionary *)supportedSettingValues;

+ (NSData *)dataForSettingsDictionary:(NSDictionary *)settings;
+ (NSDictionary *)settingsDictionaryForData:(NSData *)settings;
+ (NSDictionary *)trackpointLogDictionaryForData:(NSData *)log;
@end

@interface VTPuckSettings : VTSettings {
}
@end
