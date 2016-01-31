#import "VTProgressTracker.h"

@interface VTProgressTracker (private)

- (NSString *)constructProgressDisplayString;
- (void)updatePercentage;

@end

@implementation VTProgressTracker

@synthesize progressPercentageToDisplay;
@synthesize progressPercentage;
@synthesize currentProgress;
@synthesize goal;

- (void)setCurrentProgress:(float)newValue
{
	currentProgress = newValue;
	[self updatePercentage];
}

- (void)setGoal:(float)newGoal
{
	goal = newGoal;
	[self updatePercentage];
}

- (void)updatePercentage
{
	[self setProgressPercentage:(currentProgress / goal) * 100];
	[self setProgressPercentageToDisplay:[self constructProgressDisplayString]];
}

- (void)incrementProgress
{
	[self setCurrentProgress:(currentProgress + 1)];
}

- (NSString *)constructProgressDisplayString
{
	NSString *displayString = [NSString stringWithFormat:@"%.0f",progressPercentage];
	return displayString;
}

- (float)progressPercentage
{
	//NSLog(@"-progressPercentage is returning %f", progressPercentage);
	return progressPercentage;
}

- (void)setProgressPercentage:(float)x
{
	
	//NSLog(@"-setProgressPercentage: is called with %f",x);
	progressPercentage	= x;
}

- (void)dealloc
{
	[progressPercentageToDisplay release];
	[super dealloc];
}



@end
