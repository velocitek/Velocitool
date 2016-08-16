#import "VTFirmwareUpdateOperation.h"
#import "VTDevice.h"


@implementation VTFirmwareUpdateOperation

@synthesize done;
@synthesize success;

- (id)initWithDevice:(VTDevice*)deviceToUpdate {
  if ((self = [super init])) {
    device = [deviceToUpdate retain];

    [self setDone:NO];
    [self setSuccess:NO];
  }
  return self;
}

- (void)main 
{
    NSLog(@"VTLOG: [VTFirmwareUpdateOperation, testMain]");  // VTLOG for debugging
    
	//NSLog(@"Hello World!");
		
	//NOTE: Make sure this is the absolute path to where the firmware file is on your machine
	if([device updateFirmware:@"/Users/alec/Dropbox/Code/Velocitool/Velocitek_SpeedPuck_1-4.hex"])
	{
				
		//NSLog(@"Success!");
		[self setSuccess: YES];
		
	}
	else 
	{
		//NSLog(@"Failure... boo hoo!");
	}
	 
	[self setDone:YES];
	
	
}


@end
