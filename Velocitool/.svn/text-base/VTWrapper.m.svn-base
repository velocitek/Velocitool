/*
 * This class is a first draft and currently UNUSED! See VTConnection instead.
 */

//
// This is really fugly, but unfortunately the device driver for the hardware Velocitek uses is only
// available in binary form, as a dyld file to be installed in /usr/local. This is a really bad idea
// to have an application dropping stuff in there, and I don't like that device driver very much. At
// some point, it will need to be redone all in free code.
//
// Anyway, to avoid the issue I'm loading the dyld file from the resource folder at launch time.
//
//

#import "VTWrapper.h"

#import <dlfcn.h>
#import "ftd2xx.h"

@interface VTWrapperDevice()
- initWithWrapper:(VTWrapper *)wrapper vendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial;
- (void)open;
- (void)close;
@end


@implementation VTWrapperDevice

- initWithWrapper:(VTWrapper *)wrapper vendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial {
    _wrapper = wrapper; // No need for retain, wrapper is a singleton
    _vendorID = vendorID;
    _productID = productID;
    _serial = [serial copy];
    
    [self open];
    
    // open had the side effect of setting the _ft_handle to the library.
    if (_ft_handle) {
        return self;
    } else {
        return nil;
    }
}


- (void)open {
    FT_STATUS ft_error;
    
    // Make sure the library can find the device I want
    //
    FT_STATUS (*FT_SetVIDPID)(DWORD dwVID, DWORD dwPID);
    
    *(void**)(&FT_SetVIDPID) = _wrapper->_FT_SetVIDPID;
    
    if ( (ft_error = (*FT_SetVIDPID)(_vendorID, _productID)) ) {
        [NSException raise:@"VTError" format:@"Call to FT_SetVIDPID failed with error %d", ft_error];
    }
    
    // Open the device
    //
    FT_HANDLE ft_handle;
    FT_STATUS (*FT_OpenEx)(PVOID pArg1, DWORD Flags, FT_HANDLE *pHandle);
    
    *(void**)(&FT_OpenEx) = _wrapper->_FT_OpenEx;
    
    if ( (ft_error = (*FT_OpenEx)((char*)[_serial UTF8String], FT_OPEN_BY_SERIAL_NUMBER, &ft_handle)) ) {
        [NSException raise:@"VTError" format:@"Call to FT_OpenEx failed with error %d", ft_error];
    }
    
    NSAssert(ft_handle, @"Crap, open failed!");
    
    // reset?
    FTD2XX_API
    FT_STATUS (*FT_ResetDevice)(FT_HANDLE ftHandle);
    
    *(void**)(&FT_ResetDevice) = _wrapper->_FT_ResetDevice;
    
    if ( (ft_error = (*FT_ResetDevice)(ft_handle)) ) {
        [NSException raise:@"VTError" format:@"Call to FT_ResetDevice failed with error %d", ft_error];
    }
    
    // purge buffers?
    FTD2XX_API
    FT_STATUS (*FT_Purge)(FT_HANDLE ftHandle, ULONG Mask);
    
    *(void**)(&FT_Purge) = _wrapper->_FT_Purge;
    
    if ( (ft_error = (*FT_Purge)(ft_handle, FT_PURGE_RX | FT_PURGE_TX)) ) {
        [NSException raise:@"VTError" format:@"Call to FT_Purge failed with error %d", ft_error];
    }
    
    
    // Set Baud Rate
    //
    FT_STATUS (*FT_SetBaudRate)(FT_HANDLE ftHandle,  ULONG BaudRate);
    *(void**)(&FT_SetBaudRate) = _wrapper->_FT_SetBaudRate;
    
    if ( (ft_error = (*FT_SetBaudRate)(ft_handle, FT_BAUD_115200)) ){
        [NSException raise:@"VTError" format:@"Unable to set the baudrate %d", ft_error];
    }
    
    // Set parameters
    //
    FT_STATUS (*FT_SetDataCharacteristics)(FT_HANDLE ftHandle, UCHAR WordLength, UCHAR StopBits, UCHAR Parity);
    *(void**)(&FT_SetDataCharacteristics) = _wrapper->_FT_SetDataCharacteristics;
    
    if ( (ft_error = (*FT_SetDataCharacteristics)(ft_handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE)) ){
        [NSException raise:@"VTError" format:@"Unable to set the data characteristics %d", ft_error];
    }
    
    // Set timeouts
    //
    FT_STATUS (*FT_SetTimeouts)(FT_HANDLE ftHandle, ULONG ReadTimeout, ULONG WriteTimeout);
    *(void**)(&FT_SetTimeouts) = _wrapper->_FT_SetTimeouts;
    
    if ( (ft_error = (*FT_SetTimeouts)(ft_handle, 500, 500)) ){
        [NSException raise:@"VTError" format:@"Unable to set the timeouts %d", ft_error];
    }
    
    _ft_handle = ft_handle;
}


- (void)reset {
    if (_ft_handle) {
        [self close];
        [self open];
    }
}


- (void)close {
    FT_STATUS ft_error;
    FT_STATUS (*FT_Close)(FT_HANDLE ftHandle);
    *(void**)(&FT_Close) = _wrapper->_FT_Close;
    
    if ( (ft_error = (*FT_Close)(_ft_handle)) ){
        [NSException raise:@"VTError" format:@"Unable to close device %d", ft_error];
    }
    _ft_handle = 0;
}


- (NSData *)runCommand:(char)command responsePrefix:(char)prefix expectedLength:(int)length {
    
    return [self runCommand:(char)command withArgumentsPrefix:'\0' arguments:nil responsePrefix:(char)prefix expectedLength:(int)length];
}


- (NSData *)runCommand:(char)command withArgumentsPrefix:(char)argPrefix arguments:(NSData *)arguments responsePrefix:(char)prefix expectedLength:(int)length {
    
    //NSLog(@"set RTS");
    [self setRTS];
    
    //NSLog(@"setting flow control");
    [self setFlowControl:NO];
    
    //NSLog(@"Writing command %c", command);
    [self write:[NSData dataWithBytes:&command length:1]];
    
    //NSLog(@"reading command!");
    NSData *confirmation = [self readLength:1];
    
    if (((char*)[confirmation bytes])[0] != command) {
        [NSException raise:@"VTError" format:@"wrong answer!"];
    }
    
    //NSLog(@"Writing X");
    [self write:[NSData dataWithBytes:"X" length:1]];
    
    if (arguments) {
        //NSLog(@"Writing args %c%@", argPrefix, arguments);
        [self write:[NSData dataWithBytes:&argPrefix length:1]];
        [self write:arguments];
    }
    
    //NSLog(@"read X!");
    confirmation = [self readLength:1];
    
    if (((char*)[confirmation bytes])[0] != 'X') {
        [NSException raise:@"VTError" format:@"wrong answer X!"];
    }
    
    //NSLog(@"read %c!", prefix);
    confirmation = [self readLength:1];
    
    if (((char*)[confirmation bytes])[0] != prefix) {
        [NSException raise:@"VTError" format:@"wrong answer %c instead of %c!", ((char*)[confirmation bytes])[0], prefix];
    }
    
    NSData *result = nil;
    
    if (length) {
        //NSLog(@"read data!");
        result = [self readLength:length];
    }
    //NSLog(@"clearRTS!");
    [self clearRTS];
    
    return result;
}


- (void)setRTS {
    FT_STATUS ft_error;
    FT_STATUS (*FT_SetRts)(FT_HANDLE ftHandle);
    *(void**)(&FT_SetRts) = _wrapper->_FT_SetRts;
    
    if ( (ft_error = (*FT_SetRts)(_ft_handle)) ){
        [NSException raise:@"VTError" format:@"Unable to set RTS %d", ft_error];
    }
    usleep(500000); // Give the device 50ms to react...
}


- (void)clearRTS {
    FT_STATUS ft_error;
    FT_STATUS (*FT_ClrRts)(FT_HANDLE ftHandle);
    *(void**)(&FT_ClrRts) = _wrapper->_FT_ClrRts;
    
    if ( (ft_error = (*FT_ClrRts)(_ft_handle)) ){
        [NSException raise:@"VTError" format:@"Unable to clear RTS %d", ft_error];
    }
    usleep(500000); // Give the device 50ms to react...
}


- (void)setFlowControl:(BOOL)onOff {
    FT_STATUS ft_error;
    FT_STATUS (*FT_SetFlowControl)(FT_HANDLE ftHandle, USHORT FlowControl, UCHAR XonChar, UCHAR XoffChar);
    *(void**)(&FT_SetFlowControl) = _wrapper->_FT_SetFlowControl;
    
    if (onOff) {
        ft_error = (*FT_SetFlowControl)(_ft_handle, FT_FLOW_XON_XOFF, 0x11, 0x13);
    } else {
        ft_error = (*FT_SetFlowControl)(_ft_handle, FT_FLOW_NONE, 0, 0);
    }
    
    if (ft_error) {
        [NSException raise:@"VTError" format:@"Unable to set flow control %d", ft_error];
    }
}


- (void)write:(NSData *)data {
    FT_STATUS ft_error;
    FT_STATUS (*FT_Write)(FT_HANDLE ftHandle, LPVOID lpBuffer, DWORD nBufferSize, LPDWORD lpBytesWritten);
    *(void**)(&FT_Write) = _wrapper->_FT_Write;
    DWORD sizedone;
    
    if ( (ft_error = (*FT_Write)(_ft_handle, (void*)[data bytes], [data length], &sizedone)) ){
        [NSException raise:@"VTError" format:@"Unable to write %d", ft_error];
    }
    
    if (sizedone != [data length]) {
        [NSException raise:@"VTError" format:@"wrote only %d of %d", sizedone, [data length]];
    }
}


- (NSData *)readLength:(int)length {
    return [self readLength:length timeout:5000];
}


- (NSData *)readLength:(int)length timeout:(int)timeOutInMs {
    FT_STATUS ft_error;
    FT_STATUS (*FT_Read)(FT_HANDLE ftHandle, LPVOID lpBuffer, DWORD nBufferSize, LPDWORD lpBytesReturned);
    *(void**)(&FT_Read) = _wrapper->_FT_Read;
    DWORD sizedone;
    char buffer[length];
    
    NSAssert(length > 0, @"WTF? Who's asking to read 0 bytes?");
    
    int available = [self waitForResponseLength:length timeout:timeOutInMs];
    
    if ( (ft_error = (*FT_Read)(_ft_handle, buffer, length, &sizedone)) ) {
        [NSException raise:@"VTError" format:@"Unable to read %d", ft_error];
    }
    
    if (sizedone != length) {
        [NSException raise:@"VTError" format:@"read only %d of %d", sizedone, length];
    }
    
    NSData *returnValue = [NSData dataWithBytes:buffer length:length];
    
    //NSLog(@"Read %d bytes (%d left)", length, available-length);
    //NSLog(@"Bytes read %@", returnValue);

    
    return returnValue;
}


- (int)waitForResponseLength:(int)length timeout:(int)timeOutInMs {
    int ii;
    
    FT_STATUS ft_error;
    FT_STATUS (*FT_GetStatus)(FT_HANDLE ftHandle, DWORD *dwRxBytes, DWORD *dwTxBytes, DWORD *dwEventDWord);
    *(void**)(&FT_GetStatus) = _wrapper->_FT_GetStatus;
        
    for(ii = 0; ii < (timeOutInMs/100) ; ii++) {
        DWORD rxQueueLength;
        DWORD txQueueLength;
        DWORD event;
        
        if ( (ft_error = (*FT_GetStatus)(_ft_handle, &rxQueueLength, &txQueueLength, &event)) ){
            [NSException raise:@"VTError" format:@"GetStatus failed %d", ft_error];
        }
        if (txQueueLength == 0 && rxQueueLength >= length) {
            return rxQueueLength;
        }

        if (usleep(100000)) { // aka 100ms
            [NSException raise:@"VTError" format:@"usleep failed! %d", errno];
        }
    }
    [NSException raise:@"VTError" format:@"No response in time"];
    return 0;
}


- (void)dealloc {
    if (_ft_handle) {
        [self close];
    }
    [_serial release];
    [super dealloc];
}


@end



static VTWrapper *the_one_true_instance = Nil;

@interface VTWrapper (Private)
- initForLibAtPath:(NSString *)path;
@end

@implementation VTWrapper

+ (VTWrapper *)wrapperForLibAtPath:(NSString *)path {
    if (!the_one_true_instance) {
        the_one_true_instance = [[VTWrapper alloc] initForLibAtPath:path];
    }
    
    return the_one_true_instance;
}


+ (VTWrapper *)wrapper {
    if (!the_one_true_instance) {
        [NSException raise:@"VTError" format:@"Don't call -wrapper first! "];
    }
    return the_one_true_instance;
}


- (void *)_functionForName:(NSString *)name {
    void *function = dlsym(_handle, [name UTF8String]);
    if (!function) {
        [NSException raise:@"VTNoSymbol" format:@"Expected symbol '%@' not found in library", name];
    }
    return function;
}


- initForLibAtPath:(NSString *)path {
    _handle = dlopen([path UTF8String], RTLD_LAZY | RTLD_GLOBAL);

    if (!_handle) {
		[NSException raise:@"VTNoLibrary" format:@"Can't load the library at %@: %s", path, dlerror()];
    }
    _FT_SetVIDPID              = [self _functionForName:@"FT_SetVIDPID"];
    _FT_OpenEx                 = [self _functionForName:@"FT_OpenEx"];
    _FT_SetBaudRate            = [self _functionForName:@"FT_SetBaudRate"];
    _FT_SetDataCharacteristics = [self _functionForName:@"FT_SetDataCharacteristics"];
    _FT_SetTimeouts            = [self _functionForName:@"FT_SetTimeouts"];
    _FT_SetRts                 = [self _functionForName:@"FT_SetRts"];
    _FT_ClrRts                 = [self _functionForName:@"FT_ClrRts"];
    _FT_SetFlowControl         = [self _functionForName:@"FT_SetFlowControl"];
    _FT_Write                  = [self _functionForName:@"FT_Write"];
    _FT_Read                   = [self _functionForName:@"FT_Read"];
    _FT_GetStatus              = [self _functionForName:@"FT_GetStatus"];
    _FT_ResetDevice            = [self _functionForName:@"FT_ResetDevice"];
    _FT_Purge                  = [self _functionForName:@"FT_Purge"];
    _FT_Close                  = [self _functionForName:@"FT_Close"];
    
    return self;
}


- (VTWrapperDevice *)openDeviceWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial {
    return [[[VTWrapperDevice alloc] initWithWrapper:self vendorID:vendorID productID:productID serialNumber:serial] autorelease];
}


@end
