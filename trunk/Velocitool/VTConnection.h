
#import <Cocoa/Cocoa.h>

@class VTCommand;
@class VTRecord;

@interface VTConnection : NSObject {
    void *_ft_handle;
    int _vendorID;
    int _productID;
    NSString * _serial;
    
    unsigned int _available;
}

+ connectionWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial;

- runCommand:(VTCommand *)command;

- (void)writeChar:(char)c;
- (void)writeUnsignedChar:(unsigned char)c;
- (void)writeBool:(BOOL)yn;

- (char)readChar;
- (unsigned char)readUnsignedChar;
- (BOOL)readBool;
- (int)readInt32;
- (NSDate *)readDate;

- (NSData *)readLength:(unsigned int)length; // Dangerous. No byte swapping on that one...

@end

