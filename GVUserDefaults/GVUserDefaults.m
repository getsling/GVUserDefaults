//
//  GVUserDefaults.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults.h"
#import <objc/runtime.h>
#import <Security/Security.h>

// special constant for marking property as sceduled for removal while stored in cache
static id kGVScheduledForRemoval;

// Keychain service name
static NSString *kGVKeychainServiceName;

@interface GVUserDefaults ()
@property (nonatomic, strong) NSMutableDictionary *propertiesCache;
// Accessors
void GVAccessorSetter(id self, SEL _cmd, id newValue);
// Keychain access functions
void GVSetPasswordWithValueAndName(NSString *value, NSString *name);
void GVRemovePasswordForName(NSString *name);
NSString *GVPasswordForName(NSString *name);
@end

@implementation GVUserDefaults

#pragma mark - NSObject

+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    NSString *method = NSStringFromSelector(aSEL);
	
    if ([method isEqualToString:@"transformKey:"]) {
        // Prevent endless loop for possibly non-existing prefix method
        return [super resolveInstanceMethod:aSEL];
    }
	
    if ([method hasPrefix:@"set"]) {
        class_addMethod([self class], aSEL, (IMP) GVAccessorSetter, "v@:@");
        return YES;
    } else {
        class_addMethod([self class], aSEL, (IMP) GVAccessorGetter, "@@:");
        return YES;
    }
}

- (id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	// Service name for the keychain
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		kGVKeychainServiceName = [[NSBundle mainBundle] bundleIdentifier];
		kGVScheduledForRemoval = [NSNull null];
	});
	
	// Cache dictionary
	self.propertiesCache = [NSMutableDictionary dictionary];
	
	return self;
}

#pragma mark - GVUserDefaults

- (void)save
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self.propertiesCache enumerateKeysAndObjectsUsingBlock:^(id propertyName, id propertyValue, BOOL *stop) {
		if ([self.securePropertyNames containsObject:propertyName]) {
			GVRemovePasswordForName(propertyName);
			if (propertyValue && propertyValue != kGVScheduledForRemoval) {
				GVSetPasswordWithValueAndName(propertyValue, propertyName);
			}
		} else {
			if (!propertyValue || propertyValue == kGVScheduledForRemoval) {
				[userDefaults removeObjectForKey:propertyName];
			} else {
				[userDefaults setValue:propertyValue forKey:propertyName];
			}
		}
	}];
	[userDefaults synchronize];
}

- (NSString *)_transformKey:(NSString *)key {
    if ([self respondsToSelector:@selector(transformKey:)]) {
        return [self performSelector:@selector(transformKey:) withObject:key];
    }

    return key;
}


#pragma mark - Accessor functions

id GVAccessorGetter(id self, SEL _cmd)
{
    NSString *propertyName = NSStringFromSelector(_cmd);
    propertyName = [self _transformKey:propertyName];
	NSMutableDictionary *propertiesCache = [self propertiesCache];
	NSArray *securePropertyNames = [self securePropertyNames];
	if (propertiesCache[propertyName]) {
		return propertiesCache[propertyName] == kGVScheduledForRemoval ? nil : propertiesCache[propertyName];
	}
	
	id value = nil;
	if ([securePropertyNames containsObject:propertyName]) {
		value = GVPasswordForName(propertyName);
	} else {
		value = [[NSUserDefaults standardUserDefaults] objectForKey:propertyName];
	}

	if (value) {
		propertiesCache[propertyName] = value;
	}
	
    return propertiesCache[propertyName];
}

void GVAccessorSetter(id self, SEL _cmd, id newValue)
{
    NSString *method = NSStringFromSelector(_cmd);
	
    NSString *key = [[method substringFromIndex:3] stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] lowercaseString]];
    key = [self _transformKey:key];
	
	NSMutableDictionary *propertiesCache = [self propertiesCache];
	propertiesCache[key] = newValue?:kGVScheduledForRemoval;
}

#pragma mark - Keychain access functions

void GVSetPasswordWithValueAndName(NSString *value, NSString *name)
{
	if (!name.length || (value == kGVScheduledForRemoval || (![value isKindOfClass:[NSString class]] || !value.length))) {
		return;
	}
	
	NSDictionary *query = @{
		(__bridge NSString *)kSecClass :			(__bridge NSString *)kSecClassGenericPassword,
		(__bridge NSString *)kSecAttrService :		kGVKeychainServiceName,
		(__bridge NSString *)kSecAttrAccount :		name,
		(__bridge NSString *)kSecValueData :		[value dataUsingEncoding:NSUTF8StringEncoding]
	};
	
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
#ifdef DEBUG
	if (status != noErr && status != errSecItemNotFound) {
		NSException *exception = [NSException exceptionWithName:@"Failed to save secure property" reason:[NSString stringWithFormat:@"property name: %@; status %lu", name, status] userInfo:nil];
		@throw exception;
	}
#endif
}

void GVRemovePasswordForName(NSString *name)
{
	// delete value
	NSDictionary *query = @{
		(__bridge NSString *)kSecClass :		(__bridge NSString *)kSecClassGenericPassword,
		(__bridge NSString *)kSecAttrService :	kGVKeychainServiceName,
		(__bridge NSString *)kSecAttrAccount :	name,
	};
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
#ifdef DEBUG
	if (status != noErr && status != errSecItemNotFound) {
		NSException *exception = [NSException exceptionWithName:@"Failed to save secure property" reason:[NSString stringWithFormat:@"property name: %@; status %lu", name, status] userInfo:nil];
		@throw exception;
	}
#endif
}

NSString *GVPasswordForName(NSString *name)
{
	if (!name.length) {
		return nil;
	}
	
	NSDictionary *query = @{
		(__bridge NSString *)kSecClass :		(__bridge NSString *)kSecClassGenericPassword,
		(__bridge NSString *)kSecAttrService :	kGVKeychainServiceName,
		(__bridge NSString *)kSecAttrAccount :	name,
		(__bridge NSString *)kSecReturnData :	(__bridge id)kCFBooleanTrue,
		(__bridge NSString *)kSecReturnData :	(__bridge id)kSecMatchLimitOne
	};
	
	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

#ifdef DEBUG
	if (status != noErr && status != errSecItemNotFound) {
		NSException *exception = [NSException exceptionWithName:@"Failed to save secure property" reason:[NSString stringWithFormat:@"property name: %@; status %lu", name, status] userInfo:nil];
		@throw exception;
	}
#endif
	
	if (status != noErr) {
		return nil;
	}
	NSString *propertyValue = [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
	return propertyValue;	
}

@end
