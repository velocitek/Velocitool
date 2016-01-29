/*
 * This class is a first draft and currently UNUSED! See VTConnection instead.
 */

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
