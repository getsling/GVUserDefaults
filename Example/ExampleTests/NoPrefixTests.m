//
//  NoPrefixTests.m
//  Example
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "NoPrefixTests.h"
#import "GVUserDefaults.h"

@interface GVUserDefaults (NoPrefix)
@property (nonatomic, weak) NSString *userName;
@property (nonatomic, weak) NSNumber *userId;
@end

@implementation GVUserDefaults (NoPrefix)
@dynamic userName;
@dynamic userId;
@end


@implementation NoPrefixTests

- (void)setUp {
    [super setUp];

    NSDictionary *defaults = @{
        @"userName": @"default",
        @"userId": @1
    };

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)tearDown {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
    [super tearDown];
}

- (void)testDefaults {
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"default");
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @1);
}

- (void)testSetters {
    [GVUserDefaults standardUserDefaults].userName = @"changed";
    [GVUserDefaults standardUserDefaults].userId = @2;

    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, @"changed");
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, @2);
}

- (void)testGetters {
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]);
    XCTAssertEqualObjects([GVUserDefaults standardUserDefaults].userId, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]);
}

@end
