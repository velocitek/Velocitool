#import <CoreFoundation/CoreFoundation.h>
#import "VTWrapper.h"
#import "VTDeviceLoader.h"
#import "VTDevice.h"

@interface Observer:NSObject {} @end
@implementation Observer
- (void)ping:(NSNotification *)note {
    NSArray *devices = [[VTDeviceLoader loader] devices];
    //NSLog(@"Devices = %@", devices);
    
    for (VTDevice *device in devices) {
        NSLog(@"Reset settings on %@", device);
        [device setDeviceSettings:nil];
        NSLog(@"Done resetting settings on %@", device);
    }
    
}
@end


int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSAutoreleasePool *inner_pool = [NSAutoreleasePool new];
    
    // Initialize the wrapper
    [VTWrapper wrapperForLibAtPath:@"/Users/noyau/Projects/velocitek/FTDI Driver/D2XX/bin/libftd2xx.0.1.4.dylib"];\
    
    [[NSNotificationCenter defaultCenter] addObserver:[Observer new] selector:@selector(ping:) name:VTDeviceChangedNotification object:[VTDeviceLoader loader]];
    
    [[[Observer new] autorelease] ping:nil];
    
    // Start the run loop. Now we'll receive notifications.
    NSLog(@"Starting run loop");
    [inner_pool release];

    CFRunLoopRun();
    
    // We should never get here
    NSLog(@"Unexpectedly back from CFRunLoopRun()!");
    [pool release];
    return 0;
}
