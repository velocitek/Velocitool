#import <Cocoa/Cocoa.h>

@class VTPuckSettings;

@interface VTStoredDevice : NSManagedObject {
    VTPuckSettings *deviceSettings;
}

@end

@interface VTStoredDevice (CoreDataGeneratedAccessors)

// Stuff stored in the DB
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *serial;
@property (nonatomic, retain) NSSet *tracklogs;

// Derived value for display purpose. Read only.
@property (nonatomic, retain) NSString *identity;
@property (nonatomic, retain) NSString *imagePath;

// Stuff from the USB communication
@property (nonatomic, retain) NSDictionary *deviceInfo;
@property (nonatomic, retain) NSString *currentAction;


- (void)addTracklogsObject:(NSManagedObject *)value;
- (void)removeTracklogsObject:(NSManagedObject *)value;
- (void)addTracklogs:(NSSet *)value;
- (void)removeTracklogs:(NSSet *)value;

- (VTPuckSettings *)puckSettings;

- (IBAction)saveSettings:target;
- (IBAction)cancelSettings:target;
@end
