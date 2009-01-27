//
//  VTGlobals.m
//  Velocitool
//
//  Created by Eric Noyau on 20/01/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VTGlobals.h"


void VTRaiseAbstractMethodException(id object, SEL _cmd, Class abstractClass)
{
    Class objectClass = [object class];
    if (objectClass == abstractClass) {
        [NSException raise:NSInvalidArgumentException format:@"*** -%s cannot be sent to an abstract object of class %@: Create a concrete instance!", (const char *)(_cmd), NSStringFromClass(objectClass)];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"*** -%s not implemented in the class %@.  Define -[%@ %s]!", (const char *)(_cmd), NSStringFromClass(objectClass), NSStringFromClass(objectClass), (const char *)(_cmd)];
    }
}
