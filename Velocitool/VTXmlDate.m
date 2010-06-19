//
//  VTXmlDate.m
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import "VTXmlDate.h"

@interface VTXmlDate (private)

-(NSString *)removeGMTFromDateString:(NSString *)dateStringToModify;

@end



@implementation VTXmlDate

+ (id)xmlDateWithDate:(NSDate*) dateTime
{
	VTXmlDate *xmlDate = [[self alloc] initWithDate:dateTime];
	[xmlDate autorelease];
	return xmlDate;
}

- (id)initWithDate:(NSDate*) dateTime;
{
	[super init];
	date = dateTime;
	return self;
}

+ (NSString*)xmlNow
{
	NSDate *currentTime = [NSDate date];
	VTXmlDate *xmlDate = [[self alloc] initWithDate:currentTime];
	return [xmlDate xmlDateString];
}

- (NSString*)xmlDateString
{
		
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	//"2010-04-27T20:19:24-10:00"
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSString *dateString;
	
	dateString = [dateFormatter stringFromDate:date];
	
	dateString = [self removeGMTFromDateString:dateString];
	
	return dateString;
}



//Removes the letters "GMT" from the timezone listing on a Unicode date string 
//e.g. "2010-04-27T20:19:24-GMT10:00" becomes 
- (NSString *)removeGMTFromDateString:(NSString *)dateStringToModify
{				
	return [dateStringToModify stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
	
}

@end
