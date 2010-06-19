//
//  MainWindowController.h
//  Velocitool
//
//  Created by Eric Noyau on 07/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class VTDevice;


@interface MainWindowController : NSWindowController {
    
	IBOutlet NSBox *box;
	IBOutlet NSButton *viewSwitchButton;
	NSMutableArray *viewControllers;
    
}



- (IBAction)changeViewController:(id)sender;

-(void)displayViewController:(NSViewController *)vc;

@end
