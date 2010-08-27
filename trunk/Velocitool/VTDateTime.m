//
//  VTDateTime.m
//  Velocitool
//
//  Created by Alec Stewart on 3/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//


#import "VTDateTime.h"
#import <Foundation/NSDate.h>


@implementation VTDateTime

@synthesize date;
@synthesize picDateRepresentation;

+ (id)vtDateWithPicBytes:(NSData *)bytes
{
	VTDateTime *velocitekDateTime = [[self alloc] init];
	
	[velocitekDateTime setPicDateRepresentation:bytes];
	
	[velocitekDateTime autorelease];
	
	return velocitekDateTime;
}

+ (id)vtDateWithDate:(NSDate *)dateObject
{
	VTDateTime *velocitekDateTime = [[self alloc] init];
	
	[velocitekDateTime setDate:dateObject];
	
	[velocitekDateTime autorelease];
	
	return velocitekDateTime;
}

- (id) init
{
	[super init];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	
	utcTime = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
	
	usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[usLocale autorelease];
	
	[dateFormatter setLocale:usLocale];
	[dateFormatter setTimeZone:utcTime];
	
	return self;
}

- (void)dealloc
{
	[dateFormatter release];
	[date release];
	[picDateRepresentation release];
	[super dealloc];
}

- (NSString *)description
{
	NSString *description_string;
	NSString *dateTimeDescriptionString;
	NSString *picRepresentationDescriptionString;
	
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
	dateTimeDescriptionString = [NSString stringWithFormat:@"Date / Time: %@", [dateFormatter stringFromDate:date]];
	picRepresentationDescriptionString = [NSString stringWithFormat:@"Representation on PIC: %@", [picDateRepresentation description]];
	
	description_string = [NSString stringWithFormat:@"%@\n%@\n", dateTimeDescriptionString, picRepresentationDescriptionString];
	
	return description_string;
	
}	

-(void)setDate:(NSDate *)d
{
	[d retain];
	[date release];
	date = d;
	
	//Now define the representation of the new date in the PIC (GPS device microcontroller) memory	
	unsigned char picBytes[NUM_BYTES_IN_PIC_DATETIME];
	
	unsigned char year;
	unsigned char month;
	unsigned char day;
	unsigned char hour;
	unsigned char minute;
	unsigned char second;
	unsigned char hundredthSeconds;

	[dateFormatter setDateFormat:@"yy"];		
	year = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"MM"];
	month = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"dd"];
	day = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"HH"];
	hour = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"mm"];
	minute = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"ss"];
	second = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	[dateFormatter setDateFormat:@"SS"];
	hundredthSeconds = (unsigned char)[[dateFormatter stringFromDate:date] intValue];
	
	picBytes[0] = year;
	picBytes[1] = month;
	picBytes[2] = day;
	picBytes[3] = hour;
	picBytes[4] = minute;
	picBytes[5] = second;
	picBytes[6] = hundredthSeconds;
	
	[picDateRepresentation release];
	
	picDateRepresentation = [NSData dataWithBytes:picBytes length:NUM_BYTES_IN_PIC_DATETIME];
	
	[picDateRepresentation retain];
	
}

-(void)setPicDateRepresentation:(NSData *)p
{
	[p retain];
	[picDateRepresentation release];
	picDateRepresentation = p;
	
	//Now adjust the date property to match this new picRepresentation 
	
	unsigned char picBytes[NUM_BYTES_IN_PIC_DATETIME];
	
	[picDateRepresentation getBytes:picBytes length:NUM_BYTES_IN_PIC_DATETIME];
	
	int year = 2000 + (int)picBytes[0];
    int month = (int)picBytes[1];
    int day = (int)picBytes[2];
    int hour = (int)picBytes[3];
    int minutes = (int)picBytes[4];
    int seconds = (int)picBytes[5];
    int hundredth = (int)picBytes[6];
    
    
	// Can't find a NSDate constructor precise to the hundredth of a second for some reason...
	NSDate *dateWithoutHundredths;
	dateWithoutHundredths = [NSDate dateWithString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", year, month, day, hour, minutes, seconds]];
	
	NSTimeInterval hundredthsToAdd = (double)(hundredth / 100.0);

	NSDate *dateWithHundredths = [[NSDate alloc] initWithTimeInterval:hundredthsToAdd sinceDate:dateWithoutHundredths];
	
	[date release];
	
	date = dateWithHundredths;	
	    	
}




 
@end
