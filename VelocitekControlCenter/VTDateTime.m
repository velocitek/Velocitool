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
    //NSLog(@"VTLOG: [VTDateTime, vtDateWithPicBytes = %@]", bytes);  // VTLOG for debugging
    
        return [[self alloc] initWithPicDateRepresentation:bytes];
}

+ (id)vtDateWithDate:(NSDate *)dateObject {
    //NSLog(@"VTLOG: [VTDateTime, vtDateWithDate = %@]", dateObject);  // VTLOG for debugging
    
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

- (instancetype)initWithDate:(NSDate *)date {
  if ((self = [super init])) {
    _date = date;

    NSDateFormatter *dateFormatter = [self dateFormatter];

    [dateFormatter setDateFormat:@"yy"];
    unsigned char year;
    year = (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"MM"];
    unsigned char month =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"dd"];
    unsigned char day =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"HH"];
    unsigned char hour =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"mm"];
    unsigned char minute =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"ss"];
    unsigned char second =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    [dateFormatter setDateFormat:@"SS"];
    unsigned char hundredthSeconds =
        (unsigned char)[[dateFormatter stringFromDate:date] intValue];

    unsigned char picBytes[[VTDateTime picRepresentationSize]];
    picBytes[0] = year;
    picBytes[1] = month;
    picBytes[2] = day;
    picBytes[3] = hour;
    picBytes[4] = minute;
    picBytes[5] = second;
    picBytes[6] = hundredthSeconds;

    _picDateRepresentation =
        [NSData dataWithBytes:picBytes length:[VTDateTime picRepresentationSize]];
  }
  return self;
}

- (instancetype)initWithPicDateRepresentation:(NSData *)bytes {
  if ((self = [super init])) {
    _picDateRepresentation = bytes;
      
      NSLog(@"%@", [_picDateRepresentation description]);

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
    dateWithoutHundredths = [NSDate
        dateWithString:[NSString stringWithFormat:
                                     @"%04u-%02u-%02u %02u:%02u:%02u +0000",
                                     year, month, day, hour, minutes, seconds]];

    NSTimeInterval hundredthsToAdd = (double)(hundredth / 100.0);

    _date = [[NSDate alloc] initWithTimeInterval:hundredthsToAdd
                                       sinceDate:dateWithoutHundredths];
  }
  return self;
}

- (NSString *)description {
  NSString *description_string;
  NSString *dateTimeDescriptionString;
  NSString *picRepresentationDescriptionString;

  NSDateFormatter *dateFormatter = [self dateFormatter];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];

  dateTimeDescriptionString =
      [NSString stringWithFormat:@"Date / Time: %@",
                                 [dateFormatter stringFromDate:self.date]];
  picRepresentationDescriptionString =
      [NSString stringWithFormat:@"Representation on PIC: %@",
                                 [self.picDateRepresentation description]];

  description_string =
      [NSString stringWithFormat:@"%@\n%@\n", dateTimeDescriptionString,
                                 picRepresentationDescriptionString];

  return description_string;
}

@end
