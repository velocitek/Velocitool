#import <Cocoa/Cocoa.h>
#import "VTDeviceLoader.h"
#import "VTDevice.h"

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    VTDeviceLoader *loader = [VTDeviceLoader loader];
    
    for (VTDevice *device in [loader devices]) {
        
        NSLog(@"%@ (%@ v.%@)\n%@",
              [device model],
              [device serial],
              [device firmwareVersion],
              [device deviceSettings]
        );
    }
    
    [pool drain];
    return 0;
}
