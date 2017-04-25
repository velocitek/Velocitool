
#import "VTGlobals.h"

void VTRaiseAbstractMethodException(id object, SEL _cmd, Class abstractClass) {
  Class objectClass = [object class];
  if (objectClass == abstractClass) {
    [NSException raise:NSInvalidArgumentException
                format:@"*** -%s cannot be sent to an abstract object of class "
                       @"%@: Create a concrete instance!",
                       sel_getName(_cmd), NSStringFromClass(objectClass)];
  } else {
    [NSException
         raise:NSInvalidArgumentException
        format:@"*** -%s not implemented in the class %@.  Define -[%@ %s]!",
               sel_getName(_cmd), NSStringFromClass(objectClass),
               NSStringFromClass(objectClass), sel_getName(_cmd)];
  }
}

/*
void SetVelocitekFilesDir(NSString* path) {
    [[NSUserDefaults standardUserDefaults] setValue:path forKey:@"VELOCITEK_FILES_DIR"];
}

NSString* GetVelocitekFilesDir(void) {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"VELOCITEK_FILES_DIR"];
}

bool IsSetVelocitekFilesDir(void) {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"VELOCITEK_FILES_DIR"] != nil;
}

bool PathExistsAndIsDir(NSString* path) {
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir){
        return true;
    }
    else {
        return false;
    }
}
*/
