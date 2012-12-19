//
//  AppDelegate.m
//  Example
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *defaults = @{
        @"NSUSerDefault:userName": @"default",
        @"NSUSerDefault:userId": @1
    };

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUSerDefault:userId"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
