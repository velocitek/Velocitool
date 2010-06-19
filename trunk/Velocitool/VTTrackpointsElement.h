//
//  VTTrackpointsElement.h
//  Velocitool
//
//  Created by Alec Stewart on 6/3/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTTrackpointElement;


@interface VTTrackpointsElement : NSXMLElement {

}

+ (id)trackpointsElementWithTrackpointsArray:(NSMutableArray*) trackpoints;

- (id)initWithTrackpointsArray: (NSMutableArray*) trackpoints;

@end
