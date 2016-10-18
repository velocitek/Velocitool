#define MAX_NUM_CHARS_IN_FIRMWARE_FILE 200000

//#define ALL_DEVICES
//#define LOAD_DEVICE
//#define TRACKPOINT_SAVE
//#define FIRMWARE_UPDATE
//#define FILE_READ
//#define FIRMWARE_VERSION_READ
//#define SERIAL_NUMBER_READ
//#define TRACKPOINT_LOG_READ
//#define TRACKPOINTS_READ
//#define PROGRESS_TRACKER
//#define DEVICE_SETTINGS
//#define XSLT_TEST
//#define DATE_TEST
//#define LAUNCH_GPSAR_TEST
#define CONVERT_TIMESTAMP


#import <Cocoa/Cocoa.h>
#import "VTDateTime.h"

void convertTimestamp(double timestamp);

int main (int argc, const char * argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    NSArray * theArgs = [[NSProcessInfo processInfo] arguments];
    
    NSString * arg1 = theArgs[1];
    
    NSTimeInterval interval = (double)[arg1 intValue];
    
    convertTimestamp(interval);
    
    [pool drain];
    return 0;
}

void convertTimestamp(NSTimeInterval timestamp) {
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:timestamp];
    VTDateTime *vtDateTime = [VTDateTime vtDateWithDate:date];
    DDLogDebug(@"timestamp = %f", timestamp);
    DDLogDebug(@"date      = %@", [date description]);
    DDLogDebug(@"vtDate    = %@", [vtDateTime description]);
}
