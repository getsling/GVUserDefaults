//
//  GVUserDefaults+Properties.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults+Properties.h"

@implementation GVUserDefaults (Properties)

- (NSDictionary *)setupDefaults {
    return @{
        @"userName": @"default",
        @"userId": @1
    };
}

- (NSString *)transformKey:(NSString *)key {
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
    return [NSString stringWithFormat:@"NSUserDefault%@", key];
}

@dynamic userName;
@dynamic userId;

@end
