
#import <Cocoa/Cocoa.h>

@interface VTPuckSettings : NSObject {
    NSMutableDictionary *_settings;
}

@property (retain) id recordRate;
@property (retain) id declination;
@property (retain) id speedUnitOfMeasurement;
@property (retain) id speedDamping;
@property (retain) id headingDamping;
@property (retain) id maxSpeedMode;
@property (retain) id barGraphEnabled;
@property (retain) id deviceOperationOption;

@property (readonly) NSString *barGraphLabel;
@property (readonly) BOOL barGraphState;
@property (readonly) BOOL compassEnabled;
@property (readonly) BOOL everythingOff;

+ (VTPuckSettings *)settingsWithDictionary:(NSDictionary *)settings;
- (NSDictionary *)settingsDictionary;

@end

