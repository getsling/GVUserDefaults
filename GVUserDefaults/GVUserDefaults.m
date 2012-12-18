//
//  GVUserDefaults.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults.h"
#import <objc/runtime.h>

@implementation GVUserDefaults

+ (GVUserDefaults *)standardUserDefaults {
    static dispatch_once_t pred;
    static GVUserDefaults *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    NSString *method = NSStringFromSelector(aSEL);

    if ([method isEqualToString:@"prefix"]) {
        // Prevent endless loop for possibly non-existing prefix method
        return [super resolveInstanceMethod:aSEL];
    }

    if ([method hasPrefix:@"set"]) {
        class_addMethod([self class], aSEL, (IMP) accessorSetter, "v@:@");
        return YES;
    } else {
        class_addMethod([self class], aSEL, (IMP) accessorGetter, "@@:");
        return YES;
    }
}

- (NSString *)getPrefix {
    if ([self respondsToSelector:@selector(prefix)]) {
        return [self performSelector:@selector(prefix)];
    }

    return @"";
}

id accessorGetter(id self, SEL _cmd) {
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getPrefix], NSStringFromSelector(_cmd)];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

void accessorSetter(id self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
    NSString *key = [[method stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] lowercaseString]];
    key = [NSString stringWithFormat:@"%@%@", [self getPrefix], key];

    // Set value of the key anID to newValue
    [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
