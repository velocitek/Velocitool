//
//  VTStoredDevice.h
//  Velocitool
//
//  Created by Eric Noyau on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VTStoredDevice : NSManagedObject {
}

@end

@interface VTStoredDevice (CoreDataGeneratedAccessors)

@property (retain) NSString *name;
@property (retain) NSString *serial;
@property (retain) NSSet *tracklogs;

@property (retain) NSDictionary *deviceInfo;
@property (retain) NSString *currentAction;
@property (retain) NSString *identity;
@property (retain) NSString *imagePath;

- (void)addTracklogsObject:(NSManagedObject *)value;
- (void)removeTracklogsObject:(NSManagedObject *)value;
- (void)addTracklogs:(NSSet *)value;
- (void)removeTracklogs:(NSSet *)value;
@end
