//
//  VTVccXmlDoc.h
//  Velocitool
//
//  Created by Alec Stewart on 6/6/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTCapturedTrackElement;

@interface VTVccXmlDoc : NSXMLDocument {
	

}

- (id)initWithCapturedTrack: (VTCapturedTrackElement*)capturedTrack;
+ (id)vccXmlDocWithCapturedTrack: (VTCapturedTrackElement*) capturedTrack; 
- (void)saveAsVccFile;

@end
