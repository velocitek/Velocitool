#import "VTFirmwareUpdateOperation.h"
#import "VTDevice.h"
#import "VTGlobals.h"


@implementation VTFirmwareUpdateOperation

@synthesize done;
@synthesize success;

- (id)initWithDevice:(VTDevice*)deviceToUpdate path:(NSString*)path {
    if ((self = [super init])) {
        device = deviceToUpdate;
        pathToFirmwareFile = path;
        
        [self setDone:NO];
        [self setSuccess:NO];
    }
    return self;
}

- (void)main
{
    NSLog(@"VTLOG: [VTFirmwareUpdateOperation, testMain]");  // VTLOG for debugging
    
    //NOTE: Make sure this is the absolute path to where the firmware file is on your machine
    if([device updateFirmware:pathToFirmwareFile])
    {
        [self setSuccess: YES];
    }
    else
    {
        // TODO: throw up alert
        [self setSuccess:NO];
    }
    
    [self setDone:YES];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VTUpdateFirmwareFinishedNotification object:self];
    
}


@end
