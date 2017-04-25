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
#import "ftd2xx.h"

void convertTimestamp(double timestamp);

int main (int argc, const char * argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    NSArray * theArgs = [[NSProcessInfo processInfo] arguments];
    
    NSString * arg1 = theArgs[1];
    
    NSTimeInterval interval = (double)[arg1 intValue];
    
    FT_STATUS ft_error;
    FT_HANDLE ft_handle;
    
    DWORD vid = 0x0403;
    DWORD pid = 0xb70a;
    
    DWORD       libVersion = 0;
    
    
    // Make sure the library can find the device I want.
    ft_error = FT_SetVIDPID(vid, pid);
    
    if(ft_error != FT_OK) {
        NSLog(@"VTError: Call to FT_SetVIDPID failed with error %u", ft_error);
        return false;
    }
    
    DWORD       totalDevices = 0;
    
    ft_error = FT_ListDevices(&totalDevices, NULL, FT_LIST_NUMBER_ONLY);
    
    if(ft_error != FT_OK) {
        printf("Error: FT_ListDevices(%d)\n", (int)ft_error);
        return 1;
    }

    
    [pool drain];
    return 0;
}

/*
void convertTimestamp(NSTimeInterval timestamp) {
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:timestamp];
    VTDateTime *vtDateTime = [VTDateTime vtDateWithDate:date];
    DDLogDebug(@"timestamp = %f", timestamp);
    DDLogDebug(@"date      = %@", [date description]);
    DDLogDebug(@"vtDate    = %@", [vtDateTime description]);
}
*/
