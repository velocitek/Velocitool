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
    
    NSLog(@"addObjectsWithoutOverlap:");
    if (last) NSLog(@"last in accumulator: %@", [self dateInfo:last.timestamp]);
    NSLog(@"first in newly read points: %@", [self dateInfo:((VTTrackpointRecord*)[newPoints firstObject]).timestamp]);
    NSLog(@"last in newly read points: %@", [self dateInfo:((VTTrackpointRecord*)[newPoints lastObject]).timestamp]);

    if ([acc count] == 0) {
        NSLog(@"Discarding 0 overlapping track points (acc is empty).");
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
        NSLog(@"Discarding %d overlapping track points.", i);
        [newPointsMutable removeObjectsInRange:NSMakeRange(0, i)];
        [acc addObjectsFromArray:newPointsMutable];
    }
    
    return acc;
}

- (NSMutableArray*) trackpointsHelper:(NSMutableArray*)acc expectedNumTrackpoint:(unsigned long)expectedNumTrackpoints start:(NSDate*)start end:(NSDate*)end {
    
    NSLog(@"Expected num trackpoint = %lu", expectedNumTrackpoints);
    NSLog(@"Start Date = %f - %@", [start timeIntervalSinceReferenceDate], [start description]);
    NSLog(@"End Date  = %f - %@", [end timeIntervalSinceReferenceDate], [end description]);
    
    
    if (acc == nil) acc = [[NSMutableArray alloc] init];
    
    NSArray * newTrackpoints = [device trackpoints:start endTime:end];
    
    NSLog(@"New trackpoints downloaded = %lu", [newTrackpoints count]);
    
    //[acc addObjectsFromArray:newTrackpoints];
    
    acc = [self addObjectsWithoutOverlap:acc toAdd:newTrackpoints];
    
    NSLog(@"Total in accumulator after merging = %lu", [acc count]);

    if ([acc count] < expectedNumTrackpoints) {
        
        NSLog(@"[acc count] < expectedNumTrackpoints, recovering...");
        NSLog(@"start time interval =%fl", [start timeIntervalSinceReferenceDate]);
        NSLog(@"end time interval  =%fl", [end timeIntervalSinceReferenceDate]);
        
        // get last trackpoint
        VTTrackpointRecord *lastTrackpoint = [acc lastObject];
        
        // get date of last trackpoint
        NSDate *dateOfLastTrackpoint = lastTrackpoint.timestamp;
        
        // increment by 1 ms
        NSTimeInterval timeOfLastTrackpoint = [dateOfLastTrackpoint timeIntervalSinceReferenceDate];
        NSLog(@"timeOfLastTrackpoint =% f", timeOfLastTrackpoint);

        NSTimeInterval newTimeInterval = timeOfLastTrackpoint + 0.1;
        NSLog(@"timeOfLastTrackpoint+1 = %f",newTimeInterval);
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
