//
//  VTPuckSettingsController.h
//  Velocitool
//
//  Created by Eric Noyau on 02/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VTPuckSettingsController : NSObjectController {

}

@property (readonly) NSString *barGraphLabel;
@property (readonly) BOOL barGraphEnabled;
@property (readonly) BOOL declinationEnabled;
@property (readonly) BOOL everythingOff;

@end

