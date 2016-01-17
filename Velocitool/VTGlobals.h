
#import <Cocoa/Cocoa.h>

extern void VTRaiseAbstractMethodException(id object, SEL _cmd,
                                           Class abstractClass);

#define VTDeclinationPref    @"declination"

#define VTRecordRatePref          @"recordRate"
#define VTRecordRateAll           2
#define VTRecordRateEveryTwo      4
#define VTRecordRateEveryFour     8
//#define VTRecordRateEveryEight    8
//#define VTRecordRateEverySixteen 16

#define VTSpeedUnitPref            @"speedUnitOfMeasurement"
#define VTSpeedUnitKnots           0
#define VTSpeedUnitMilesPerHour      1
#define VTSpeedUnitKilometersPerHour 2
#define VTSpeedUnitMetersPerSecond   3

#define VTMaxSpeedPref     @"maxSpeedMode"
#define VTMaxSpeedInstant  0
#define VTMaxSpeed10Second 1
#define VTMaxSpeedBoth     2

#define VTPuckModePref   @"deviceOperationOption"

//SpeedPuck Firmware 1.4 constants
#define VTPuck1_4ModeNormal 0
#define VTPuck1_4ModeRace 1
#define VTPuck1_4ModeMotor  2
#define VTPuck1_4ModeBlank  3

//SpeedPuck Firmware 1.3 constants
#define VTPuck1_3ModeNormal 0
#define VTPuck1_3ModeMotor  1
#define VTPuck1_3ModeBlank  2

#define VTSpeedDampingPref   @"speedDamping"
#define VTHeadingDampingPref @"headingDamping"
#define VTDampingNoDamping 0
#define VTDampingOneSecond 1
#define VTDampingTwoSecond 2
#define VTDampingFiveSecond 5
#define VTDampingTenSecond 10
#define VTDampingThirtySecond 30
#define VTDampingOneMinute 60
#define VTDampingTwoMinutes 120
#define VTDampingFourMinutes 240

#define VTBarGraphPref    @"barGraphOption"
#define VTBarGraphDisplayHeaderLiftAngle 1
#define VTBarGraphDisabled 0

//Button Notifications
#define VTSaveButtonSelectedNotification @"VTSaveButtonSelectedNotification" 
#define VTOpenButtonSelectedNotification @"VTOpenButtonSelectedNotification" 
#define VTCloseButtonPressedNotification @"VTCloseButtonPressedNotification" 
#define VTExportGPXButtonSelectedNotification @"VTExportGPXButtonSelectedNotification" 
#define VTExportKMLButtonSelectedNotification @"VTExportKMLButtonSelectedNotification" 

#define VTUpdateDeviceSettingsButtonSelectedNotification @"VTUpdateDeviceSettingsButtonSelectedNotification" 

//#define VTSetupUpdateDeviceFirmwareSelectedNotification @"VTSetupUpdateDeviceFirmwareSelectedNotification" 
//#define VTHelpTutorialVideoSelectedNotification @"VTHelpTutorialVideoSelectedNotification"

#define VTDownloadButtonPressedNotification @"VTDownloadButtonPressedNotification"

//Erase All Notification
#define VTEraseAllConfirmedNotification @"VTEraseAllButtonSelectedNotification" 


