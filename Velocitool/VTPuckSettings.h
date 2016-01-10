
#import <Cocoa/Cocoa.h>

@interface VTPuckSettings : NSObject {
    NSMutableDictionary *_settings;
}

@property (nonatomic, retain) id recordRate;
@property (nonatomic, retain) id declination;
@property (nonatomic, retain) id speedUnitOfMeasurement;
@property (nonatomic, retain) id speedDamping;
@property (nonatomic, retain) id headingDamping;
@property (nonatomic, retain) id maxSpeedMode;
@property (nonatomic, retain) id barGraphEnabled;
@property (nonatomic, retain) id deviceOperationOption;

@property (nonatomic, readonly) NSString *barGraphLabel;
@property (nonatomic, readonly) BOOL barGraphState;
@property (nonatomic, readonly) BOOL compassEnabled;
@property (nonatomic, readonly) BOOL everythingOff;

+ (VTPuckSettings *)settingsWithDictionary:(NSDictionary *)settings;
- (NSDictionary *)settingsDictionary;

@end

