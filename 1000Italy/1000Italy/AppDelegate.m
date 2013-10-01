//
//  AppDelegate.m
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@implementation AppDelegate
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    // redirect after device check
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        self.viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPhone" bundle:nil];
        //this is iphone 5 xib
    } else {
        self.viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPhone4" bundle:nil];
        // this is iphone 4 xib
    }
    
    self.window.rootViewController = self.viewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
    
}

@end
