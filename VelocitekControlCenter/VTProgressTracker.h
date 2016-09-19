#import <Cocoa/Cocoa.h>


@interface VTProgressTracker : NSObject {
	
	NSString *progressPercentageToDisplay;
	float progressPercentage;
	float currentProgress;
	float goal;

}
@property (nonatomic, readwrite, retain) NSString *progressPercentageToDisplay;
@property (nonatomic, readwrite) float progressPercentage;
@property (nonatomic, readwrite) float currentProgress;
@property (nonatomic, readwrite) float goal;

- (void)incrementProgress;

@end
