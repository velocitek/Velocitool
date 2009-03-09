//
//  VTStoredDevice.h
//  Velocitool
//
//  Created by Eric Noyau on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VTPuckSettings;

@interface VTStoredDevice : NSManagedObject {
    VTPuckSettings *deviceSettings;
}

@end

@interface VTStoredDevice (CoreDataGeneratedAccessors)

// Stuff stored in the DB
@property (retain) NSString *name;
@property (retain) NSString *serial;
@property (retain) NSSet *tracklogs;

// Derived value for display purpose. Read only.
@property (retain) NSString *identity;
@property (retain) NSString *imagePath;

// Stuff from the USB communication
@property (retain) NSDictionary *deviceInfo;
@property (retain) NSString *currentAction;


- (void)addTracklogsObject:(NSManagedObject *)value;
- (void)removeTracklogsObject:(NSManagedObject *)value;
- (void)addTracklogs:(NSSet *)value;
- (void)removeTracklogs:(NSSet *)value;

- (VTPuckSettings *)puckSettings;
- (IBAction)saveSettings:target;
- (IBAction)cancelSettings:target;
@end
