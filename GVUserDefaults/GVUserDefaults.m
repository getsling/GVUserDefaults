//
//  GVUserDefaults.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults.h"
#import <objc/runtime.h>

@interface GVUserDefaults ()
@property (nonatomic, strong) NSMutableDictionary *propertiesCache;
@end

@implementation GVUserDefaults

+ (GVUserDefaults *)standardUserDefaults
{
    static dispatch_once_t pred;
    static GVUserDefaults *sharedInstance = nil;
    dispatch_once(&pred, ^{
		sharedInstance = [[self alloc] init];
	});
    return sharedInstance;
}

- (id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.propertiesCache = [NSMutableDictionary dictionary];
	
	return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    NSString *method = NSStringFromSelector(aSEL);

    if ([method isEqualToString:@"transformKey"]) {
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

- (NSString *)_transformKey:(NSString *)key {
    if ([self respondsToSelector:@selector(transformKey:)]) {
        return [self performSelector:@selector(transformKey:) withObject:key];
    }

    return key;
}

id accessorGetter(GVUserDefaults *self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    key = [self _transformKey:key];
	
	if (self.propertiesCache[key]) {
		return self.propertiesCache[key];
	}
	
	self.propertiesCache[key] = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    return self.propertiesCache[key];
}

void accessorSetter(GVUserDefaults *self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
	
    NSString *key = [[method substringFromIndex:3] stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] lowercaseString]];
    key = [self _transformKey:key];
	
	self.propertiesCache[key] = newValue;

    // Set value of the key anID to newValue
    [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
}

@end
