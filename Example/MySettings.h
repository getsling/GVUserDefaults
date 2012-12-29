//
//  MySettings.h
//  Example
//
//  Created by Alexander Zats on 12/29/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults.h"

@interface MySettings : GVUserDefaults

+ (MySettings *)settings;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
