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

- (NSMutableArray*) addObjectsWithoutOverlap: (NSMutableArray*) acc toAdd:(NSArray*) newPoints {
    
    VTTrackpointRecord * last = [acc lastObject];
    NSTimeInterval lastTimestamp = last.timestamp.timeIntervalSinceReferenceDate;
    
    NSMutableArray * newPointsMutable = [newPoints mutableCopy];
    
    VTTrackpointRecord * currentRecord;
    
    int i;
    for (i=0;i<(int)newPoints.count;i++) {
        currentRecord = [newPoints objectAtIndex:i];
        if (currentRecord.timestamp.timeIntervalSinceReferenceDate > lastTimestamp) {
            break;
        }
    }
    
    NSLog(@"Discarding %d overlapping track points.", i);
    
    
    [newPointsMutable removeObjectsInRange:NSMakeRange(0, i)];
    
    [acc addObjectsFromArray:newPointsMutable];
    
    return acc;
}

- (NSMutableArray*) trackpointsHelper:(NSMutableArray*)acc expectedNumTrackpoint:(unsigned long)expectedNumTrackpoints start:(NSDate*)start end:(NSDate*)end {
    
    NSLog(@"expected num trackpoint =%lu", expectedNumTrackpoints);
    NSLog(@"start=%fl - %@", [start timeIntervalSinceReferenceDate], [start description]);
    NSLog(@"end  =%fl - %@", [end timeIntervalSinceReferenceDate], [end description]);
    
    
    if (acc == nil) acc = [[NSMutableArray alloc] init];
    
    NSArray * newTrackpoints = [device trackpoints:start endTime:end];
    
    NSLog(@"#new downloaded = %lu", [newTrackpoints count]);
    
    //[acc addObjectsFromArray:newTrackpoints];
    
    acc = [self addObjectsWithoutOverlap:acc toAdd:newTrackpoints];
    
    NSLog(@"#total in accumulator = %lu", [acc count]);

    if ([acc count] < expectedNumTrackpoints) {
        
        NSLog(@"#tpts=%lu", expectedNumTrackpoints);
        NSLog(@"start=%fl", [start timeIntervalSinceReferenceDate]);
        NSLog(@"end  =%fl", [end timeIntervalSinceReferenceDate]);
        
        // get last trackpoint
        VTTrackpointRecord *lastTrackpoint = [acc lastObject];
        
        // get date of last trackpoint
        NSDate *dateOfLastTrackpoint = lastTrackpoint.timestamp;
        
        // increment by 1 ms
        NSTimeInterval timeOfLastTrackpoint = [dateOfLastTrackpoint timeIntervalSinceReferenceDate];
        NSLog(@"timeOfLastTrackpoint =%fl", timeOfLastTrackpoint);

        NSTimeInterval newTimeInterval = timeOfLastTrackpoint + 1.0;
        NSLog(@"timeOfLastTrackpoint+1 =%fl",newTimeInterval);
        NSDate *datePlusOne =[NSDate dateWithTimeIntervalSinceReferenceDate:newTimeInterval];
        
        // This reads any lingering data from the connection and resets it by opening and closing the connection
        [device recoverDeviceConnection];
        
        // rest
        [NSThread sleepForTimeInterval:1.0f];
        
        if ([datePlusOne timeIntervalSinceReferenceDate] >= [end timeIntervalSinceReferenceDate]) return acc;

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
