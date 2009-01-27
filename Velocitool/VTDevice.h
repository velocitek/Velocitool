
#import <Cocoa/Cocoa.h>

@class VTWrapperDevice;
//
// This represent a Velocitek device
//

@interface VTDevice : NSObject {
    NSDictionary *_properties;
    VTWrapperDevice *_wrapperDevice;
}

+ deviceForProperties:(NSDictionary *)properties;

@end
