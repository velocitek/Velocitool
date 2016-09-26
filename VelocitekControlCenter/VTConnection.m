
#define ACKLOD 0x06

#import "VTCommand.h"
#import "VTConnection.h"
#import "VTDateTime.h"
#import "VTFirmwareFile.h"
#import "VTFloat.h"
#import "VTRecord.h"
#import "VTProgressTracker.h"

#import <dlfcn.h>
#import "ftd2xx.h"

//
// This is really fugly, but unfortunately the device driver for the hardware
// Velocitek uses is only available in binary form, as a dyld file to be
// installed in /usr/local. This is a really bad idea to have an application
// dropping stuff in there, and I don't like that device driver very much. At
// some point, it will need to be redone all in free code.
//
// Anyway, to avoid the issue I'm loading the dyld file from the resource folder
// at launch time. All the functions I use are dynamically looked up and stored
// in those static variables.
//
static FT_STATUS (*pFT_SetVIDPID)(DWORD dwVID, DWORD dwPID);
static FT_STATUS (*pFT_OpenEx)(PVOID pArg1, DWORD Flags, FT_HANDLE *pHandle);
static FT_STATUS (*pFT_ResetDevice)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_Purge)(FT_HANDLE ftHandle, ULONG Mask);
static FT_STATUS (*pFT_SetBaudRate)(FT_HANDLE ftHandle, ULONG BaudRate);
static FT_STATUS (*pFT_SetDataCharacteristics)(FT_HANDLE ftHandle,
                                               UCHAR WordLength, UCHAR StopBits,
                                               UCHAR Parity);
static FT_STATUS (*pFT_SetTimeouts)(FT_HANDLE ftHandle, ULONG ReadTimeout,
                                    ULONG WriteTimeout);
static FT_STATUS (*pFT_Close)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_SetRts)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_ClrRts)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_SetFlowControl)(FT_HANDLE ftHandle, USHORT FlowControl,
                                       UCHAR XonChar, UCHAR XoffChar);
static FT_STATUS (*pFT_Write)(FT_HANDLE ftHandle, LPVOID lpBuffer,
                              DWORD nBufferSize, LPDWORD lpBytesWritten);
static FT_STATUS (*pFT_Read)(FT_HANDLE ftHandle, LPVOID lpBuffer,
                             DWORD nBufferSize, LPDWORD lpBytesReturned);
static FT_STATUS (*pFT_GetStatus)(FT_HANDLE ftHandle, DWORD *dwRxBytes,
                                  DWORD *dwTxBytes, DWORD *dwEventDWord);
static FT_STATUS (*pFT_ListDevices)(PVOID pvArg1, PVOID pvArg2, DWORD dwFlags);

@interface VTConnection () {
    // Handle to the FT device.
    void *_ft_handle;
    // Identifiers for the device.
    int _vendorID;
    int _productID;
    NSString *_serial;
    // Amount of bytes available for reading.
    NSUInteger _available;
}

// Designated initializer.
- (instancetype)initWithVendorID:(int)vendorID
                       productID:(int)productID
                    serialNumber:(NSString *)serial;

// Opens the connection. Done on init.
- (void)open;
// Closes the connection.
- (void)close;
// Closes, then reopens the connection.
- (void)reset;

// Set and reset the flag to signal that the host wants to talk to the device.
- (void)setRTS;
- (void)clearRTS;

// Use flow control.
- (void)setFlowControl:(BOOL)onOff;

// Send data to the device.
- (NSUInteger)write:(NSData *)data;
// Wait for the length of data to read back.
- (NSUInteger)waitForResponseLength:(NSUInteger)length timeout:(int)timeOutInMs;
// Read from device.
- (NSData *)readLength:(NSUInteger)length timeout:(int)timeOutInMs;

@end

@implementation VTConnection
@synthesize progressTracker = _progressTracker;

+ (void)initialize {
    if (self != [VTConnection self]) {
        return;
    }
    
    // On first use load the dynamic library and setup all the pointers to the
    // functions in it.
    NSString *path =
    [[NSBundle mainBundle] pathForResource:@"libftd2xx.1.2.2.dylib"
                                    ofType:@""];
    
    void *handle = dlopen([path UTF8String], RTLD_LAZY | RTLD_GLOBAL);
    NSAssert2(handle, @"Can't load the library at %@: %s", path, dlerror());
    
    pFT_SetVIDPID = dlsym(handle, "FT_SetVIDPID");
    NSAssert(pFT_SetVIDPID, @"FT_SetVIDPID");
    pFT_OpenEx = dlsym(handle, "FT_OpenEx");
    NSAssert(pFT_OpenEx, @"FT_OpenEx");
    pFT_SetBaudRate = dlsym(handle, "FT_SetBaudRate");
    NSAssert(pFT_SetBaudRate, @"FT_SetBaudRate");
    pFT_SetDataCharacteristics = dlsym(handle, "FT_SetDataCharacteristics");
    NSAssert(pFT_SetDataCharacteristics, @"FT_SetDataCharacteristics");
    pFT_SetTimeouts = dlsym(handle, "FT_SetTimeouts");
    NSAssert(pFT_SetTimeouts, @"FT_SetTimeouts");
    pFT_SetRts = dlsym(handle, "FT_SetRts");
    NSAssert(pFT_SetRts, @"FT_SetRts");
    pFT_ClrRts = dlsym(handle, "FT_ClrRts");
    NSAssert(pFT_ClrRts, @"FT_ClrRts");
    pFT_SetFlowControl = dlsym(handle, "FT_SetFlowControl");
    NSAssert(pFT_SetFlowControl, @"FT_SetFlowControl");
    pFT_Write = dlsym(handle, "FT_Write");
    NSAssert(pFT_Write, @"FT_Write");
    pFT_Read = dlsym(handle, "FT_Read");
    NSAssert(pFT_Read, @"FT_Read");
    pFT_GetStatus = dlsym(handle, "FT_GetStatus");
    NSAssert(pFT_GetStatus, @"FT_GetStatus");
    pFT_ResetDevice = dlsym(handle, "FT_ResetDevice");
    NSAssert(pFT_ResetDevice, @"FT_ResetDevice");
    pFT_Purge = dlsym(handle, "FT_Purge");
    NSAssert(pFT_Purge, @"FT_Purge");
    pFT_Close = dlsym(handle, "FT_Close");
    NSAssert(pFT_Close, @"FT_Close");
    pFT_ListDevices = dlsym(handle, "FT_ListDevices");
    NSAssert(pFT_ListDevices, @"FT_ListDevices");
}

+ connectionWithVendorID:(int)vendorID
               productID:(int)productID
            serialNumber:(NSString *)serial {
    return [[self alloc] initWithVendorID:vendorID
                                productID:productID
                             serialNumber:serial];
}

- (instancetype)initWithVendorID:(int)vendorID
                       productID:(int)productID
                    serialNumber:(NSString *)serial {
    if ((self = [super init])) {
        
        NSLog(@"VTLog: Initialized with Vendor ID = %d, Product ID = %d, Serial Number = %@", vendorID, productID, serial);
        _vendorID = vendorID;
        _productID = productID;
        _serial = [serial copy];
        _progressTracker = [[VTProgressTracker alloc] init];
        [self open];
        if (!_ft_handle) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self close];
    _serial = nil;
}

#pragma mark - Public methods

- runCommand:(VTCommand *)command {
    // Signal to the device the intention to talk to it.
    [self setRTS];
    
    // Adopt the flow control requested by the command.
    [self setFlowControl:[command flowControl]];
    
    // Send the command, which is a single character.
    unsigned char signalChar = [command signal];
    [self writeUnsignedChar:signalChar];
    
    // Read the response, which should be an echo of the command.
    unsigned char response = [self readUnsignedChar];
    if (response != signalChar) {
        NSLog(@"VTError: Wrong response %c to signal %c. Aborting.", response,
              signalChar);
        [self recover];
        return nil;
    }
    
    // Confirm the command, send additional parameters.
    signalChar = 'X';
    [self writeUnsignedChar:signalChar];
    
    VTRecord *parameter = [command parameter];
    
    if (parameter) {
        [parameter writeForConnection:self];
    }
    
    // Read the response signal , which should be 'X' again confirming the
    // parameters reception.
    response = [self readUnsignedChar];
    if (response != signalChar) {
        NSLog(@"VTError: Wrong response %c to signal %c. Aborting.", response,
              signalChar);
        [self recover];
        return nil;
    }
    
    // Decode the result. This is done by a VTRecord subclass. Depending on the
    // command this could be one single record or a series of records all of the
    // same type.
    BOOL returnsList = [command returnsList];
    Class resultClass = [command resultClass];
    id returnValue = nil;
    
    // Kinda hacky, but used to detect jump in dates when downloading tracks
    double badDataJumpThreshold = 3155695.2; // 1 year in seconds
    VTTrackpointRecord * previous;
    BOOL shouldCheckForJump = (resultClass == NSClassFromString(@"VTTrackpointRecord"));;
    
    if (returnsList) {
        NSMutableArray *results = [NSMutableArray array];
        
        while ([self waitForResponseLength:1 timeout:500]) {
            VTRecord *result = [[resultClass alloc] init];
            
            
            [result readFromConnection:self];
            
            NSLog(@"\n%@", [result description]);
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////
            // Hack to detect bad data in down
            
            // Are we downloading a track?
            if (shouldCheckForJump) {
            
                // Cast the current result to the VTTrackpointRecord type so we can get the datetime
                VTTrackpointRecord * current = (VTTrackpointRecord*)result;
                // Check for the jump, and if it is greater than the threshold, return what we've downloaded so far
                // The recovery algorithm should start off where we stopped
                
                NSTimeInterval previousTimestamp = previous.timestamp.timeIntervalSinceReferenceDate;
                NSTimeInterval currentTimestamp = current.timestamp.timeIntervalSinceReferenceDate;
                
                NSLog(@"%f", currentTimestamp);

                if (previous != nil && fabs(currentTimestamp - previousTimestamp) > badDataJumpThreshold) {
                    NSLog(@"VTError: bad data detected! Previous datetime: (%f) %@, Current timestamp: (%f) %@", previousTimestamp, [previous.timestamp description], currentTimestamp, [current.timestamp description]);
                    return [results copy];
                }
                
                previous = (VTTrackpointRecord*)result;

            }
            
            [results addObject:result];
            [self.progressTracker
             performSelectorOnMainThread:@selector(incrementProgress)
             withObject:nil
             waitUntilDone:YES];
        }
        returnValue = [results copy];
        
    }
    else {
        VTRecord *result = [[resultClass alloc] init];
        
        [result readFromConnection:self];
        returnValue = result;
    }
    [self clearRTS];
    
    return returnValue;
}

- (void)writeChar:(char)c {
    [self write:[NSData dataWithBytes:&c length:1]];
}

- (void)writeUnsignedChar:(unsigned char)c {
    [self write:[NSData dataWithBytes:&c length:1]];
}

- (void)writeBool:(BOOL)boolValue {
    char v = boolValue ? 1 : 0;
    [self write:[NSData dataWithBytes:&v length:1]];
}

- (void)writeDate:(NSDate *)dateToWrite {
    VTDateTime *dateToConvert = [VTDateTime vtDateWithDate:dateToWrite];
    [self write:[dateToConvert picDateRepresentation]];
}

- (void)writeFloat:(float)floatToWrite {
    VTFloat *floatToConvert = [VTFloat vtFloatWithFloat:floatToWrite];
    [self write:[floatToConvert picFloatRepresentation]];
}

- (unsigned char)readUnsignedChar {
    NSData *r = [self readLength:1];
    if (![r length]) {
        return 0;
    }
    const unsigned char *bytes = [r bytes];
    return bytes[0];
}

- (char)readChar {
    NSData *r = [self readLength:1];
    if (![r length]) {
        return 0;
    }
    const char *bytes = [r bytes];
    return bytes[0];
}

- (BOOL)readBool {
    return [self readChar] ? YES : NO;
}

- (int)readInt32 {
    NSData *r = [self readLength:4];
    if (![r length]) {
        return 0;
    }
    const unsigned int *bytes = [r bytes];  // sloppy at best :)
    return bytes[0];
}

- (NSDate *)readDate {
    VTDateTime *dateToConvert = [VTDateTime vtDateWithPicBytes:[self readLength:[VTDateTime picRepresentationSize]]];
    return [dateToConvert date];
}

- (float)readFloat {
    VTFloat *floatToConvert =
    [VTFloat vtFloatWithPicBytes:[self readLength:[VTFloat picRepresentationSize] /*timeout:1000*/]];   // Fix app crashing when download tracks
    return [floatToConvert floatingPointNumber];
}

- (NSData *)readLength:(unsigned int)length {
    return [self readLength:length timeout:5000];
}

- (void)recover {
    NSUInteger toRead = [self waitForResponseLength:10000 timeout:1000];
    
    while (toRead) {  // Read all the stuff from the device
        [self readLength:toRead timeout:0];
        toRead = [self waitForResponseLength:10000 timeout:1000];
    }
    
    [self clearRTS];
    [self reset];
}

# pragma mark Broken Firmware code.

- (BOOL)runFirmwareUpdate:(VTFirmwareFile *)firmwareFile {
    unsigned char response;
    [self setRTS];
    
    // Send the Write Firmware command signal
    unsigned char signalChar = 'L';
    [self writeUnsignedChar:signalChar];
    
    response = [self readUnsignedChar];
    if (response != 'R') {
        NSLog(@"VTError: Wrong response %c to signal %c.", response, signalChar);
        [self recover];
        return FIRMWARE_UPDATE_FAILED;
    }
    [self clearRTS];
    
    return [self writeFirmwareFile:firmwareFile];
}

- (BOOL)writeFirmwareFile:(VTFirmwareFile *)firmwareFile {
    NSArray *firmwareData = [firmwareFile firmwareData];
    float lineCounter = 0;
    float numLinesInUpdate = (float)[firmwareData count];
    // float percentComplete = 0;
    // float percentCompleteToReport = 0;
    DWORD numBytesInTXQueue;
    DWORD numBytesInRXQueue;
    DWORD event;
    FT_STATUS status;
    [self setFlowControl:YES];
    
    NSUInteger bytesWritten;
    // NSLog(@"Starting to send firmware data.");
    // for each element in firmwareData
    for (NSData *dataLine in firmwareData) {
        status = (*pFT_GetStatus)(_ft_handle, &numBytesInRXQueue,
                                  &numBytesInTXQueue, &event);
        NSAssert(FT_SUCCESS(status), @"Unexpected status.");
        
        // NSLog(@"About to write firmware line %d.  %d bytes in RX Queue, %d bytes
        // in TX Queue.", (int)lineCounter, numBytesInRXQueue, numBytesInTXQueue);
        // write data object to connection
        
        usleep(100000);
        bytesWritten = [self write:dataLine];
        
        if (bytesWritten != [dataLine length]) {
            NSLog(@"VTError: Firmware line %d was not written successfully.  "
                  @"Aborting firmware update.",
                  (int)lineCounter);
        }
        
        [self readChar];
        [self readChar];
        [self readChar];
        
        // if (![self readFirmwareUpdateFlowControlChars]) return
        // FIRMWARE_UPDATE_FAILED;
        
        /*
         percentComplete = ((lineCounter + 1) / numLinesInUpdate) * 100;
         
         //if percentComplete is greater than or equal to percentCompleteToReport +
         5.0
         if (percentComplete >= percentCompleteToReport + 5.0)
         {
         percentCompleteToReport = percentComplete;
         
         //reportPercentComplete
         NSLog(@"Firmware update is now %f %%
         complete",percentCompleteToReport);
         
         }
         */
        
        if (lineCounter == (numLinesInUpdate - 1)) {
            // NSLog(@"Firmware update is now 100 %% complete");
            [self setFlowControl:NO];
            return FIRMWARE_UPDATE_SUCCEEDED;
        }
        
        lineCounter++;
    }
    return FIRMWARE_UPDATE_FAILED;
}

- (BOOL)readFirmwareUpdateFlowControlChars {
    unsigned char firstFlowControlCharacter = [self readChar];  // XOFF;//
    if (firstFlowControlCharacter != XOFF) {
        NSLog(@"VTError: First flow control character received from device not "
              @"valid, aborting firmware update");
        return FIRMWARE_UPDATE_FAILED;
    }
    unsigned char secondFlowControlCharacter = [self readChar];  // ACKLOD;//
    if (secondFlowControlCharacter == XON) {
        NSLog(@"VTError: ACK (0x06) not received between XOFF and XON.  This means "
              @"the end of a firmware line was received by the device but the "
              @"line did not pass the checksum test.");
        NSLog(@"Aborting firmware update.");
        return FIRMWARE_UPDATE_FAILED;
    } else if (secondFlowControlCharacter != ACKLOD) {
        NSLog(@"VTError: firmware line not acknowledged even though successfully "
              @"written. Aborting firmware update");
        return FIRMWARE_UPDATE_FAILED;
    }
    unsigned thirdFlowControlCharacter = [self readChar];  // XON;//
    if (thirdFlowControlCharacter != XON) {
        NSLog(@"VTError: Third flow control character received from device, not "
              @"valid aborting firmware update");
        return FIRMWARE_UPDATE_FAILED;
    }
    return FIRMWARE_UPDATE_SUCCEEDED;
}

#pragma mark Private methods

- (void)open {
    FT_STATUS ft_error;
    FT_HANDLE ft_handle;
    
    // Make sure the library can find the device I want.
    if ((ft_error = (*pFT_SetVIDPID)(_vendorID, _productID))) {
        NSLog(@"VTError: Call to FT_SetVIDPID failed with error %u", ft_error);
        return;
    }
    
    // Open the device, selecting it by serial number.
    const char *serialString = [_serial UTF8String];
    if ((ft_error = (*pFT_OpenEx)((char *)serialString, FT_OPEN_BY_SERIAL_NUMBER,
                                  &ft_handle))) {
        NSLog(@"VTError: Call to FT_OpenEx failed with error %u", ft_error);
        return;
    }
    
    if (!ft_handle) {
        NSLog(@"VTError: Unable to open device with serial number %@", _serial);
        return;
    }
    
    // Reset the device. Is this really necessary?
    if ((ft_error = (*pFT_ResetDevice)(ft_handle))) {
        NSLog(@"VTError: Call to FT_ResetDevice failed with error %u", ft_error);
        [self close];
        return;
    }
    
    // Purge buffers. Probably not necessary either, but a good practice.
    if ((ft_error = (*pFT_Purge)(ft_handle, FT_PURGE_RX | FT_PURGE_TX))) {
        NSLog(@"VTError: Call to FT_ResetDevice failed with error %u", ft_error);
        [self close];
        return;
    }
    
    // Set Baud Rate.
    if ((ft_error = (*pFT_SetBaudRate)(ft_handle, FT_BAUD_115200))) { // decreased baud rate from (FT_BAUD_115200) to try and fix download problems
        NSLog(@"VTError: Call to FT_SetBaudRate failed with error %u", ft_error);
        [self close];
        return;
    }
    
    // Set parameters.
    if ((ft_error = (*pFT_SetDataCharacteristics)(
                                                  ft_handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE))) {
        NSLog(@"VTError: Call to FT_SetDataCharacteristics failed with error %u",
              ft_error);
        [self close];
        return;
    }
    
    // Set timeouts
    //
    if ((ft_error = (*pFT_SetTimeouts)(ft_handle, 1000, 1000))) {
        NSLog(@"VTError: Call to FT_SetTimeouts failed with error %u", ft_error);
        [self close];
        return;
    }
    
    _ft_handle = ft_handle;
    _available = 0;
}

- (void)close {
    FT_STATUS ft_error;
    if (_ft_handle && (ft_error = (*pFT_Close)(_ft_handle))) {
        NSLog(@"VTError: Call to FT_Close failed with error %u", ft_error);
    }
    _ft_handle = 0;
    _available = 0;
}

- (void)reset {
    [self close];
    [self open];
}

- (void)setRTS {
    FT_STATUS ft_error;
    
    if ((ft_error = (*pFT_SetRts)(_ft_handle))) {
        NSLog(@"VTError: Call to FT_SetRts failed with error %u", ft_error);
        return;
    }
    usleep(50000);  // Give the device 50ms to react...
}

- (void)clearRTS {
    FT_STATUS ft_error;
    
    if ((ft_error = (*pFT_ClrRts)(_ft_handle))) {
        NSLog(@"VTError: Call to FT_ClrRts failed with error %u", ft_error);
        return;
    }
    usleep(500000);  // Give the device 500ms to react...
}

- (void)setFlowControl:(BOOL)onOff {
    FT_STATUS ft_error;
    
    if (onOff) {
        ft_error = (*pFT_SetFlowControl)(_ft_handle, FT_FLOW_XON_XOFF, XON, XOFF);
    } else {
        ft_error = (*pFT_SetFlowControl)(_ft_handle, FT_FLOW_NONE, 0, 0);
    }
    
    if (ft_error) {
        NSLog(@"VTError: Call to FT_SetFlowControl failed with error %u", ft_error);
    }
}

- (NSUInteger)write:(NSData *)data {
    if (![data length]) {
        return 0;  // Nothing to do.
    }
    FT_STATUS ft_error;
    NSUInteger sizedone;
    
    // The API used only support 32 bits on 64 bits arch. Make sure the data is
    // smaller than that.
    NSAssert([data length] < (DWORD)-1, @"Unsuported write size.");
    DWORD passed_length = (DWORD)[data length];
    
    unsigned int returned_length = 0;
    if ((ft_error = (*pFT_Write)(_ft_handle, (void *)[data bytes],
                                 passed_length, &returned_length))) {
        NSLog(@"VTError: Call to FT_Write failed with error %u", ft_error);
        return 0;
    }
    sizedone = returned_length;
    if (sizedone != [data length]) {
        NSLog(@"VTError: Call to FT_Write failed, wrote only %lu of %lu",
              (unsigned long)sizedone, (unsigned long)[data length]);
    }
    return sizedone;
}

- (NSUInteger)waitForResponseLength:(NSUInteger)length
                            timeout:(int)timeOutInMs {
    int ii;
    FT_STATUS ft_error;
    useconds_t timeoutInUSeconds = (unsigned int)timeOutInMs * 1000;
    
    for (ii = 0; ii < 100; ii++) {
        DWORD rxQueueLength;
        DWORD txQueueLength;
        DWORD event;
        
        if ((ft_error = (*pFT_GetStatus)(_ft_handle, &rxQueueLength, &txQueueLength,  &event))) {
            NSLog(@"VTError: Call to FT_GetStatus failed with error %u", ft_error);
            return 0;
        }
        
        if (txQueueLength == 0 && rxQueueLength >= length) {
            return rxQueueLength;
        }
        
        usleep(timeoutInUSeconds/100);
    }
    
    NSLog(@"waitForResponseLength timed out after waiting %d ms for %lu byte(s)", timeOutInMs, (unsigned long)length);
    NSLog(@"%@",[NSThread callStackSymbols]);
    return 0;
    
}

- (NSData *)readLength:(NSUInteger)length timeout:(int)timeOutInMs {
    NSLog(@"VTLOG: [VTConnection, readLength = %lu timeout = %d]", (unsigned long)length, timeOutInMs);  // VTLOG for debugging
    
    FT_STATUS ft_error;
    DWORD sizedone;
    char buffer[length];
    
    NSAssert(length > 0, @"WTF? Who's asking to read 0 bytes?");
    NSAssert(length <= (DWORD)-1, @"WTF? Who's asking to write so much data?");
    // The API used only support 32 bits on 64 bits arch. Make sure the data is
    // smaller than that.
    DWORD dword_length = (DWORD)length;
    
    if (_available  < length) {
        _available = [self waitForResponseLength:length timeout:timeOutInMs];
    }
    
    if ((ft_error = (*pFT_Read)(_ft_handle, buffer, dword_length, &sizedone))) {
        NSLog(@"VTError: Call to FT_Read failed with error %u", ft_error);
        /*
        NSException *e = [NSException
                          exceptionWithName:@"FT_Read failed"
                          reason:[NSString stringWithFormat:@"Call to FT_Read failed with error %u", ft_error]
                          userInfo:nil];
        @throw e;
         */
        return nil;
    }
    
    _available -= sizedone;
    
    if (sizedone != length) {
        NSLog(@"VTError: Call to FT_Read read only %u of %lu", sizedone, (unsigned long)length);
        /*
        NSException *e = [NSException
                          exceptionWithName:@"FT_Read failed"
                          reason:[NSString stringWithFormat:@"Call to FT_Read read only %u of %lu", sizedone, (unsigned long)length]
                          userInfo:nil];
        @throw e;
         */
        return nil;
    }
    
    NSLog(@"Returning bytes of length: %d", (int)length);
    
    return [NSData dataWithBytes:buffer length:length];
}

@end
