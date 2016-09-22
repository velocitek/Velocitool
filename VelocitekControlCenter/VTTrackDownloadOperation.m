#import "VTTrackDownloadOperation.h"
#import "VTTrackFromDevice.h"
#import "VTDevice.h"
#import "VTRecord.h"
#import "VTProgressTracker.h"
#import "VTCapturedTrackElement.h"

@interface VTTrackDownloadOperation (private)
	
- (void)initializeProgressTracker;
	
@end

NSString *VTTrackFinishedDownloadingNotification = @"VTTrackFinishedDownloadingNotification";

@implementation VTTrackDownloadOperation

- (id)initWithTrackObject:(VTTrackFromDevice *)track;
{
  if ((self = [super init])) {
    trackpoints = [[NSMutableArray alloc] init];
    trackFromDevice = track;
    device = [track device];
    selectedTrackLogs = [track selectedTrackLogs];
  }
  return self;
}

- (void)main {
    
	NSArray *newTrackpoints;
	NSDate *start;
	NSDate *end;
	
	[self initializeProgressTracker];
	
	for(VTTrackpointLogRecord *trackpointLog in selectedTrackLogs)
	{
		
		start = [trackpointLog start];
		end = [trackpointLog end];
		
        NSLog(@"Downloading trackpoints. Start = %@, End = %@", [start description], [end description]);
        
        int expectedNumTrackpoints = trackpointLog.numTrackpoints;
        
        NSLog(@"Expecting %d trackpoints.", expectedNumTrackpoints);
        
        newTrackpoints = [self trackpointsHelper:nil expectedNumTrackpoint:expectedNumTrackpoints start:start end:end];
        
		[trackpoints addObjectsFromArray:newTrackpoints];
		
	}
	
	[trackFromDevice setTrackpoints:trackpoints];
	[trackFromDevice setNumTrackpoints:[trackpoints count]];
	[trackFromDevice setCapturedTrackXMLElement:[VTCapturedTrackElement capturedTrackElementWithTrackPointsAndDevice:trackpoints device:device]];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	//NSLog(@"Sending notification that the track has finished downloading");
	[notificationCenter postNotificationName:VTTrackFinishedDownloadingNotification object:self];

}

- (NSMutableArray*) trackpointsHelper:(NSMutableArray*)acc expectedNumTrackpoint:(unsigned long)expectedNumTrackpoints start:(NSDate*)start end:(NSDate*)end {
    
    NSLog(@"#tpts=%lul", expectedNumTrackpoints);
    NSLog(@"start=%fl", [start timeIntervalSinceReferenceDate]);
    NSLog(@"end  =%fl", [end timeIntervalSinceReferenceDate]);
    
    
    if (acc == nil) acc = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray * newTrackpoints = [device trackpoints:start endTime:end];
    
    NSLog(@"#downloaded = %lu", [newTrackpoints count]);
    
    [acc addObjectsFromArray:newTrackpoints];
    
    NSLog(@"#totak = %lu", [acc count]);

    if ([acc count] < expectedNumTrackpoints) {
        
        NSLog(@"#tpts=%lul", expectedNumTrackpoints);
        NSLog(@"start=%fl", [start timeIntervalSinceReferenceDate]);
        NSLog(@"end  =%fl", [end timeIntervalSinceReferenceDate]);
        
        // get last trackpoint
        VTTrackpointRecord *lastTrackpoint = [acc lastObject];
        
        // get date of last trackpoint
        NSDate *dateOfLastTrackpoint = lastTrackpoint.timestamp;
        
        // increment by 1 ms
        NSTimeInterval timeOfLastTrackpoint = [dateOfLastTrackpoint timeIntervalSinceReferenceDate];
        NSLog(@"last =%fl", timeOfLastTrackpoint);

        NSTimeInterval newTimeInterval = timeOfLastTrackpoint + 1.0;
        NSLog(@"newl =%fl",newTimeInterval);
        NSDate *datePlusOne =[NSDate dateWithTimeIntervalSinceReferenceDate:newTimeInterval];
        
        // rest
        [NSThread sleepForTimeInterval:1.0f];

        // call helper again
        return [self trackpointsHelper:acc expectedNumTrackpoint:expectedNumTrackpoints start:datePlusOne end:end];
        
    }
    
    return acc;
    
}

- (void)initializeProgressTracker
{
	float totalNumberOfTrackpointsToDownload = 0;
	for(VTTrackpointLogRecord *trackpointLog in selectedTrackLogs)
	{
		totalNumberOfTrackpointsToDownload = totalNumberOfTrackpointsToDownload + (float)[trackpointLog numTrackpoints];
	}
	
	
	[self setValue:[NSNumber numberWithFloat:0]
		forKeyPath:@"device._connection.progressTracker.currentProgress"];
	
	[self setValue:[NSNumber numberWithFloat:totalNumberOfTrackpointsToDownload]
		forKeyPath:@"device._connection.progressTracker.goal"];
	
}

@end
