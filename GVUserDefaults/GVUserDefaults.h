//
//  GVUserDefaults.h
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVUserDefaults : NSObject

+ (GVUserDefaults *)standardUserDefaults;

@property (nonatomic, strong) NSArray *securePropertyNames;

- (void)save;

@end
