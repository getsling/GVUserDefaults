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
    // Removing it for debugging, starting with a clean slate every time
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
