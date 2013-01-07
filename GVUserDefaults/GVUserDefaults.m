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

- (id)init {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(setupDefaults)]) {
            NSDictionary *defaults = [self performSelector:@selector(setupDefaults)];
            NSMutableDictionary *mutableDefaults = [NSMutableDictionary dictionaryWithCapacity:[defaults count]];
            for (NSString *key in defaults) {
                id value = [defaults objectForKey:key];
                NSString *transformedKey = [self _transformKey:key];
                [mutableDefaults setObject:value forKey:transformedKey];
            }
            [[NSUserDefaults standardUserDefaults] registerDefaults:mutableDefaults];
        }
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    NSString *method = NSStringFromSelector(aSEL);

    if ([method isEqualToString:@"transformKey:"] || [method isEqualToString:@"setupDefaults"]) {
        // Prevent endless loop for optional (and missing) category methods
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

- (NSString *)_transformKey:(NSString *)key {
    if ([self respondsToSelector:@selector(transformKey:)]) {
        return [self performSelector:@selector(transformKey:) withObject:key];
    }

    return key;
}

id accessorGetter(GVUserDefaults *self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    key = [self _transformKey:key];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

void accessorSetter(GVUserDefaults *self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
    NSString *key = [[method stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] lowercaseString]];
    key = [self _transformKey:key];

    // Set value of the key anID to newValue
    [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
}

@end
