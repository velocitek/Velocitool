//
//  FirwareUpdateViewController.m
//  Velocitek Control Center
//
//  Created by Andrew Hughes on 10/16/16.
//
//

#import "FirmwareUpdateViewController.h"

@interface FirmwareUpdateViewController ()

@end

@implementation FirmwareUpdateViewController


- (id)init {
    if((self = [super initWithNibName:@"FirmwareUpdateView" bundle: nil])) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [tabView selectTabViewItemWithIdentifier:@"INPROGRESS"];
}

- (void) showInProgressTab {
    [tabView selectTabViewItemWithIdentifier:@"INPROGRESS"];
}

- (void) showSuccessTab {
    [tabView selectTabViewItemWithIdentifier:@"SUCCESS"];
}


@end
