//
//  LoginViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class PKRevealController;

@interface LoginViewController : UIViewController <MBProgressHUDDelegate> {
    
    // progress HUD
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (nonatomic, weak) IBOutlet UITextField * usernameField;
@property (nonatomic, weak) IBOutlet UITextField * passwordField;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton * forgotButton;

@property (nonatomic, weak) IBOutlet UILabel * titleLabel;

@property (nonatomic, weak) IBOutlet UIImageView * headerImageView;

@property (nonatomic, weak) IBOutlet UIView * infoView;
@property (nonatomic, weak) IBOutlet UILabel * infoLabel;

@property (nonatomic, weak) IBOutlet UIView * overlayView;

@property (nonatomic, strong, readwrite) PKRevealController *revealController;


- (IBAction)loginClicked:(id)sender;
- (IBAction)backgroundClick:(id)sender;
- (IBAction)forgotPass:(id)sender;
- (void)tokenStatusAction:(id)sender;

// reachability wifi check
-(void)reachabilityChanged:(NSNotification*)note;

@end


