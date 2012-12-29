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

static NSString *GVKeychainServiceName;

@interface GVUserDefaults ()
@property (nonatomic, strong) NSMutableDictionary *propertiesCache;
void GVSSetSecureProperty(id self, SEL _cmd, id propertyValue, NSString *propertyName);
id GVGetSecureProperty(id self, SEL _cmd, NSString *propertyName);
@end

@implementation GVUserDefaults

+ (GVUserDefaults *)standardUserDefaults
{
    static dispatch_once_t pred;
    static GVUserDefaults *sharedInstance = nil;
    dispatch_once(&pred, ^{
		sharedInstance = [[[self class] alloc] init];
	});
    return sharedInstance;
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
		GVKeychainServiceName = [[NSBundle mainBundle] bundleIdentifier];
	});
	
	// Cache dictionary
	self.propertiesCache = [NSMutableDictionary dictionary];
	
	return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    NSString *method = NSStringFromSelector(aSEL);

    if ([method isEqualToString:@"transformKey:"]) {
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

- (void)save
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self.propertiesCache enumerateKeysAndObjectsUsingBlock:^(id propertyName, id propertyValue, BOOL *stop) {
		if ([self.securePropertyNames containsObject:propertyName]) {
			GVSSetSecureProperty(self, @selector(save), propertyName, propertyValue);
		} else {
			[userDefaults setValue:propertyValue forKey:propertyName];
		}
	}];
	[userDefaults synchronize];
}

id accessorGetter(id self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    key = [self _transformKey:key];
	NSMutableDictionary *propertiesCache = [self propertiesCache];
	NSArray *securePropertyNames = [self securePropertyNames];
	if (propertiesCache[key]) {
		return propertiesCache[key];
	}
	
	id value = nil;
	if ([securePropertyNames containsObject:key]) {
		value = GVGetSecureProperty(self, _cmd, key);
	} else {
		value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	}
	if (value) {
		propertiesCache[key] = value;
	}
    return propertiesCache[key];
}

void accessorSetter(id self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
	
    NSString *key = [[method substringFromIndex:3] stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] lowercaseString]];
    key = [self _transformKey:key];
	
	NSMutableDictionary *propertiesCache = [self propertiesCache];
	if (newValue) {
		propertiesCache[key] = newValue;
	} else {
		[propertiesCache removeObjectForKey:key];
	}

//	BOOL isSecure = [self.securePropertyNames containsObject:key];
//	if (isSecure) {
//		GVSSetSecureProperty(self, _cmd, newValue, key);
//	} else {
//		// Set value of the key anID to newValue
//		[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:key];
//	}
}

void GVSSetSecureProperty(id self, SEL _cmd, NSString *propertyName, id propertyValue)
{
	if (!propertyName.length) {
		return;
	}
	
#ifdef DEBUG
	NSAssert([propertyValue isKindOfClass:[NSString class]], @"Currently supported only instances of NSString class");
#endif
	if (![propertyValue isKindOfClass:[NSString class]]) {
		return;
	}
	
	OSStatus status = noErr;
	if (propertyValue) {
		// save value
		NSDictionary *query = @{
			(__bridge NSString *)kSecClass :			(__bridge NSString *)kSecClassGenericPassword,
			(__bridge NSString *)kSecAttrService :		GVKeychainServiceName,
			(__bridge NSString *)kSecAttrAccount :		propertyName,
			(__bridge NSString *)kSecValueData :		[propertyValue dataUsingEncoding:NSUTF8StringEncoding]
		};

		status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
	} else {
		// delete value
		NSDictionary *query = @{
			(__bridge NSString *)kSecClass :		(__bridge NSString *)kSecClassGenericPassword,
			(__bridge NSString *)kSecAttrService :	GVKeychainServiceName,
			(__bridge NSString *)kSecAttrAccount :	propertyName,
		};
		status = SecItemDelete((__bridge CFDictionaryRef)query);
	}
	
#ifdef DEBUG
	NSAssert(status == noErr, @"Failed to save secure property \"%@\" with value \"%@\"; Status %lu", propertyName, propertyValue, status);
#endif
}

id GVGetSecureProperty(id self, SEL _cmd, NSString *propertyName)
{
	if (!propertyName.length) {
		return nil;
	}

	NSDictionary *query = @{
		(__bridge NSString *)kSecClass :		(__bridge NSString *)kSecClassGenericPassword,
		(__bridge NSString *)kSecAttrService :	GVKeychainServiceName,
		(__bridge NSString *)kSecAttrAccount :	propertyName,
		(__bridge NSString *)kSecReturnData :	(__bridge id)kCFBooleanTrue,
		(__bridge NSString *)kSecReturnData :	(__bridge id)kSecMatchLimitOne
	};

	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
#ifdef DEBUG
	NSAssert(status == noErr || status == errSecItemNotFound, @"Failed to save secure property \"%@\"; Status %lu", propertyName, status);
#endif
	if (status != noErr) {
		return nil;
	}
	NSString *propertyValue = [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
	return propertyValue;
}

@end
