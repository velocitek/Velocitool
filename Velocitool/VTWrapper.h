
#import <Cocoa/Cocoa.h>

@class VTWrapperDevice;

@interface VTWrapper : NSObject {
    void *_handle;
    
@public
    void *_FT_SetVIDPID;
    void *_FT_OpenEx;
    void *_FT_SetBaudRate;
    void *_FT_SetDataCharacteristics;
    void *_FT_SetTimeouts;
    void *_FT_SetRts;
    void *_FT_ClrRts;
    void *_FT_SetFlowControl;
    void *_FT_Write;
    void *_FT_Read;
    void *_FT_GetStatus;
    void *_FT_ResetDevice;
    void *_FT_Purge;
    void *_FT_Close;
}

+ (VTWrapper *)wrapperForLibAtPath:(NSString *)path;
+ (VTWrapper *)wrapper;

- (VTWrapperDevice *)openDeviceWithVendorID:(int)vendorID productID:(int)productID serialNumber:(NSString *)serial;

@end

@interface VTWrapperDevice : NSObject {
    VTWrapper *_wrapper;
    void *_ft_handle;
    int _vendorID;
    int _productID;
    NSString * _serial;
}


- (NSData *)runCommand:(char)command responsePrefix:(char)prefix expectedLength:(int)length;
- (NSData *)runCommand:(char)command withArgumentsPrefix:(char)argPrefix arguments:(NSData *)arguments responsePrefix:(char)prefix expectedLength:(int)length;

- (void)reset;

- (void)setRTS;
- (void)clearRTS;
- (void)setFlowControl:(BOOL)onOff;
- (void)write:(NSData *)data;
- (NSData *)readLength:(int)length;
- (NSData *)readLength:(int)length timeout:(int)timeOutInMs;
- (int)waitForResponseLength:(int)length timeout:(int)timeOutInMs;
@end

