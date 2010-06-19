//
//  VTXmlDate.h
//  Velocitool
//
//  Created by Alec Stewart on 6/5/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VTXmlDate : NSObject {

	NSDate* date;
}

+ (id)xmlDateWithDate:(NSDate*) dateTime;
+ (NSString *)xmlNow;
- (id)initWithDate:(NSDate*) dateTime;
- (NSString*)xmlDateString;

@end
