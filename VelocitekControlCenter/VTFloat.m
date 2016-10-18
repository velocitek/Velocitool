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

/*  // Debug
 
 2016-07-28 00:12:55.630 Velocitool[33130:329322] *** Assertion failure in +[VTFloat vtFloatWithPicBytes:], Project/Velocitool/Velocitool/VTFloat.m:23
 2016-07-28 00:12:55.711 Velocitool[33130:329322] An uncaught exception was raised
 2016-07-28 00:12:55.711 Velocitool[33130:329322] Invalid input
 2016-07-28 00:12:55.711 Velocitool[33130:329322] (
	0   CoreFoundation                      0x00007fff99b644f2 __exceptionPreprocess + 178
	1   libobjc.A.dylib                     0x00007fff939c673c objc_exception_throw + 48
	2   CoreFoundation                      0x00007fff99b691ca +[NSException raise:format:arguments:] + 106
	3   Foundation                          0x00007fff97277856 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 198
	4   Velocitool                          0x0000000100007c46 +[VTFloat vtFloatWithPicBytes:] + 246
	5   Velocitool                          0x0000000100005ac7 -[VTConnection readFloat] + 103
	6   Velocitool                          0x0000000100008492 -[VTTrackpointRecord readDeviceDataFromConnection:] + 242
	7   Velocitool                          0x000000010000823e -[VTRecord readFromConnection:] + 62
	8   Velocitool                          0x0000000100005495 -[VTConnection runCommand:] + 677
	9   Velocitool                          0x0000000100002adf -[VTDeviceGeneration3 trackpoints:endTime:] + 191
	10  Velocitool                          0x000000010000ff9b -[VTTrackDownloadOperation main] + 459
	11  Foundation                          0x00007fff971cbc7a -[__NSOperationInternal _start:] + 654
	12  Foundation                          0x00007fff971c7c64 __NSOQSchedule_f + 194
	13  libdispatch.dylib                   0x00000001000e6cc5 _dispatch_client_callout + 8
	14  libdispatch.dylib                   0x00000001000ec112 _dispatch_queue_drain + 351
	15  libdispatch.dylib                   0x00000001000f3e24 _dispatch_queue_invoke + 557
	16  libdispatch.dylib                   0x00000001000eadab _dispatch_root_queue_drain + 1226
	17  libdispatch.dylib                   0x00000001000ea8a5 _dispatch_worker_thread3 + 106
	18  libsystem_pthread.dylib             0x0000000100149336 _pthread_wqthread + 1129
	19  libsystem_pthread.dylib             0x0000000100146f91 start_wqthread + 13
 )
 2016-07-28 00:12:55.712 Velocitool[33130:329322] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid input'
 *** First throw call stack:
 (
	0   CoreFoundation                      0x00007fff99b644f2 __exceptionPreprocess + 178
	1   libobjc.A.dylib                     0x00007fff939c673c objc_exception_throw + 48
	2   CoreFoundation                      0x00007fff99b691ca +[NSException raise:format:arguments:] + 106
	3   Foundation                          0x00007fff97277856 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 198
	4   Velocitool                          0x0000000100007c46 +[VTFloat vtFloatWithPicBytes:] + 246
	5   Velocitool                          0x0000000100005ac7 -[VTConnection readFloat] + 103
	6   Velocitool                          0x0000000100008492 -[VTTrackpointRecord readDeviceDataFromConnection:] + 242
	7   Velocitool                          0x000000010000823e -[VTRecord readFromConnection:] + 62
	8   Velocitool                          0x0000000100005495 -[VTConnection runCommand:] + 677
	9   Velocitool                          0x0000000100002adf -[VTDeviceGeneration3 trackpoints:endTime:] + 191
	10  Velocitool                          0x000000010000ff9b -[VTTrackDownloadOperation main] + 459
	11  Foundation                          0x00007fff971cbc7a -[__NSOperationInternal _start:] + 654
	12  Foundation                          0x00007fff971c7c64 __NSOQSchedule_f + 194
	13  libdispatch.dylib                   0x00000001000e6cc5 _dispatch_client_callout + 8
	14  libdispatch.dylib                   0x00000001000ec112 _dispatch_queue_drain + 351
	15  libdispatch.dylib                   0x00000001000f3e24 _dispatch_queue_invoke + 557
	16  libdispatch.dylib                   0x00000001000eadab _dispatch_root_queue_drain + 1226
	17  libdispatch.dylib                   0x00000001000ea8a5 _dispatch_worker_thread3 + 106
	18  libsystem_pthread.dylib             0x0000000100149336 _pthread_wqthread + 1129
	19  libsystem_pthread.dylib             0x0000000100146f91 start_wqthread + 13
 )
 libc++abi.dylib: terminating with uncaught exception of type NSException
 
 
 */

+ (id)vtFloatWithPicBytes:(NSData *)bytes {
//  NSAssert([bytes length] == [self picRepresentationSize], @"Invalid input");
    
    if ( !bytes )  // if bytes is null
    {        
        return [[self alloc] initWithFloat:0.0f];
    }
    
  return [[self alloc] initWithPicBytes:bytes];
}

+ (id)vtFloatWithFloat:(float)f {
  return [[self alloc] initWithFloat:f];
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
        [NSData dataWithBytes:result
                        length:[VTFloat picRepresentationSize]];
  }
  return self;
}

- (instancetype)initWithPicBytes:(NSData *)bytes;
{
  if ((self = [super init])) {
    _picFloatRepresentation = bytes;

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
