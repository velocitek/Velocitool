//
//  VTTrackpointsElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/3/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTTrackpointsElement.h"
#import "VTTrackpointElement.h"


@implementation VTTrackpointsElement

+ (id)trackpointsElementWithTrackpointsArray:(NSMutableArray*) trackpoints{
	
	VTTrackpointsElement *trackpointsElement = [[self alloc] initWithTrackpointsArray:trackpoints];
	[trackpointsElement autorelease];
	return trackpointsElement;

}

- (id)initWithTrackpointsArray:(NSMutableArray *)trackpoints {
  if ((self = [super initWithKind:NSXMLElementKind])) {
    // create a new element named "Trackpoints"
    [self setName:@"Trackpoints"];

    // for each trackpoint object in the array
    for (VTTrackpointRecord *trackpoint in trackpoints) {
      // make a trackpoint element from the trackpoint object
      VTTrackpointElement *trackpointElement = [VTTrackpointElement
          trackpointElementWithTrackpointRecord:trackpoint];

      // add the trackpoint element as a child of the trackpoints element
      [self addChild:trackpointElement];
    }
  }
  return self;
}

@end
