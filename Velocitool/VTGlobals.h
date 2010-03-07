
#import <Cocoa/Cocoa.h>

extern void VTRaiseAbstractMethodException(id object, SEL _cmd, Class abstractClass);


#define VTDeclinationPref    @"declination"
#define VTSpeedDampingPref   @"speedDamping"
#define VTHeadingDampingPref @"headingDamping"
#define VTBarGraphEnabled    @"barGraphOption"

#define VTRecordRatePref          @"recordRate"
#define VTRecordRateAll           1
#define VTRecordRateEveryTwo      2
#define VTRecordRateEveryFour     4
#define VTRecordRateEveryEight    8
#define VTRecordRateEverySixteen 16

#define VTSpeedUnitPref            @"speedUnitOfMeasurement"
#define VTSpeedUnitKnots           1
#define VTSpeedUnitMilesHours      2
#define VTSpeedUnitKilometersHours 3
#define VTSpeedUnitMetersSeconds   4

#define VTMaxSpeedPref     @"maxSpeedMode"
#define VTMaxSpeedInstant  0
#define VTMaxSpeed10Second 1
#define VTMaxSpeedBoth     2

#define VTPuckModePref   @"deviceOperationOption"
#define VTPuckModeNormal 0
#define VTPuckModeMotor  1
#define VTPuckModeBlank  2

