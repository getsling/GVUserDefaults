//
//  GVUserDefaults+Mine.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults+Mine.h"

@implementation GVUserDefaults (Mine)

- (NSString *)prefix {
    return @"NSUSerDefault:";
}

@dynamic userName;
@dynamic userId;

@end
