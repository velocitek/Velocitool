//
//  VTBoundaryElement.m
//  Velocitool
//
//  Created by Alec Stewart on 6/3/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTBoundaryElement.h"
#import "VTRecord.h"

/*
Methods (private):

-findExtremeValue
-createElementName
-findElementStringValue
*/

@interface VTBoundaryElement (private)

-(void)setElementName;
-(void)findExtremeValue;
-(NSString *)findElementStringValue:(float)elementFloatValue;
-(void)setElementValue;

@end

@implementation VTBoundaryElement

+boundaryElementWithTrackPointArray:(NSMutableArray *)trackpointArray whichBoundary:(BOOL)minMax whichCoord:(BOOL)latLong
{
	VTBoundaryElement *boundaryElement = [[self alloc] initWithTrackpointArray:trackpointArray whichBoundary:minMax whichCoord:latLong];
	[boundaryElement autorelease];
	return boundaryElement;
	
}

- initWithTrackpointArray:(NSMutableArray *)trackpointArray whichBoundary:(BOOL)minMax whichCoord:(BOOL)latLong
{
	minOrMax = minMax;
	latOrLong = latLong;
	trackpoints = [trackpointArray retain];
	
	//initialize a new element
	[super init];		
	[self initWithKind:NSXMLElementKind];
	
	//set the element name
	[self setElementName];
		
	//set the element value
	[self setElementValue];
			
	return self;

}

-(void)setElementValue
{
	[self findExtremeValue];	
	NSString* elementValue = [self findElementStringValue:extremeValue];
	
	[self setStringValue:elementValue];		
}

-(NSString *)findElementStringValue:(float)elementFloatValue
{
	if (latOrLong == LATITUDE) 
		return [NSString stringWithFormat:@"%.15f", extremeValue];		
	
	else		
		return [NSString stringWithFormat:@"%.14f", extremeValue];		
	
}

-(void)findExtremeValue
{
	NSSortDescriptor *sortDescriptor;
	NSArray *sortDescriptors;
	NSArray *sortedArray;
	VTTrackpointRecord *trackpointContainingExtremeValue;
	
	NSUInteger indexOfLastElement = [trackpoints count] - 1;
	
	if (latOrLong == LATITUDE) 
		//Sort the trackpoints array is ascending order by latitude
		sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_latitude" ascending:YES];		
		
	else		
		//Sort the trackpoints array is ascending order by longitude
		sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_longitude" ascending:YES];		
			
	sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	sortedArray = [trackpoints sortedArrayUsingDescriptors:sortDescriptors];
	
	//NSLog(@"sortedArray: %@",sortedArray);
							
	if(minOrMax == MINIMUM)
		//extremeValue = member of first element of the sorted array
		trackpointContainingExtremeValue = [sortedArray objectAtIndex:0];
						
	else						
		//extremeValue = member of last element of the sorted array
		trackpointContainingExtremeValue = [sortedArray objectAtIndex:indexOfLastElement];
			
		
	if (latOrLong == LATITUDE) 
		extremeValue = [trackpointContainingExtremeValue _latitude];
		
	else 
		extremeValue = [trackpointContainingExtremeValue _longitude];
	
			
}

-(void)setElementName
{
	NSString *firstPartOfName;
	NSString *secondPartOfName;
	NSString *elementName;
	
	if(minOrMax == MINIMUM)
	{		
		firstPartOfName = [NSString stringWithString:@"Min"];
	}		
	else
	{		
		firstPartOfName = [NSString stringWithString:@"Max"];
	}
			
    if(latOrLong == LATITUDE)
	{
		secondPartOfName = [NSString stringWithString:@"Latitude"];
	}		
	else
	{		
		secondPartOfName = [NSString stringWithString:@"Longitude"];
	}					
	
	//elementName = concatenation of firstPartOfName and secondPartOfName	
	elementName = [firstPartOfName stringByAppendingString:secondPartOfName];
	
	[self setName:elementName];
		
}

@end

