#import <Cocoa/Cocoa.h>
@class VTDevice;
@class VTCapturedTrackElement;

@interface VTTrackFromDevice : NSObject {
	
	VTDevice *device;
	NSMutableArray *selectedTrackLogs;
	NSMutableArray *trackpoints;
	NSUInteger numTrackpoints;
	VTCapturedTrackElement *capturedTrackXMLElement;
		
	NSOperationQueue *queue;

}

@property (nonatomic, readonly) VTDevice *device;
@property (nonatomic, readonly) NSMutableArray *selectedTrackLogs;
@property (nonatomic, readwrite, strong) NSMutableArray *trackpoints;
@property (nonatomic, readwrite) NSUInteger numTrackpoints;
@property (nonatomic, readwrite, strong) VTCapturedTrackElement *capturedTrackXMLElement;

- (id) initWithDeviceAndTrackLogs:(VTDevice *)device trackLogs:(NSMutableArray *)trackLogs;
- (void) handleCancelDownload:(NSNotification*) notification;

@end
