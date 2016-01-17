
#import "VTCommand.h"
#import "VTConnection.h"
#import "VTDevice.h"
#import "VTFirmwareFile.h"
#import "VTGlobals.h"
#import "VTRecord.h"

#include <IOKit/usb/IOUSBLib.h>

@interface VTDevice () {
  NSDictionary *_usbProperties;
}
// The open connection to the device.
@property(nonatomic, readonly, retain) VTConnection *connection;

// Private designated initializer.
- (instancetype)initWithConnection:(VTConnection *)connection
                     usbProperties:(NSDictionary *)usbProperties;
@end

@interface VTDeviceGeneration3 : VTDevice {
  NSString *_firmwareVersion;
  NSDictionary *_deviceSettings;
}
@end

@interface VTDeviceSpeedPuck : VTDeviceGeneration3 {
}
@end
@interface VTDeviceProStart : VTDeviceGeneration3 {
}
@end

@interface VTDeviceS10 : VTDevice {
}
@end
@interface VTDeviceSC1 : VTDevice {
}
@end

@implementation VTDevice
static NSDictionary *productIDToClass = nil;

@synthesize connection = _connection;

#pragma mark - Class methods
+ (void)initialize {
  if (self != [VTDevice self]) {
    return;
  }

  productIDToClass = [[NSDictionary alloc]
      initWithObjectsAndKeys:[VTDeviceSpeedPuck class],
                             [NSNumber numberWithInt:0xb709],
                             [VTDeviceProStart class],
                             [NSNumber numberWithInt:0xb70a],
                             [VTDeviceS10 class],
                             [NSNumber numberWithInt:0x6001],
                             [VTDeviceSC1 class],
                             [NSNumber numberWithInt:0xb708], nil];
}

+ deviceForUSBProperties:(NSDictionary *)usbProperties {
  int productID = [[usbProperties objectForKey:@kUSBProductID] intValue];
  NSAssert(productID, @"No productID");
  id klass = [productIDToClass objectForKey:[NSNumber numberWithInt:productID]];
  if (!klass) {
    return nil;
  }
  int vendorID = [[usbProperties objectForKey:@kUSBVendorID] intValue];
  NSAssert(vendorID, @"No vendor ID");
  NSString *serial = [usbProperties objectForKey:@kUSBSerialNumberString];
  NSAssert(serial, @"No serial number");

  VTConnection *connection = [VTConnection connectionWithVendorID:vendorID
                                                        productID:productID
                                                     serialNumber:serial];
  if (!connection) {
    return nil;
  }
  return [[[klass alloc] initWithConnection:connection
                              usbProperties:usbProperties] autorelease];
}

#pragma mark - Init

- (instancetype)initWithConnection:(VTConnection *)connection
                     usbProperties:(NSDictionary *)usbProperties {
  _connection = [connection retain];
  _usbProperties = [usbProperties copy];

  return self;
}

- (void)dealloc {
  [_connection release];
  _connection = nil;
  [_usbProperties release];
  _usbProperties = nil;
  [super dealloc];
}

#pragma mark - Public methods

- (NSString *)serial {
  return [_usbProperties objectForKey:@kUSBSerialNumberString];
}

- (NSString *)model {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
  return nil;
}

- (NSString *)firmwareVersion {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
  return nil;
}

- (NSDictionary *)deviceSettings {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
  return nil;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (NSArray *)trackpointLogs {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
  return nil;
}

- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
  return nil;
}

- (BOOL)updateFirmware:(NSString *)filePath {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);

  return FIRMWARE_UPDATE_FAILED;
}

- (void)eraseAll {
  // For subclassers to implement
  VTRaiseAbstractMethodException(self, _cmd, [VTDevice self]);
}

- (NSString *)description {
  NSString *sd = [super description];
  NSString *s = [self serial];
  NSString *fv = [self firmwareVersion];

  return [NSString stringWithFormat:@"%@ (%@, %@)", sd, s, fv];
}

@end

@implementation VTDeviceS10

- (NSString *)model {
  return @"S10";
}

- (NSString *)firmwareVersion {
  // There is no way to get the firmware version of the S10. Just return the
  // known version
  return @"1.1";
}

@end

@implementation VTDeviceSC1
// The legacy method of determining firmware version was to get a user
// information record and decode the byte storing firmware version. However
// getting a command involves knowing the firmware version which we do not know
// yet. Kind of a catch 22 here.
//
// The new method is a simple command, as used on the puck.
//
- (NSString *)model {
  return @"SC1";
}

@end

// This is an abstract class
@implementation VTDeviceGeneration3

- (void)dealloc {
  [_firmwareVersion release];
  _firmwareVersion = nil;
  [_deviceSettings release];
  _deviceSettings = nil;
  [super dealloc];
}

- (NSString *)firmwareVersion {
  if (!_firmwareVersion) {
    VTCommand *firmwareVersionCommand =
        [VTCommand commandWithSignal:'V'
                           parameter:nil
                         resultClass:[VTFirmwareVersionRecord class]];
    VTFirmwareVersionRecord *result =
        (VTFirmwareVersionRecord *)[self.connection
            runCommand:firmwareVersionCommand];

    _firmwareVersion = [[result version] copy];
  }
  return _firmwareVersion;
}

- (NSArray *)trackpointLogs {
  VTCommand *trackpointLogsCommand =
      [VTCommand commandWithSignal:'O'
                         parameter:nil
                      resultsClass:[VTTrackpointLogRecord class]];
  NSArray *records =
      (NSArray *)[self.connection runCommand:trackpointLogsCommand];
  return records;
}

- (NSArray *)trackpoints:(NSDate *)downloadFrom endTime:(NSDate *)downloadTo {
  VTReadTrackpointsCommandParameter *commandParameter =
      [VTReadTrackpointsCommandParameter commandParameterFromDate:downloadFrom
                                                           toDate:downloadTo];

  VTCommand *command = [VTCommand commandWithSignal:'T'
                                          parameter:commandParameter
                                       resultsClass:[VTTrackpointRecord class]];

  NSArray *records = (NSArray *)[self.connection runCommand:command];
  return records;
}

- (void)eraseAll {
  [self.connection
      runCommand:[VTCommand commandWithSignal:'E'
                                    parameter:nil
                                  resultClass:[VTCommandResultRecord class]]];
}

- (BOOL)updateFirmware:(NSString *)filePath {
  VTFirmwareFile *firmwareFile =
      [VTFirmwareFile vtFirmwareFileWithFilePath:filePath];
  return [self.connection runFirmwareUpdate:firmwareFile];
}

@end

@implementation VTDeviceSpeedPuck

- (NSString *)model {
  return @"SpeedPuck";
}

- (NSDictionary *)deviceSettings {
  if (!_deviceSettings) {
    VTPuckSettingsRecord *result = (VTPuckSettingsRecord *)[self.connection
        runCommand:[VTCommand commandWithSignal:'S'
                                      parameter:nil
                                    resultClass:[VTPuckSettingsRecord class]]];

    _deviceSettings = [[result settingsDictionary] copy];
  }
  return _deviceSettings;
}

- (void)setDeviceSettings:(NSDictionary *)settings {
  [self.connection
      runCommand:[VTCommand commandWithSignal:'D'
                                    parameter:[VTPuckSettingsRecord
                                                  recordFromSettingsDictionary:
                                                      settings]
                                  resultClass:[VTCommandResultRecord class]]];

  [_deviceSettings release];
  _deviceSettings = nil;
}

@end

@implementation VTDeviceProStart
- (NSString *)model {
  return @"ProStart";
}
@end
