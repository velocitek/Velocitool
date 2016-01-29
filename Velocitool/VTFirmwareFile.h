//
//  VTFirmwareFile.h
//  Velocitool
//
//  Created by Alec Stewart on 4/10/10.
//  Copyright 2010 Velocitek. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VTConnection.h"

#import "VTFirmwareFile.h"


@interface VTFirmwareFile : NSObject {
	
	@protected NSString *rawFirmwareString;
	NSMutableArray *firmwareData;
	
}

@property (nonatomic, readonly) NSMutableArray *firmwareData;

+ (id)vtFirmwareFileWithFilePath:(NSString *)filePath;

@end


