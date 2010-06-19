//
//  VTTrackDownloadOperation.m
//  Velocitool
//
//  Created by Alec Stewart on 6/12/10.
//  Copyright 2010 Velocitek. All rights reserved.
//


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

- (id)initWithTrackObject:(VTTrackFromDevice*)track;
{
    if (![super init]) return nil;
    
	trackpoints = [[NSMutableArray alloc] init];
	
	trackFromDevice = track;
	device = [track device];
	selectedTrackLogs = [track selectedTrackLogs];
			
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
		
		newTrackpoints = [device trackpoints:start endTime:end];
		
		[trackpoints addObjectsFromArray:newTrackpoints];
		
	}
	
	[trackFromDevice setTrackpoints:trackpoints];
	[trackFromDevice setNumTrackpoints:[trackpoints count]];
	[trackFromDevice setCapturedTrackXMLElement:[VTCapturedTrackElement capturedTrackElementWithTrackPointsAndDevice:trackpoints device:device]];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSLog(@"Sending notification that the track has finished downloading");
	[notificationCenter postNotificationName:VTTrackFinishedDownloadingNotification object:self];

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
