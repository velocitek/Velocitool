
#import "MainWindowController.h"
#import "TrackLogViewController.h"
#import "TrackFileViewController.h"


//For test
#import "VTDevice.h"
#import "VTCommand.h"
#import "VTRecord.h"


@implementation MainWindowController

- (IBAction)changeViewController:(id)sender
{
	static int i = 0;
	
	i++;
	
	i = i % 2;
	
	[self displayViewController:[viewControllers objectAtIndex:i]];
	
}

-(id)init
{
	
	if(![super initWithWindowNibName:@"MainWindow"])
		return nil;
	
	viewControllers = [[NSMutableArray alloc] init];
	
	TrackLogViewController *trackLogViewController = [[TrackLogViewController alloc] init];
	[viewControllers addObject:trackLogViewController];
	[trackLogViewController release];
	
	TrackFileViewController *trackFileViewController = [[TrackFileViewController alloc] init];
	[viewControllers addObject:trackFileViewController];
	[trackFileViewController release];
	
	[self displayViewController:[viewControllers objectAtIndex:0]];
	
	return self;
}

-(void)dealloc
{
	[viewControllers release];
	[super dealloc];
	
}

-(void)displayViewController:(NSViewController *)vc
{
	//Try to end editing
	NSWindow *w = [box window];
	BOOL ended = [w makeFirstResponder:w];
	if(!ended) {
		NSBeep();
		return;
	}
	
	//Put the view in the box
	NSView *v = [vc view];
	[box setContentView:v];
}



@end
