#import <Cocoa/Cocoa.h>
@class VTTrackFromDevice;
@class VTDevice;

extern NSString *VTTrackFinishedDownloadingNotification;
extern NSString *VTTrackCancelDownloadNotification;

@interface VTTrackDownloadOperation : NSOperation {
	
	VTTrackFromDevice *trackFromDevice;
	VTDevice *device;
	NSMutableArray *selectedTrackLogs;
	NSMutableArray *trackpoints;	
}

- (id)initWithTrackObject:(VTTrackFromDevice*)track;

@end

