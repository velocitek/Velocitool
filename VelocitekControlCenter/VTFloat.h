#import <Cocoa/Cocoa.h>

@interface VTFloat : NSObject
// The value of the float, as a float.
@property(nonatomic, readonly) float floatingPointNumber;
// The value of the float, in microcontroller format
@property(nonatomic, readonly) NSData *picFloatRepresentation;

// Length, in bytes, of the microcontroller format.
+ (unsigned int)picRepresentationSize;

// Initializing with either format.
+ (instancetype)vtFloatWithPicBytes:(NSData *)bytes;
+ (instancetype)vtFloatWithFloat:(float)f;

@end
