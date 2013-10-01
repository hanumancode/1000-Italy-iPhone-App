//
//  LoginViewController.m
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "SBJson.h"
#import "Reachability.h"
#import "FrontViewController.h"
#import "SettingsViewController.h"
#import "PKRevealController.h"
#import "SIAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation LoginViewController
@synthesize txtUsername;
@synthesize txtPassword;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* darkColor = [UIColor colorWithRed:62.0/255 green:28.0/255 blue:55.0/255 alpha:1.0f];
    
    NSString* fontName = @"DIN-Regular";
    NSString* boldFontName = @"DIN-Bold";
    
   self.view.backgroundColor = [UIColor clearColor];
    
    self.usernameField.backgroundColor = [UIColor whiteColor];
    self.usernameField.placeholder = @"username";
    self.usernameField.font = [UIFont fontWithName:fontName size:16.0f];
    self.usernameField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftView = leftView;
    
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.placeholder = @"password";
    self.passwordField.font = [UIFont fontWithName:fontName size:16.0f];
    self.passwordField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    
    UIView* leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = leftView2;
    
    self.loginButton.backgroundColor = customColorGrey;
    self.loginButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    
//    [self.loginButton setTitle:@"ACCEDI" forState:UIControlStateNormal];
    
    [self.loginButton setTitle:NSLocalizedString(@"ACCEDI", nil) forState:UIControlStateNormal];
    
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    
    self.forgotButton.backgroundColor = [UIColor clearColor];
    self.forgotButton.titleLabel.font = [UIFont fontWithName:fontName size:12.0f];
    [self.forgotButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:darkColor forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    
    self.titleLabel.textColor =  [UIColor whiteColor];
    self.titleLabel.font =  [UIFont fontWithName:boldFontName size:24.0f];
    self.titleLabel.text = @"1000 Italy";
    self.titleLabel.alpha = 0.5;
    
    self.infoLabel.textColor =  [UIColor darkGrayColor];
    self.infoLabel.font =  [UIFont fontWithName:boldFontName size:14.0f];
    self.infoLabel.text = @"Please login below";
    
    self.infoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.headerImageView.image = [UIImage imageNamed:@"loginImage.jpeg"];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    [txtPassword setReturnKeyType:UIReturnKeyDone];
    
    //reachability note
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    
    // reachability test for wifi connection
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //     UIAlertView *notificationReachabilityAlert = [[UIAlertView alloc] initWithTitle:@"Internet Test √" message:@"wifi network test √" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //   [notificationReachabilityAlert show];
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self alertNoWiFi:nil];
            
            //UIAlertView *notificationReachabilityAlert = [[UIAlertView alloc] initWithTitle:@"No internet" message:@"no wifi network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //[notificationReachabilityAlert show];
            
        });
    };
    
    [reach startNotifier];
    
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        
        // once this is done, if you need to you can call
        // some code on a main thread (delegates, notifications, UI updates...)
        dispatch_async(dispatch_get_main_queue(), ^{
                     
            
        });
    });
    
    // release the dispatch queue
    dispatch_release(jsonParsingQueue);

}

#pragma Reachability wifi check
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    
    if(![reach isReachable])
        
    {
        [self alertNoWiFi:nil];
        
        //        UIAlertView *notificationReachabilityAlert = [[UIAlertView alloc] initWithTitle:@"No internet" message:@"no wifi network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //      [notificationReachabilityAlert show];
    }
    
    /*
     if([reach isReachable])
     {
     UIAlertView *notificationReachabilityAlert = [[UIAlertView alloc] initWithTitle:@"Internet √" message:@"wifi network √" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
     [notificationReachabilityAlert show];
     }
     else
     {
     UIAlertView *notificationReachabilityAlert = [[UIAlertView alloc] initWithTitle:@"No internet" message:@"no wifi network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
     [notificationReachabilityAlert show];
     }
     */
}

- (void)alertNoWiFi:(id)sender
{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"No internet" andMessage:@"no wifi network detected"];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              //   NSLog(@"OK Clicked");
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    
    observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillShowNotification
                                                                  object:alertView
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                              }];
    observer2 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidShowNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                             }];
    observer3 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                             }];
    observer4 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer1];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer2];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer3];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer4];
                                                                 
                                                                 observer1 = observer2 = observer3 = observer4 = nil;
                                                             }];
    
    [alertView show];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [txtPassword resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [self setTxtUsername:nil];
    [self setTxtPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *) title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)loginClicked:(id)sender {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // Do something...
        
        @try {
            
            if([[self.usernameField text] isEqualToString:@""] || [[self.passwordField text] isEqualToString:@""] ) {
                
                //[self alertStatus:@"Please enter both Username and Password" :@"Login Failed!"];
                
                [self alertLoginFailurePW:nil];
                
            } else {
                NSString *post =[[NSString alloc] initWithFormat:@"username=%@&password=%@",[self.usernameField text],[self.passwordField text]];
                NSLog(@"PostData: %@",post);
                
                // token url
                NSURL *url=[NSURL URLWithString:@"http://stg.1000italy.com/api/token"];
                
                NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                
                NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:url];
                [request setHTTPMethod:@"POST"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
                
                NSLog(@"url is %@",url),
                NSLog(@"request is %@",request),
                
                [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
                
                NSError *error = [[NSError alloc] init];
                NSHTTPURLResponse *response = nil;
                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                NSLog(@"Response code: %d", [response statusCode]);
                if ([response statusCode] >=200 && [response statusCode] <300)
                {
                    NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                    NSLog(@"Response ==> %@", responseData);
                    
                    // extract token from json
                    NSError *error = nil;
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
                    NSString *token = [[responseDict objectForKey:@"data"] objectForKey:@"token"];
                    
                    NSString *userId = [[[responseDict objectForKey:@"data"] objectForKey:@"user"] objectForKey:@"id"];
                    
                    
                    if (token)     // make sure token is not nil
                    {
                        // save token string to nsuserdefaults
                        NSString *valueToSave = token;
                        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"token"];
                        
                        NSString *userIdToSave = userId;
                        [[NSUserDefaults standardUserDefaults] setObject:userIdToSave forKey:@"userId"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                    }
                    
                    SBJsonParser *jsonParser = [SBJsonParser new];
                    NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                    NSLog(@"%@",jsonData);
                    NSInteger success = token ? 1 : 0;   // token was sent to 1000Italy = login successful
                    NSLog(@"%d",success);
                    
                    if(success == 1)
                    {
                        
                        NSLog(@"Login SUCCESS");
                        
                        //  [self alertStatus:@"Logged in Successfully." :@"Login Success!"];
                        
                        [self tokenStatusAction:nil];
                        
                        
                    } else {
                        
                        NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                        //                    [self alertStatus:error_msg :@"Login Failed!"];
                        [self alertLoginFailure:error_msg];
                        
                    }
                    
                } else {
                    //                if (error) NSLog(@"Error: %@", error);
                    //                [self alertStatus:@"Connection Failed" :@"Login Failed!"];
                    
                    [self alertLoginFailure:nil];
                    
                }
            }
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            [self alertStatus:@"Login Failed." :@"Login Failed!"];
            
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

- (IBAction)backgroundClick:(id)sender {
    [txtPassword resignFirstResponder];
    [txtUsername resignFirstResponder];
    
    [self.view endEditing:YES];
    
    // NSLog(@"bg click");
}

- (void)tokenStatusAction:(id)sender {
        
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSLog(@"saved value for token is %@",savedValue);
    
    
    // Step 1: Create controllers.
    UINavigationController *frontViewController = [[UINavigationController alloc] initWithRootViewController:[[FrontViewController alloc] init]];
    
//    UIViewController *rightViewController = [[MapViewController alloc] init];
    UIViewController *rightViewController = nil;
    UIViewController *leftViewController = [[SettingsViewController alloc] init];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"blackBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
    
    frontViewController.navigationBar.self.opaque = YES;
    frontViewController.view.backgroundColor = [UIColor clearColor];
    
    // Step 2: Configure an options dictionary for the PKRevealController if necessary - in most cases the default behaviour should suffice. See PKRevealController.h for more option keys.
    
     NSDictionary *options = @{
     PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
     PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES],
     
     };
     
    
   // NSDictionary *options = @{ PKRevealControllerRecognizesPanningOnFrontViewKey : @NO };
    
    // Instantiate PKRevealController.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController
                                                                                options:options];
    
    // Set it as root view controller.
    
    [self presentViewController:self.revealController animated:YES completion:nil];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

- (IBAction)forgotPass:(id)sender{
    
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.1000Italy.com"]];
    
}

#pragma Alerts

id observer1,observer2,observer3,observer4;

- (void)alertLoginFailurePW:(id)sender
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Please enter both Username and Password"];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                          //    NSLog(@"OK Clicked");
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        //    NSLog(@"%@, willShowHandler3", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        //     NSLog(@"%@, didShowHandler3", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        //    NSLog(@"%@, willDismissHandler3", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        //    NSLog(@"%@, didDismissHandler3", alertView);
    };
    
    observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillShowNotification
                                                                  object:alertView
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                              }];
    observer2 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidShowNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //     NSLog(@"%@, -didShowHandler3", alertView);
                                                             }];
    observer3 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //     NSLog(@"%@, -willDismissHandler3", alertView);
                                                             }];
    observer4 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer1];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer2];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer3];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer4];
                                                                 
                                                                 observer1 = observer2 = observer3 = observer4 = nil;
                                                             }];
    
    [alertView show];
}

- (void)alertLoginFailure:(id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Login Failed" andMessage:@"Please check your username and password..."];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                         //     NSLog(@"OK Clicked");
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    
    observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillShowNotification
                                                                  object:alertView
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  //        NSLog(@"%@, -willShowHandler3", alertView);
                                                              }];
    observer2 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidShowNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //       NSLog(@"%@, -didShowHandler3", alertView);
                                                             }];
    observer3 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //       NSLog(@"%@, -willDismissHandler3", alertView);
                                                             }];
    observer4 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //      NSLog(@"%@, -didDismissHandler3", alertView);
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer1];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer2];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer3];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer4];
                                                                 
                                                                 observer1 = observer2 = observer3 = observer4 = nil;
                                                             }];
    
    [alertView show];
}


- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

@end
