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

    NSDictionary *defaults = @{
        @"NSUSerDefault:userName": @"default",
        @"NSUSerDefault:userId": @1
    };

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userId"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)tearDown {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userId"];
    [super tearDown];
}

- (void)testDefaults {
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"default", nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @1, nil);
}

- (void)testSetters {
    [GVUserDefaults standardUserDefaults].userName = @"changed";
    [GVUserDefaults standardUserDefaults].userId = @2;

    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"changed", nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @2, nil);
}

- (void)testGetters {
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userName"], nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userId"], nil);
}

@end
