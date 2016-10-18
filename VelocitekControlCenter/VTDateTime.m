#import <Foundation/NSDate.h>
#import "VTDateTime.h"

@interface VTDateTime () {
    NSDate *_date;
    NSData *_picDateRepresentation;
}

- (instancetype)initWithPicDateRepresentation:(NSData *)bytes;
- (instancetype)initWithDate:(NSDate *)date;
- (NSDateFormatter *)dateFormatter;
@end

@implementation VTDateTime

+ (unsigned int)picRepresentationSize {
    return 7;
}

+ (id)vtDateWithPicBytes:(NSData *)bytes {
    return [[self alloc] initWithPicDateRepresentation:bytes];
}

+ (id)vtDateWithDate:(NSDate *)dateObject {
    return [[self alloc] initWithDate:dateObject];
}


- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *utcTime = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSLocale *usLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    [dateFormatter setLocale:usLocale];
    [dateFormatter setTimeZone:utcTime];
    return dateFormatter;
}

- (NSCalendar*) getGregorianUTCCalendar {
    NSCalendar * calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [calendar setTimeZone:timeZone];
    return calendar;
}

- (NSDateComponents*) getComponentsFromDate:(NSDate*) date {
    NSCalendar * calendar = [self getGregorianUTCCalendar];
    NSCalendarUnit componentsToGet = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    NSDateComponents *components = [calendar components:componentsToGet fromDate:date];
    return components;
}

- (instancetype)initWithDate:(NSDate *)date {
    
    if ((self = [super init])) {
        
        _date = date;

        NSDateComponents *components = [self getComponentsFromDate:date];
        
        int yearInt = (int)components.year - 2000;
        int monthInt = (int)components.month;
        int dayInt = (int)components.day;
        int hourInt = (int)components.hour;
        int minInt = (int)components.minute;
        int secondInt = (int)components.second;
        int hundrethsInt = (int)round(components.nanosecond * 0.0000001);
        
        unsigned char picBytes[[VTDateTime picRepresentationSize]];
        picBytes[0] = (unsigned char) yearInt;
        picBytes[1] = (unsigned char) monthInt;
        picBytes[2] = (unsigned char) dayInt;
        picBytes[3] = (unsigned char) hourInt;
        picBytes[4] = (unsigned char) minInt;
        picBytes[5] = (unsigned char) secondInt;
        picBytes[6] = (unsigned char)hundrethsInt;
        
        _picDateRepresentation = [NSData dataWithBytes:picBytes length:[VTDateTime picRepresentationSize]];
        
        VTDateTime * test = [[VTDateTime alloc] initWithPicDateRepresentation:_picDateRepresentation];
        
        DDLogDebug(@"Date created with bytes: %@\nAnd string: %@\nFor original date: %@", [_picDateRepresentation description], [test description], [date description]);
        
    }
    
    return self;
}

- (instancetype)initWithPicDateRepresentation:(NSData *)bytes {
    if ((self = [super init])) {
        
        _picDateRepresentation = bytes;
        
        //DDLogDebug(@"%@", [_picDateRepresentation description]);
        
        unsigned char picBytes[[VTDateTime picRepresentationSize]];
        [_picDateRepresentation getBytes:picBytes length:[VTDateTime picRepresentationSize]];
        
        unsigned int year = 2000 + picBytes[0];
        unsigned int month = picBytes[1];
        unsigned int day = picBytes[2];
        unsigned int hour = picBytes[3];
        unsigned int minutes = picBytes[4];
        unsigned int seconds = picBytes[5];
        unsigned int hundredth = picBytes[6];
        
        // Can't find a NSDate constructor precise to the hundredth of a second for
        // some reason...
        NSDate *dateWithoutHundredths;
        dateWithoutHundredths = [NSDate dateWithString:[NSString stringWithFormat:@"%04u-%02u-%02u %02u:%02u:%02u +0000", year, month, day, hour, minutes, seconds]];
        
        NSTimeInterval hundredthsToAdd = (double)(hundredth / 100.0);
        
        _date = [[NSDate alloc] initWithTimeInterval:hundredthsToAdd sinceDate:dateWithoutHundredths];
    }
    return self;
}

- (NSString *)description {
    NSString *description_string;
    description_string = [NSString stringWithFormat:@"%@ - %@", [self.date description], [self.picDateRepresentation description]];
    return description_string;
}

@end
