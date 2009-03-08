
#import "VTConnection.h"
#import "VTCommand.h"

#import <dlfcn.h>
#import "ftd2xx.h"


//
// This is really fugly, but unfortunately the device driver for the hardware Velocitek uses is only
// available in binary form, as a dyld file to be installed in /usr/local. This is a really bad idea
// to have an application dropping stuff in there, and I don't like that device driver very much. At
// some point, it will need to be redone all in free code.
//
// Anyway, to avoid the issue I'm loading the dyld file from the resource folder at launch time. All
// the functions i use are dynamically looked up and stored in those static variables.
//
//
static FT_STATUS (*pFT_SetVIDPID)(DWORD dwVID, DWORD dwPID);
static FT_STATUS (*pFT_OpenEx)(PVOID pArg1, DWORD Flags, FT_HANDLE *pHandle);
static FT_STATUS (*pFT_ResetDevice)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_Purge)(FT_HANDLE ftHandle, ULONG Mask);
static FT_STATUS (*pFT_SetBaudRate)(FT_HANDLE ftHandle,  ULONG BaudRate);
static FT_STATUS (*pFT_SetDataCharacteristics)(FT_HANDLE ftHandle, UCHAR WordLength, UCHAR StopBits, UCHAR Parity);
static FT_STATUS (*pFT_SetTimeouts)(FT_HANDLE ftHandle, ULONG ReadTimeout, ULONG WriteTimeout);
static FT_STATUS (*pFT_Close)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_SetRts)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_ClrRts)(FT_HANDLE ftHandle);
static FT_STATUS (*pFT_SetFlowControl)(FT_HANDLE ftHandle, USHORT FlowControl, UCHAR XonChar, UCHAR XoffChar);
static FT_STATUS (*pFT_Write)(FT_HANDLE ftHandle, LPVOID lpBuffer, DWORD nBufferSize, LPDWORD lpBytesWritten);
static FT_STATUS (*pFT_Read)(FT_HANDLE ftHandle, LPVOID lpBuffer, DWORD nBufferSize, LPDWORD lpBytesReturned);
static FT_STATUS (*pFT_GetStatus)(FT_HANDLE ftHandle, DWORD *dwRxBytes, DWORD *dwTxBytes, DWORD *dwEventDWord);

@interface VTConnection()
- initWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial;

- (void)open;
- (void)close;
- (void)reset;

- (void)setRTS;
- (void)clearRTS;

- (void)setFlowControl:(BOOL)onOff;
- (int)write:(NSData *)data;
- (NSData *)readLength:(unsigned int)length timeout:(int)timeOutInMs;
- (unsigned int)waitForResponseLength:(unsigned int)length timeout:(int)timeOutInMs;

@end

@implementation VTConnection

+ initialize {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"libftd2xx.0.1.4.dylib" ofType:@""];

    void *handle = dlopen([path UTF8String], RTLD_LAZY | RTLD_GLOBAL);
    NSAssert2(handle, @"Can't load the library at %@: %s", path, dlerror());

    pFT_SetVIDPID              = dlsym(handle, "FT_SetVIDPID");             NSAssert(pFT_SetVIDPID, @"FT_SetVIDPID");
    pFT_OpenEx                 = dlsym(handle, "FT_OpenEx");                 NSAssert(pFT_OpenEx, @"FT_OpenEx");
    pFT_SetBaudRate            = dlsym(handle, "FT_SetBaudRate");            NSAssert(pFT_SetBaudRate, @"FT_SetBaudRate");
    pFT_SetDataCharacteristics = dlsym(handle, "FT_SetDataCharacteristics"); NSAssert(pFT_SetDataCharacteristics, @"FT_SetDataCharacteristics");
    pFT_SetTimeouts            = dlsym(handle, "FT_SetTimeouts");            NSAssert(pFT_SetTimeouts, @"FT_SetTimeouts");
    pFT_SetRts                 = dlsym(handle, "FT_SetRts");                 NSAssert(pFT_SetRts, @"FT_SetRts");
    pFT_ClrRts                 = dlsym(handle, "FT_ClrRts");                 NSAssert(pFT_ClrRts, @"FT_ClrRts");
    pFT_SetFlowControl         = dlsym(handle, "FT_SetFlowControl");         NSAssert(pFT_SetFlowControl, @"FT_SetFlowControl");
    pFT_Write                  = dlsym(handle, "FT_Write");                  NSAssert(pFT_Write, @"FT_Write");
    pFT_Read                   = dlsym(handle, "FT_Read");                   NSAssert(pFT_Read, @"FT_Read");
    pFT_GetStatus              = dlsym(handle, "FT_GetStatus");              NSAssert(pFT_GetStatus, @"FT_GetStatus");
    pFT_ResetDevice            = dlsym(handle, "FT_ResetDevice");            NSAssert(pFT_ResetDevice, @"FT_ResetDevice");
    pFT_Purge                  = dlsym(handle, "FT_Purge");                  NSAssert(pFT_Purge, @"FT_Purge");
    pFT_Close                  = dlsym(handle, "FT_Close");                  NSAssert(pFT_Close, @"FT_Close");
    
    return self;
}

+ connectionWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial {
    return [[[self alloc] initWithVendorID:vendorID productID:productID serialNumber:serial] autorelease];
}

- initWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial {
    [super init];
    _vendorID = vendorID;
    _productID = productID;
    _serial = serial;
    
    [self open];
    
    return _ft_handle ? self: nil;
}

- (void)dealloc {
    [self close];
    [super dealloc];
}

- (void)open {
    FT_STATUS ft_error;
    FT_HANDLE ft_handle;
    
    // Make sure the library can find the device I want
    //
    if ( (ft_error = (*pFT_SetVIDPID)(_vendorID, _productID)) ) {
        NSLog(@"VTError: Call to FT_SetVIDPID failed with error %d", ft_error);
        return;
    }
    
    // Open the device
    //
    if ( (ft_error = (*pFT_OpenEx)((char*)[_serial UTF8String], FT_OPEN_BY_SERIAL_NUMBER, &ft_handle)) ) {
        NSLog(@"VTError: Call to FT_OpenEx failed with error %d", ft_error);
        return;
    }

    if(!ft_handle) {
        NSLog(@"VTError: Unable to open device with serial number %@", _serial);
        return;
    }
    
    // reset. Is this really necessary?
    //
    if ( (ft_error = (*pFT_ResetDevice)(ft_handle)) ) {
        NSLog(@"VTError: Call to FT_ResetDevice failed with error %d", ft_error);
        [self close];
        return;
    }
    
    // purge buffers. Probably not necessary either.
    //
    if ( (ft_error = (*pFT_Purge)(ft_handle, FT_PURGE_RX | FT_PURGE_TX)) ) {
        NSLog(@"VTError: Call to FT_ResetDevice failed with error %d", ft_error);
        [self close];
        return;
    }
    
    // Set Baud Rate
    //    
    if ( (ft_error = (*pFT_SetBaudRate)(ft_handle, FT_BAUD_115200)) ){
        NSLog(@"VTError: Call to FT_SetBaudRate failed with error %d", ft_error);
        [self close];
        return;
    }
    
    // Set parameters
    //
    if ( (ft_error = (*pFT_SetDataCharacteristics)(ft_handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE)) ){
        NSLog(@"VTError: Call to FT_SetDataCharacteristics failed with error %d", ft_error);
        [self close];
        return;
    }
    
    // Set timeouts
    //
    if ( (ft_error = (*pFT_SetTimeouts)(ft_handle, 500, 500)) ){
        NSLog(@"VTError: Call to FT_SetTimeouts failed with error %d", ft_error);
        [self close];
        return;
    }
    
    _ft_handle = ft_handle;
    _available = 0;
}


- (void)close {
    FT_STATUS ft_error;
    if (_ft_handle && (ft_error = (*pFT_Close)(_ft_handle))) {
        NSLog(@"VTError: Call to FT_Close failed with error %d", ft_error);
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
    
    if ( (ft_error = (*pFT_SetRts)(_ft_handle)) ){
        NSLog(@"VTError: Call to FT_SetRts failed with error %d", ft_error);
        return;
    }
    usleep(500000); // Give the device 50ms to react...
}

- (void)clearRTS  {
    FT_STATUS ft_error;
    if ( (ft_error = (*pFT_ClrRts)(_ft_handle)) ){
        NSLog(@"VTError: Call to FT_ClrRts failed with error %d", ft_error);
        return;
    }
    usleep(500000); // Give the device 50ms to react...
}

- (void)setFlowControl:(BOOL)onOff {
    FT_STATUS ft_error;

    if (onOff) {
        ft_error = (*pFT_SetFlowControl)(_ft_handle, FT_FLOW_XON_XOFF, 0x11, 0x13);
    } else {
        ft_error = (*pFT_SetFlowControl)(_ft_handle, FT_FLOW_NONE, 0, 0);
    }
    
    if (ft_error) {
        NSLog(@"VTError: Call to FT_SetFlowControl failed with error %d", ft_error);
    }
}


- (int)write:(NSData *)data {
    FT_STATUS ft_error;
    DWORD sizedone;
    
    if ( (ft_error = (*pFT_Write)(_ft_handle, (void*)[data bytes], [data length], &sizedone)) ){
        NSLog(@"VTError: Call to FT_Write failed with error %d", ft_error);
        return 0;
    }
    
    if (sizedone != [data length]) {
        NSLog(@"VTError: Call to FT_Write failed, wrote only %d of %d", sizedone, [data length] );
    }
    return sizedone;
}

- (NSData *)readLength:(unsigned int)length {
    return [self readLength:length timeout:5000];
}

- (NSData *)readLength:(unsigned int)length timeout:(int)timeOutInMs {
    FT_STATUS ft_error;
    DWORD sizedone;
    char buffer[length];
    
    NSAssert(length > 0, @"WTF? Who's asking to read 0 bytes?");
    
    if(_available < length) {
        _available = [self waitForResponseLength:length timeout:timeOutInMs];
    }
    
    if ( (ft_error = (*pFT_Read)(_ft_handle, buffer, length, &sizedone)) ) {
        NSLog(@"VTError: Call to FT_Read failed with error %d", ft_error);
        return nil;
    }
    
    _available -= sizedone;
    
    if (sizedone != length) {
        NSLog(@"VTError: Call to FT_Read read only %d of %d", sizedone, length);
        return nil;
    }
    
    NSData *data = [NSData dataWithBytes:buffer length:length];
    NSLog(@"Read %d (%d left) %@", sizedone, _available, data);
    return data;
}

- (unsigned int)waitForResponseLength:(unsigned int)length timeout:(int)timeOutInMs {
    int ii;
    FT_STATUS ft_error;
    useconds_t timeoutInUSeconds = (unsigned int)timeOutInMs * 1000;
    
    for(ii = 0; ii < 100 ; ii++) {
        DWORD rxQueueLength;
        DWORD txQueueLength;
        DWORD event;
        
        if ( (ft_error = (*pFT_GetStatus)(_ft_handle, &rxQueueLength, &txQueueLength, &event)) ){
            NSLog(@"VTError: Call to FT_GetStatus failed with error %d", ft_error);
            return 0;
        }
        
        if (txQueueLength == 0 && rxQueueLength >= length) {
            return rxQueueLength;
        }
        
        usleep(timeoutInUSeconds / 100);
    }
    NSLog(@"VTError: No response FT_GetStatus during the alloted time");
    return 0;
}

- (void)_recover {
    
    unsigned int toRead = [self waitForResponseLength:10000 timeout:5000];
    
    while(toRead) { // Read all the stuff from the device
        NSLog(@"reading %d of recovery", toRead);
        [self readLength:toRead timeout:0];
        toRead = [self waitForResponseLength:10000 timeout:1000];
    }
    
    [self clearRTS];
    [self close];
    [self open];
}

- runCommand:(VTCommand *)command {
    unsigned char response;
    
    [self setRTS];
    
    [self setFlowControl:[command flowControl]];
    
    unsigned char signalChar = [command signal];
    NSLog(@"signalling command %c", signalChar);

    [self writeUnsignedChar:signalChar];
    
    response = [self readUnsignedChar];
    if (response != signalChar) {
        NSLog(@"VTError: Wrong response %c to signal %c. Aborting.", response, signalChar);
        [self _recover];
        return nil;
    }
    
    signalChar = 'X';
    NSLog(@"signalling args %c", signalChar);
    [self writeUnsignedChar:signalChar];
    
    VTRecord *parameter = [command parameter];
    
    if (parameter) {
        NSLog(@"Writing args %@", parameter);
        [self writeUnsignedChar:[[parameter class] recordHeader]];
        [parameter writeDeviceDataForConnection:self];
    }
            
    response = [self readUnsignedChar];    
    if (response != signalChar) {
        NSLog(@"VTError: Wrong response %c to signal %c. Aborting.", response, signalChar);
        [self _recover];
        return nil;
    }
    
    BOOL returnsList = [command returnsList];
    Class resultClass = [command resultClass];
    signalChar = [resultClass recordHeader];
    id returnValue = nil;
    
    if(returnsList) {
        NSMutableArray *results = [NSMutableArray array];
        
        while([self waitForResponseLength:1 timeout:5000]) {
            
            VTRecord *result = [[[resultClass alloc] init] autorelease];
            if(signalChar) {
                NSLog(@"reading result record %c", signalChar);
                response = [self readUnsignedChar];
                
                if (response != signalChar) {
                    NSLog(@"VTError: Record header invalid %c. expected %c. Aborting.", response, signal);
                    [self _recover];
                    return nil;
                }
                [result readDeviceDataFromConnection:self];
                [results addObject:result];
            }            
        }
        returnValue = [results copy];
    } else {
        VTRecord *result = [[[resultClass alloc] init] autorelease];
        if(signalChar) {
            NSLog(@"reading result record %c", signalChar);
            response = [self readUnsignedChar];
    
            if (response != signalChar) {
                NSLog(@"VTError: Record header invalid %c. expected %c. Aborting.", response, signal);
                [self _recover];
                return nil;
            }
        }
        [result readDeviceDataFromConnection:self];
        returnValue = result;
    }
    [self clearRTS];
    NSLog(@"Done!");

    return returnValue;
}

- (void)writeChar:(char)c {
    unsigned char v = ((unsigned char)c) + 128; // Whatever!
    [self writeUnsignedChar:v];
    //[self write:[NSData dataWithBytes:&c length:1]];
}

- (void)writeUnsignedChar:(unsigned char)c {
    [self write:[NSData dataWithBytes:&c length:1]];
}

- (void)writeBool:(BOOL)boolValue {
    char v = boolValue ? 0: 1;
    [self write:[NSData dataWithBytes:&v length:1]];
}

- (unsigned char)readUnsignedChar {
    NSData *r = [self readLength:1];
    
    if(r) {
        const unsigned char *bytes = [r bytes];
        return bytes[0];
    } else {
        return 0;
    }
}

- (char)readChar {
    return (char)(((int)[self readUnsignedChar]) - 128);
    
}


- (BOOL)readBool {
    return [self readChar]? YES: NO;
}

- (int)readInt32 {
    NSData *r = [self readLength:4];
    
    if(r) {
        const unsigned int *bytes = [r bytes]; // sloppy at best :)
        return bytes[0];
    } else {
        return 0;
    }
}

- (NSDate *)readDate {
    int year = 2000 + [self readUnsignedChar];
    int month = [self readChar];
    int day = [self readChar];
    int hour = [self readChar];
    int minutes = [self readChar];
    int seconds = [self readChar];
    int hundreth = [self readChar];
    
    // Can't find a NSDate constructor precise to the hundreth of a second for some reason...
    NSDate *when = [NSDate dateWithString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", year, month, day, hour, minutes, seconds]];
    [when addTimeInterval:(hundreth / 100.0)];
    return when;
}


@end
/*
 float conversion use ldexp(), frexp().
 NAME
 ldexp -- multiply by integer power of 2
 
 SYNOPSIS
 #include <math.h>
 
 double
 ldexp(double x, int n);
 
 long double
 ldexpl(long double x, int n);
 
 float
 ldexpf(float x, int n);
 
 DESCRIPTION
 The ldexp() functions multiply x by 2 to the power n.
 
 SPECIAL VALUES
 ldexp(+-0, n) returns +-0.
 
 ldexp(x, 0) returns x.
 
 ldexp(+-infinity, n) returns +-infinity.
 
 SEE ALSO
 math(3), scalbn(3)
 
 STANDARDS
 The ldexp() functions conform to ISO/IEC 9899:1999(E).
 
 
 
 On both Intel and PPC macs, the type float corresponds to IEEE-754 single
 precision.  A single-precision number is represented in 32 bits, and has a
 precision of 24 significant bits, roughly like 7 significant decimal dig-
 its.  8 bits are used to encode the exponent, which gives an exponent range
 from -126 to 127, inclusive.
 
 The header <float.h> defines several useful constants for the float type:
 FLT_MANT_DIG - The number of binary digits in the significand of a float.
 FLT_MIN_EXP - One more than the smallest exponent available in the float
 type.
 FLT_MAX_EXP - One more than the largest exponent available in the float
 type.
 FLT_DIG - the precision in decimal digits of a float.  A decimal value with
 this many digits, stored as a float, always yields the same value up to
 this many digits when converted back to decimal notation.
 FLT_MIN_10_EXP - the smallest n such that 10**n is a non-zero normal number
 as a float.
 FLT_MAX_10_EXP - the largest n such that 10**n is finite as a float.
 FLT_MIN - the smallest positive normal float.
 FLT_MAX - the largest finite float.
 FLT_EPSILON - the difference between 1.0 and the smallest float bigger than
 1.0.
 
 */
