#import <Cocoa/Cocoa.h>

@class VTCommand;
@class VTRecord;
@class VTFirmwareFile;
@class VTProgressTracker;

// This is the abstract representation of a connection to a USB device.
@interface VTConnection : NSObject
// Tracks what is happening during a communication.
@property(nonatomic, readonly) VTProgressTracker *progressTracker;

// Connect to the device identified by the vendorID, productID, and serial
// number.
+ connectionWithVendorID:(int)vendorID
               productID:(int)productID
            serialNumber:(NSString *)serial;

// Run the given command.
- runCommand:(VTCommand *)command;

// Separate command for track download with some error checking
- runCommandTrackDownload:(VTCommand *)command;

// Send the corresponding data to the device.
- (void)writeChar:(char)c;
- (void)writeUnsignedChar:(unsigned char)c;
- (void)writeBool:(BOOL)yn;
- (void)writeDate:(NSDate *)date;
- (void)writeFloat:(float)floatToWrite;

// Read the corresponding data from the device.
- (char)readChar;
- (unsigned char)readUnsignedChar;
- (BOOL)readBool;
- (int)readInt32;
- (NSDate *)readDate;
- (float)readFloat;

// This is the underlaying raw reading method, that just returns the raw bytes
// from the device without any bit swapping or interpretation. Use with care!
- (NSData *)readLength:(unsigned int)length;

// Read until there is no data left, close the connection and reopen. If the
// device and the host become confused, this will reset to a known state. A bit
// slow, the timeouts on this one are relatively long.
- (void)recover;

// Firmware update is not working at this time. And should not be done here
// anyway but at a higher lever.
#define FIRMWARE_UPDATE_FAILED NO
#define FIRMWARE_UPDATE_SUCCEEDED YES
// This routine writes the bytes of a firmware file to the connection
- (BOOL)runFirmwareUpdate:(VTFirmwareFile *)firmwareFile;
// This routine writes the bytes of a firmware file to the connection
// Updating firmware currently does not work because of problems with
// the reliability of FTDI's mac drivers
- (BOOL)writeFirmwareFile:(VTFirmwareFile *)firmwareFile;
- (BOOL)readFirmwareUpdateFlowControlChars;

@end
