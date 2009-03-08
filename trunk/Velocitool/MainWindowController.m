
#import "MainWindowController.h"
#import "VTDeviceLoader.h"
#import "VTStoredDevice.h"


@implementation MainWindowController

- (void)awakeFromNib {
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceAdded:) name:VTDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceRemoved:) name:VTDeviceRemovedNotification object:nil];

    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_needsave:) name:NSManagedObjectContextObjectsDidChangeNotification object:moc];
}

- (void)_needsave:(NSNotification *)note {
    [self performSelector:@selector(_autosave:) withObject:[note userInfo] afterDelay:0.0];
}

- (void)_autosave:changes {
    NSError *error;
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];

    NSLog(@"Saving changes: %@", changes);
    
    if (![moc save:&error]) {
        BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
    
        if (errorResult == YES) {
            // now what?
        }
    }
}


- (void)_deviceAdded:(NSNotification *)note {
    NSString *serial = [[note userInfo] objectForKey:@"serial"];
    
    if(serial) {
        // Try to fetch this object
        VTStoredDevice *storedDevice = nil;

        NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Device" inManagedObjectContext:moc];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings...
        [request setPredicate:[NSPredicate predicateWithFormat:@"(serial = %@)", serial]];
        
        
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        if (array == nil)
        {
            [[NSApplication sharedApplication] presentError:error];
            return;
        }
        
        if (0 == [array count]) {
            // create it
            storedDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:moc];
            [storedDevice setSerial:serial];
            
            if (![moc save:&error]) {
                [[NSApplication sharedApplication] presentError:error];
                return;
            }
        } else {
            storedDevice = [array objectAtIndex:0];
        }
        
        if (![[deviceController arrangedObjects] containsObject:storedDevice]) {
            [deviceController addObject:storedDevice];
        }
    }
}

- (void)_deviceRemoved:(NSNotification *)note {
    NSString *serial = [[note userInfo] objectForKey:@"serial"];
    
    if(serial) {
        for (VTStoredDevice *storedDevice in [deviceController arrangedObjects]) {
            if ([[storedDevice serial] isEqual:serial]) {
                [deviceController removeObject:storedDevice];
                
                // I can't find a way to tell this stupid array controller to not
                // *delete* the object from the store when I just want to remove it
                // from view.
                
                break;
            }
        }
    }
}

- (IBAction)selectionChanged:sender {
}


@end
