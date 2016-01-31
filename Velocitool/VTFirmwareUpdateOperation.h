#import <Cocoa/Cocoa.h>
@class VTDevice;


@interface VTFirmwareUpdateOperation : NSOperation 
{
	
	VTDevice *device;
	BOOL done;
	BOOL success;

}

@property (nonatomic, readwrite) BOOL done;
@property (nonatomic, readwrite) BOOL success;

- (id)initWithDevice:(VTDevice*)deviceToUpdate;

@end



