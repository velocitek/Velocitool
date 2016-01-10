#define FIRMWARE_UPDATE_FAILED NO
#define FIRMWARE_UPDATE_SUCCEEDED YES


#import <Cocoa/Cocoa.h>

@class VTCommand;
@class VTRecord;
@class VTFirmwareFile;
@class VTProgressTracker;

@interface VTConnection : NSObject {
    void *_ft_handle;
    int _vendorID;
    int _productID;
    NSString * _serial;
    
    unsigned int _available;
	
	VTProgressTracker *progressTracker;
}

@property (nonatomic, readwrite, retain) VTProgressTracker *progressTracker;

+ connectionWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial;

- runCommand:(VTCommand *)command;

- (BOOL)runFirmwareUpdate:(VTFirmwareFile *)firmwareFile;

- (BOOL)writeFirmwareFile:(VTFirmwareFile*)firmwareFile;
- (BOOL)readFirmwareUpdateFlowControlChars;

- (void)writeChar:(char)c;
- (void)writeUnsignedChar:(unsigned char)c;
- (void)writeBool:(BOOL)yn;
- (void)writeDate:(NSDate *)date;
- (void)writeFloat:(float)floatToWrite;

- (char)readChar;
- (unsigned char)readUnsignedChar;
- (BOOL)readBool;
- (int)readInt32;
- (NSDate *)readDate;
- (float)readFloat;

- (NSData *)readLength:(unsigned int)length; // Dangerous. No byte swapping on that one...

- (void)recover;



@end

