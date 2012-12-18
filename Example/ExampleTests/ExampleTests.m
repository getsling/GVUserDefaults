//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "ExampleTests.h"
#import "GVUserDefaults+Mine.h"

@implementation ExampleTests

- (void)setUp {
    [super setUp];
    
    NSDictionary *defaults = @{
        @"NSUSerDefault:userName": @"default",
        @"NSUSerDefault:userId": @1
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)tearDown {
    // Tear-down code here.
    [super tearDown];
}

- (void)testDefaults {
    STAssertEquals([GVUserDefaults standardUserDefaults].userName, @"default", @"username equals default");
    STAssertEquals([GVUserDefaults standardUserDefaults].userId, @1, @"userId equals 1");
}

- (void)testSetters {
    [GVUserDefaults standardUserDefaults].userName = @"changed";
    [GVUserDefaults standardUserDefaults].userId = @2;

    STAssertEquals([GVUserDefaults standardUserDefaults].userName, @"changed", @"username equals changed");
    STAssertEquals([GVUserDefaults standardUserDefaults].userId, @2, @"userId equals 2");
}

- (void)testGetters {
    STAssertEquals([GVUserDefaults standardUserDefaults].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userName"], @"username equals username");
    STAssertEquals([GVUserDefaults standardUserDefaults].userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userId"], @"userId equals userId");
}

@end
