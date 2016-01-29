//
//  VTDateTime.h
//  Velocitool
//
//  Created by Alec Stewart on 3/25/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#define NUM_BYTES_IN_PIC_DATETIME 7

#import <Cocoa/Cocoa.h>
@class NSDate;

@interface VTDateTime : NSObject {
	
	NSDate *date;
	NSData *picDateRepresentation;
	
	NSDateFormatter *dateFormatter;
	NSTimeZone *utcTime;
	NSLocale *usLocale;
	
}

@property(readwrite, retain) NSDate *date;
@property(readwrite, retain) NSData *picDateRepresentation;

+ (id)vtDateWithPicBytes:(NSData *)bytes;
+ (id)vtDateWithDate:(NSDate *)bytes;


@end
