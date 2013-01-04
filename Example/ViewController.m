//
//  ViewController.m
//  Example
//
//  Created by Kevin Renskers on 19-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "ViewController.h"
#import "GVUserDefaults+Properties.h"
#import "CodeTimestamps.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *test;

    LogTimestamp;

    test = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultUserName"];
    
    LogTimestamp;

    test = [GVUserDefaults standardUserDefaults].userName;
    NSLog(@"userName: %@", test);

    LogTimestamp;

    [[NSUserDefaults standardUserDefaults] setObject:@"Hello!" forKey:@"NSUSerDefaultUserName"];

    LogTimestamp;

    [GVUserDefaults standardUserDefaults].userName = @"Hello!";

    LogTimestamp;

    NSLog(@"userName: %@", [GVUserDefaults standardUserDefaults].userName);
}

@end
