//
//  FirwareUpdateViewController.h
//  Velocitek Control Center
//
//  Created by Andrew Hughes on 10/16/16.
//
//

#import <Cocoa/Cocoa.h>

@interface FirmwareUpdateViewController : NSViewController {
    IBOutlet NSTabView* tabView;
}
- (void) showInProgressTab;
- (void) showSuccessTab;

@end
