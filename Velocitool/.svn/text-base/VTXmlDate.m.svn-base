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
-(NSString *)convertVccDateStringToInternationalFormat:(NSString *)vccDateString;
-(NSString *)removeTimezoneColonFromDateString:(NSString*) stringWithColon;
-(NSString *)putSpaceBetweenTimeAndTimezone:(NSString*) stringWithoutSpace;

@end



@implementation VTXmlDate

+ (id)xmlDateWithDate:(NSDate*) dateTime
{
	VTXmlDate *xmlDate = [[self alloc] initWithDate:dateTime];
	[xmlDate autorelease];
	return xmlDate;
}

+ (id)xmlDateWithVccDateString:(NSString*)vccDateString
{

	VTXmlDate *xmlDate = [[self alloc] initWithVccDateString:vccDateString];
	[xmlDate autorelease];
	return xmlDate;	
	    
}


- (id)initWithVccDateString:(NSString*) vccDateString
{
	[super init];
	
	//convert the vcc date string to international format
	NSString *internationalString = 
	[self convertVccDateStringToInternationalFormat:vccDateString];
	
	date = [NSDate dateWithString:internationalString];
		
	return self;
}

- (id)initWithDate:(NSDate*) dateTime;
{
	[super init];
	date = dateTime;
	return self;
}

+ (NSString*)vccNow
{
	VTXmlDate *xmlDate = [[[self alloc] initWithDate:[NSDate date]] autorelease];
	return [xmlDate vccDateString];
}

- (NSString*)vccDateString
{
		
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	//"2010-04-27T20:19:24-10:00"
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	
	NSString *dateString;
	
	dateString = [dateFormatter stringFromDate:date];
	
	dateString = [self removeGMTFromDateString:dateString];
	
	return dateString;
}

- (NSString*)vccGmtDateString
{
	
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	//"2010-04-27T20:19:24-10:00"
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	
	return [dateFormatter stringFromDate:date];
}

//Converts a vcc date string into the international format
//accepted by dateWithString
//2010-06-16T21:44:00-10:00 becomes 2010-06-16 21:44:00 -1000
-(NSString*)convertVccDateStringToInternationalFormat:(NSString*)vccDateString
{
	NSString *stringWithSpaceInsteadOfTBetweenDateAndTime = 
	[vccDateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	
	NSString *stringWithSpaceInFrontOfTimezone =
	[self putSpaceBetweenTimeAndTimezone:stringWithSpaceInsteadOfTBetweenDateAndTime];
	
		
	NSString *stringWithoutColon = 
	[self removeTimezoneColonFromDateString:
	 stringWithSpaceInFrontOfTimezone];
	
	return stringWithoutColon;
	 
}

//Puts a space between the time and timezone (used during the conversion
//of a vcc date string to the international format
//2010-06-16 21:44:00-10:00 becomes 2010-06-16 21:44:00 -10:00
-(NSString *)putSpaceBetweenTimeAndTimezone:(NSString*) stringWithoutSpace
{
	NSCharacterSet	*plusAndMinus = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
	
	NSRange locationTimeZonePlusOrMinusSymbol =
	[stringWithoutSpace rangeOfCharacterFromSet:plusAndMinus options:NSBackwardsSearch]; 
	
	//If the timezone is indicated with a minus sign, this line of code will do nothing
	NSString *stringWithSpaceInFrontOfPlus =
	[stringWithoutSpace 
	 stringByReplacingOccurrencesOfString:@"+"
	 withString:@" +"
	 options:0
	 range:locationTimeZonePlusOrMinusSymbol];
	 
	//If the timezone is indicated with a plus sign, this line of code will do nothing 
	NSString *stringWithSpaceInFrontOfPlusOrMinus = 
	 [stringWithSpaceInFrontOfPlus 
	  stringByReplacingOccurrencesOfString:@"-"
	  withString:@" -"
	  options:0
	  range:locationTimeZonePlusOrMinusSymbol];

	return stringWithSpaceInFrontOfPlusOrMinus;
}

//Removes the colon in the timezone (used during the conversion
//of a vcc date string to the international format
//2010-06-16 21:44:00 -10:00 becomes 2010-06-16 21:44:00 -1000
-(NSString *)removeTimezoneColonFromDateString:(NSString*) stringWithColon;
{
	//get an NSRange object representing the location of the 
	//timezone colon using the rangeOfCharacterFromSet method 
	//of the string with the option  NSBackwardsSearch
	
	NSRange locationOfColon;
	locationOfColon = [stringWithColon rangeOfString:@":" options: NSBackwardsSearch]; 
	
	//remove the timezone colon using 
	//stringbyReplacingOccurencesOfString:withString:options:range, 
	//specifying the range found above
	NSString *stringWithoutColon =
	[stringWithColon 
	 stringByReplacingOccurrencesOfString:@":"
	 withString:@""
	 options:0
	 range: locationOfColon];
	
	//return the string without the timezone colon
	return stringWithoutColon;
}



//Removes the letters "GMT" from the timezone listing on a Unicode date string 
//e.g. "2010-04-27T20:19:24-GMT10:00" becomes 
- (NSString *)removeGMTFromDateString:(NSString *)dateStringToModify
{				
	return [dateStringToModify stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
	
}

@end
