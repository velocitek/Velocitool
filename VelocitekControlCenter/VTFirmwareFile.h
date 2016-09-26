#import <Cocoa/Cocoa.h>
#import "VTConnection.h"

#import "VTFirmwareFile.h"


@interface VTFirmwareFile : NSObject {
	
	@protected NSString *rawFirmwareString;
	NSMutableArray *__weak firmwareData;
	
}

@property (weak, nonatomic, readonly) NSMutableArray *firmwareData;

+ (id)vtFirmwareFileWithFilePath:(NSString *)filePath;

@end


