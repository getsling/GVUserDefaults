//
//  MySettings.m
//  Example
//
//  Created by Alexander Zats on 12/29/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "MySettings.h"

@implementation MySettings
@dynamic username, password;

+ (MySettings *)settings
{
	static MySettings *_instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[MySettings alloc] init];
	});
	return _instance;
}

- (id)init
{
	self = [super init];
	if (!self) return nil;
	
	[self setSecurePropertyNames:@[ @"password" ]];
	return self;
}

@end
