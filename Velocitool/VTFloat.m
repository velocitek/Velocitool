#import "VTFloat.h"

@interface VTFloat () {
  float _floatingPointNumber;
  NSData *_picFloatRepresentation;
}

- (instancetype)initWithPicBytes:(NSData *)bytes;
- (instancetype)initWithFloat:(float)f;

@end

@implementation VTFloat

@synthesize floatingPointNumber = _floatingPointNumber;
@synthesize picFloatRepresentation = _picFloatRepresentation;

+ (unsigned int)picRepresentationSize {
  return 4;
}

+ (id)vtFloatWithPicBytes:(NSData *)bytes {
  NSAssert([bytes length] == [self picRepresentationSize], @"Invalid input");
  return [[[self alloc] initWithPicBytes:bytes] autorelease];
}

+ (id)vtFloatWithFloat:(float)f {
  return [[[self alloc] initWithFloat:f] autorelease];
}

- (void)dealloc {
  [_picFloatRepresentation release];
  [super dealloc];
}

- (NSString *)description {
  NSString *description_string;
  NSString *floatDescriptionString;
  NSString *picRepresentationDescriptionString;

  floatDescriptionString =
      [NSString stringWithFormat:@"Float value: %f", self.floatingPointNumber];
  picRepresentationDescriptionString =
      [NSString stringWithFormat:@"Representation on PIC: %@",
                                 [self.picFloatRepresentation description]];

  description_string =
      [NSString stringWithFormat:@"%@\n%@\n", floatDescriptionString,
                                 picRepresentationDescriptionString];

  return description_string;
}

- (instancetype)initWithFloat:(float)f {
  if ((self = [super init])) {
    NSAssert(sizeof(f) == 4, @"Well, this code is no longer valid...");
    _floatingPointNumber = f;

    // Now define the representation of the float in the PIC (GPS device
    // microcontroller) memory
    unsigned char result[[VTFloat picRepresentationSize]];
    unsigned char *floatAsBytes = (void *)&f;

    unsigned char signBit = floatAsBytes[3] & 0x80;
    unsigned char exponent =
        ((floatAsBytes[3] & 0x7F) << 1) + ((floatAsBytes[2] & 0x80) >> 7);

    result[0] = exponent;
    result[1] = signBit + (floatAsBytes[2] & 0x7F);
    result[2] = floatAsBytes[1];
    result[3] = floatAsBytes[0];

    _picFloatRepresentation =
        [[NSData dataWithBytes:result
                        length:[VTFloat picRepresentationSize]] retain];
  }
  return self;
}

- (instancetype)initWithPicBytes:(NSData *)bytes;
{
  if ((self = [super init])) {
    _picFloatRepresentation = [bytes retain];

    // Now adjust the floatingPointNumber property to match this new
    // picFloatRepresentation
    unsigned char bytesFromPic[[VTFloat picRepresentationSize]];
    unsigned char floatingPointNumberBytes[sizeof(float)];

    [_picFloatRepresentation getBytes:bytesFromPic
                               length:[VTFloat picRepresentationSize]];

    unsigned char exponent = bytesFromPic[0];
    unsigned char signBit = bytesFromPic[1] & 0x80;

    // Rearrange the bytes to convert from the PIC representation of a float to
    // the IEEE-754 single precision representation
    floatingPointNumberBytes[3] = signBit + ((exponent & 0xFE) >> 1);
    floatingPointNumberBytes[2] =
        ((exponent & 0x01) << 7) + (bytesFromPic[1] & 0x7F);
    floatingPointNumberBytes[1] = bytesFromPic[2];
    floatingPointNumberBytes[0] = bytesFromPic[3];

    float *pointerToFloat = (float *)floatingPointNumberBytes;
    _floatingPointNumber = *pointerToFloat;
  }
  return self;
}

@end
