//
//  ViewController.m
//  Example
//
//  Created by Kevin Renskers on 19-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "ViewController.h"
#import "CodeTimestamps.h"
#import "MySettings.h"

@interface ViewController () {
	
	__weak IBOutlet UITextField *_usernameTextField;
	__weak IBOutlet UITextField *_passwordTextField;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	MySettings *settings = [MySettings settings];
	_usernameTextField.text = settings.username;
	_passwordTextField.text = settings.password;
//    NSString *test;
//
//    LogTimestamp;
//
//    test = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userName"];
//
//    LogTimestamp;
//
//    test = [GVUserDefaults standardUserDefaults].userName;
//
//    LogTimestamp;
//
//    [[NSUserDefaults standardUserDefaults] setObject:@"Hello!" forKey:@"NSUSerDefault:userName"];
//
//    LogTimestamp;
//
//    [GVUserDefaults standardUserDefaults].userName = @"Hello!";
//
//    LogTimestamp;
}

- (IBAction)_saveButtonHandler:(id)sender
{
	MySettings *settings = [MySettings settings];
	settings.username = _usernameTextField.text;
	settings.password = _passwordTextField.text;
	[settings save];
}

@end
