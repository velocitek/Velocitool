
#import <Cocoa/Cocoa.h>

@class VTRecord;
@class VTConnection;

@interface VTCommand : NSObject {
    unsigned char _signal;
    VTRecord *_parameter;
    Class _resultClass;
    BOOL _isList;
}
+ commandWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultClass:(Class)resultClass;
+ commandWithSignal:(unsigned char)signal parameter:(VTRecord *)parameter resultsClass:(Class)resultClass;
- (BOOL)flowControl;
- (unsigned char)signal;
- (VTRecord *)parameter;
- (Class)resultClass;
- (BOOL)returnsList;

@end


@interface VTRecord : NSObject {
}

+ (unsigned char)recordHeader;
- (void)writeDeviceDataForConnection:(VTConnection *)connection;
- (void)readDeviceDataFromConnection:(VTConnection *)connection;

@end


@interface VTCommandResultRecord: VTRecord {
}

@end


@interface VTPuckSettingsRecord : VTRecord {
    unsigned char _recordRate;
    char _declination;
    unsigned char _speedUnitOfMeasurement;
    unsigned char _speedDamping;
    unsigned char _headingDamping;
    unsigned char _maxSpeedMode;
    BOOL _barGraphEnabled;
    unsigned char _deviceOperationOption;
}

+ (VTPuckSettingsRecord *)recordFromSettingsDictionary:(NSDictionary *)settings;
- (NSDictionary *)settingsDictionary;
- (void)setSettingsDictionary:(NSDictionary *)settings;
    
@end


@interface VTFirmwareVersionRecord : VTRecord {
    NSString *_version;
}

- (NSString *)version;
@end


@interface VTTrackpointLogRecord : VTRecord {
    char _logIndex;
    int _trackpointCount;
    NSDate *_start; 
    NSDate *_end; 
}

@end
