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
NSString *VTTrackCancelDownloadNotification = @"VTTrackCancelDownloadNotification";

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
		
        DDLogInfo(@"Downloading trackpoints. Start = %@, End = %@", [start description], [end description]);
        
        int expectedNumTrackpoints = trackpointLog.numTrackpoints;
        
        DDLogInfo(@"Expecting %d trackpoints.", expectedNumTrackpoints);
        
        newTrackpoints = [self trackpointsHelper:nil expectedNumTrackpoint:expectedNumTrackpoints start:start end:end];
        
		[trackpoints addObjectsFromArray:newTrackpoints];
        
	}
    	
	[trackFromDevice setTrackpoints:trackpoints];
	[trackFromDevice setNumTrackpoints:[trackpoints count]];
	[trackFromDevice setCapturedTrackXMLElement:[VTCapturedTrackElement capturedTrackElementWithTrackPointsAndDevice:trackpoints device:device]];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:VTTrackFinishedDownloadingNotification object:self];

}

- (NSString*) dateInfo:(NSDate*) date {
    return [NSString stringWithFormat:@"%f - %@", [date timeIntervalSinceReferenceDate], [date description]];
}

/*
    I was running into a problem where the ProStart was sending back data for times that started
    before the start date, as if it was adding some pre-padding in the requested data. This
    was throwing off the restart after error algorithm and causing it to have extra, overlapping
    data at the restart points. 
 
    This method removes any overlapping data from newly read points before adding it to the 
    accumulator. This behavior now seems to have corrected itself and perhaps this isnt' necessary,
    but since I'm not sure why it fixed itself, I'm leaving it in place.
 */
- (NSMutableArray*) addObjectsWithoutOverlap: (NSMutableArray*) acc toAdd:(NSArray*) newPoints {
    
    VTTrackpointRecord * last = [acc lastObject];
    VTTrackpointRecord * currentRecord;
    
    DDLogDebug(@"addObjectsWithoutOverlap:");
    if (last) DDLogDebug(@"last in accumulator: %@", [self dateInfo:last.timestamp]);
    DDLogDebug(@"first in newly read points: %@", [self dateInfo:((VTTrackpointRecord*)[newPoints firstObject]).timestamp]);
    DDLogDebug(@"last in newly read points: %@", [self dateInfo:((VTTrackpointRecord*)[newPoints lastObject]).timestamp]);

    if ([acc count] == 0) {
        DDLogDebug(@"Discarding 0 overlapping track points (acc is empty).");
        [acc addObjectsFromArray:newPoints];
    }
    else {
        NSTimeInterval lastTimestamp = last.timestamp.timeIntervalSinceReferenceDate;
        NSMutableArray * newPointsMutable = [newPoints mutableCopy];
        int i;
        for (i=0;i<(int)newPoints.count;i++) {
            currentRecord = [newPoints objectAtIndex:i];
            if (currentRecord.timestamp.timeIntervalSinceReferenceDate > lastTimestamp) {
                break;
            }
        }
        DDLogDebug(@"Discarding %d overlapping track points.", i);
        [newPointsMutable removeObjectsInRange:NSMakeRange(0, i)];
        [acc addObjectsFromArray:newPointsMutable];
    }
    
    return acc;
}

- (NSMutableArray*) trackpointsHelper:(NSMutableArray*)acc expectedNumTrackpoint:(unsigned long)expectedNumTrackpoints start:(NSDate*)start end:(NSDate*)end {
    
    if (self.isCancelled) {
        return acc;
    }
    
    DDLogDebug(@"Expected num trackpoint = %lu", expectedNumTrackpoints);
    DDLogDebug(@"Start Date = %f - %@", [start timeIntervalSinceReferenceDate], [start description]);
    DDLogDebug(@"End Date  = %f - %@", [end timeIntervalSinceReferenceDate], [end description]);
    
    
    if (acc == nil) acc = [[NSMutableArray alloc] init];
    
    NSArray * newTrackpoints = [device trackpoints:start endTime:end];
    
    DDLogDebug(@"New trackpoints downloaded = %lu", [newTrackpoints count]);
    
    //[acc addObjectsFromArray:newTrackpoints];
    
    acc = [self addObjectsWithoutOverlap:acc toAdd:newTrackpoints];
    
    DDLogDebug(@"Total in accumulator after merging = %lu", [acc count]);

    if ([acc count] < expectedNumTrackpoints) {
        
        DDLogDebug(@"[acc count] < expectedNumTrackpoints, recovering...");
        DDLogDebug(@"start time interval =%fl", [start timeIntervalSinceReferenceDate]);
        DDLogDebug(@"end time interval  =%fl", [end timeIntervalSinceReferenceDate]);
        
        // get last trackpoint
        VTTrackpointRecord *lastTrackpoint = [acc lastObject];
        
        // get date of last trackpoint
        NSDate *dateOfLastTrackpoint = lastTrackpoint.timestamp;
        
        // increment by 1 ms
        NSTimeInterval timeOfLastTrackpoint = [dateOfLastTrackpoint timeIntervalSinceReferenceDate];
        DDLogDebug(@"timeOfLastTrackpoint =% f", timeOfLastTrackpoint);

        NSTimeInterval newTimeInterval = timeOfLastTrackpoint + 0.1;
        DDLogDebug(@"timeOfLastTrackpoint+1 = %f",newTimeInterval);
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
