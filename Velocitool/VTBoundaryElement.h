//
//  VTBoundaryElement.h
//  Velocitool
//
//  Created by Alec Stewart on 6/3/10.
//  Copyright 2010 Velocitek. All rights reserved.
//


/*Members:

-elementName
-elementStringValue
-extremValue
-trackpoints

Methods (public):

- boundaryElementWithTrackpointsArray
- initWithTrackpointsArray
*/

#define MINIMUM  YES
#define MAXIMUM  NO

#define LATITUDE YES
#define LONGITUDE NO

#import <Cocoa/Cocoa.h>

@interface VTBoundaryElement : NSXMLElement {

	NSString *elementStringValue;
	float extremeValue;
	NSMutableArray *trackpoints;
	
	BOOL minOrMax;
	BOOL latOrLong;
}

+boundaryElementWithTrackPointArray:(NSMutableArray *)trackpointArray whichBoundary:(BOOL)minMax whichCoord:(BOOL)latLong;

- initWithTrackpointArray:(NSMutableArray *)trackpointArray whichBoundary:(BOOL)minMax whichCoord:(BOOL)latLong;

@end
