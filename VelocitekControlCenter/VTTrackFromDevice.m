#import "VTTrackFromDevice.h"
#import "VTDevice.h"
#import "VTRecord.h"
#import "VTConnection.h"
#import "VTProgressTracker.h"
#import "VTTrackDownloadOperation.h"
#import "VTCapturedTrackElement.h"

@interface VTTrackFromDevice (private)

- (void)removeUnselectedTrackLogs;
- (void)downloadTrack;
//- (void)initializeProgressTracker;

@end



@implementation VTTrackFromDevice

@synthesize device;
@synthesize selectedTrackLogs;
@synthesize trackpoints;
@synthesize numTrackpoints;
@synthesize capturedTrackXMLElement;

- (id)initWithDeviceAndTrackLogs:(VTDevice *)deviceToDownloadFrom trackLogs:(NSMutableArray *)trackLogs
{
	if ((self = [super init])) {

    trackpoints = [[NSMutableArray alloc] init];
    
    device = [deviceToDownloadFrom retain];	
    selectedTrackLogs = [trackLogs retain];
    
    [self removeUnselectedTrackLogs];
    
    [self downloadTrack];	
  }
	return self;
	
}

- (void)removeUnselectedTrackLogs
{
	unsigned int i = 0;
	
	VTTrackpointLogRecord *trackpointLog;
	
	for (i = 0; i < [selectedTrackLogs count]; i++)
	{
		trackpointLog = [selectedTrackLogs objectAtIndex:i];
		
		if (![trackpointLog selectedForDownload]) {
			
			[selectedTrackLogs removeObject:trackpointLog];
			//Decrement the loop counter to account for the fact that all the array elements have been shifted
			//backwards to fill the hole we just created by removing an element
			i--;
		}						
	}
	
}

- (void)downloadTrack
{
	queue = [[NSOperationQueue alloc] init];
	
	VTTrackDownloadOperation *trackDownloadOperation = [[VTTrackDownloadOperation alloc] initWithTrackObject:self];
	
	[queue addOperation:trackDownloadOperation];
	
	[trackDownloadOperation release];
			
}

- (void)dealloc
{
	[device release];
	[selectedTrackLogs release];
	[queue release], queue = nil;
	[super dealloc];
}

@end
