#import <Cocoa/Cocoa.h>

@interface VTDateTime : NSObject

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSData *picDateRepresentation;

// Length, in bytes, of the microcontroller format.
+ (unsigned int)picRepresentationSize;

+ (id)vtDateWithPicBytes:(NSData *)bytes;
+ (id)vtDateWithDate:(NSDate *)bytes;

@end
