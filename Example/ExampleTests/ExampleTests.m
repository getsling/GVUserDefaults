//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "ExampleTests.h"
#import "GVUserDefaults+Properties.h"

@implementation ExampleTests

- (void)setUp {
    [super setUp];

    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)tearDown {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [super tearDown];
}

- (void)testDefaults {
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"default");
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @1);
    XCTAssertEqual([GVUserDefaults standardUserDefaults].integerValue, 123);
    XCTAssertEqual([GVUserDefaults standardUserDefaults].boolValue, YES);
}

- (void)testSetters {
    [GVUserDefaults standardUserDefaults].userName = @"changed";
    [GVUserDefaults standardUserDefaults].userId = @2;
    [GVUserDefaults standardUserDefaults].integerValue = 456;

    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"changed");
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @2);
    XCTAssertEqual([GVUserDefaults standardUserDefaults].integerValue, 456);
}

- (void)testGetters {
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultUserName"]);
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultUserId"]);
    XCTAssertEqual([GVUserDefaults standardUserDefaults].integerValue, [[NSUserDefaults standardUserDefaults] integerForKey:@"NSUserDefaultIntegerValue"]);
}

@end
