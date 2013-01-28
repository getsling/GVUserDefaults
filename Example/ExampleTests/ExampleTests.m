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
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"default", nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @1, nil);
    STAssertEquals([GVUserDefaults standardUserDefaults].integerValue, 123, nil);
    STAssertEquals([GVUserDefaults standardUserDefaults].boolValue, YES, nil);
}

- (void)testSetters {
    [GVUserDefaults standardUserDefaults].userName = @"changed";
    [GVUserDefaults standardUserDefaults].userId = @2;
    [GVUserDefaults standardUserDefaults].integerValue = 456;

    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"changed", nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @2, nil);
    STAssertEquals([GVUserDefaults standardUserDefaults].integerValue, 456, nil);
}

- (void)testGetters {
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultUserName"], nil);
    STAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultUserId"], nil);
    STAssertEquals([GVUserDefaults standardUserDefaults].integerValue, [[NSUserDefaults standardUserDefaults] integerForKey:@"NSUserDefaultIntegerValue"], nil);
}

@end
