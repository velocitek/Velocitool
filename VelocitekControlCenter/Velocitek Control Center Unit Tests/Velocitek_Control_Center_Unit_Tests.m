//
//  Velocitek_Control_Center_Unit_Tests.m
//  Velocitek Control Center Unit Tests
//
//  Created by Andrew Hughes on 2/6/17.
//
//

#import <XCTest/XCTest.h>

@interface Velocitek_Control_Center_Unit_Tests : XCTestCase

@end

@implementation Velocitek_Control_Center_Unit_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr-FR"];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSString *dateString;
    
    dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(dateString);
}



@end
