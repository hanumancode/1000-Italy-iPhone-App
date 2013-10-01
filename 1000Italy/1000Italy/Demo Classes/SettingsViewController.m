//
//  SettingsViewController.m
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "PKRevealController.h"
#import "FrontViewController.h"
#import "ComprareViewController.h"
#import "VedereViewController.h"
#import "ManigareViewController.h"
#import "VivereViewController.h"
#import "SIAlertView.h"
#import "ProfiloViewController.h"
#import "QRReaderViewControllerMain.h"
#import "MBProgressHUD.h"
#import "ExpandingTableViewProjectViewController.h"

@implementation SettingsViewController

@synthesize homeBtn;
@synthesize compareBtn, mangiareBtn,vedereBtn, vivereBtn;
@synthesize profiloBtn,offerteBtn,infoutiliBtn,impostazioniBtn,qrBtn,tableView;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [tableView bounds];
    [tableView setBounds:CGRectMake(bounds.origin.x,
                                    bounds.origin.y,
                                    bounds.size.width,
                                    bounds.size.height + 100)];

    
    // Each view can dynamically specify the min/max width that can be revealed.
    [self.revealController setMinimumWidth:280.0f maximumWidth:324.0f forViewController:self];

    NSString* boldFontName = @"DIN-Bold";
    
    [self.compareBtn setTitle:NSLocalizedString(@"COMPRARE", nil) forState:UIControlStateNormal];
    [self.mangiareBtn setTitle:NSLocalizedString(@"MANGIARE", nil) forState:UIControlStateNormal];
    [self.vedereBtn setTitle:NSLocalizedString(@"VISITARE", nil) forState:UIControlStateNormal];
    [self.vivereBtn setTitle:NSLocalizedString(@"VIVERE", nil) forState:UIControlStateNormal];
    [self.profiloBtn setTitle:NSLocalizedString(@"PROFILO", nil) forState:UIControlStateNormal];
    [self.impostazioniBtn setTitle:NSLocalizedString(@"IMPOSTAZIONI", nil) forState:UIControlStateNormal];
    
    [self.offerteBtn setTitle:NSLocalizedString(@"OFFERTE", nil) forState:UIControlStateNormal];
    [self.infoutiliBtn setTitle:NSLocalizedString(@"INFO", nil) forState:UIControlStateNormal];
    [self.qrBtn setTitle:NSLocalizedString(@"QR", nil) forState:UIControlStateNormal];

    
    self.homeBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    
    self.compareBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.mangiareBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.vedereBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.vivereBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    
    self.profiloBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.offerteBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.infoutiliBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];
    self.impostazioniBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:15];

}

#pragma mark - API

- (IBAction)showOppositeView:(id)sender
{
    [self.revealController showViewController:self.revealController.rightViewController];
}

- (IBAction)togglePresentationMode:(id)sender
{
    if (![self.revealController isPresentationModeActive])
    {
        [self.revealController enterPresentationModeAnimated:YES
                                                  completion:NULL];
    }
    else
    {
        [self.revealController resignPresentationModeEntirely:NO
                                                     animated:YES
                                                   completion:NULL];
    }
}

-(IBAction)pushHomeButton{
    
    // front view controller
    
    [self.homeBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      
        FrontViewController *myNewUIViewController = [[FrontViewController alloc] init];
        UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
        [self.revealController setFrontViewController:myNavController];
        // Putting back the front view on focus
        [self.revealController showViewController:self.revealController.frontViewController];
                
    });

}

-(IBAction)pushCompareButton{
    
    // shopping or compare view controller
    
   [self.compareBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        ComprareViewController *myNewUIViewController = [[ComprareViewController alloc] init];
        UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
        [self.revealController setFrontViewController:myNavController];
        // Putting back the front view on focus
        [self.revealController showViewController:self.revealController.frontViewController];
                
    });
}

-(IBAction)pushMangiareButton{
      
    // mangiare view controller
    
    [self.mangiareBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

    ManigareViewController *myNewUIViewController = [[ManigareViewController alloc] init];
    UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
    [self.revealController setFrontViewController:myNavController];
    // Putting back the front view on focus
    [self.revealController showViewController:self.revealController.frontViewController];
    
    });

}

-(IBAction)pushVedereButton{
   
    // vedere view controller
    [self.vedereBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

    VedereViewController *myNewUIViewController = [[VedereViewController alloc] init];
    UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
    [self.revealController setFrontViewController:myNavController];
    // Putting back the front view on focus
    [self.revealController showViewController:self.revealController.frontViewController];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });

}

-(IBAction)pushVivereButton{
   
    // vivere or events view controller

    [self.vivereBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC);
   
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    VivereViewController *myNewUIViewController = [[VivereViewController alloc] init];
    UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
    [self.revealController setFrontViewController:myNavController];
    // Putting back the front view on focus
    [self.revealController showViewController:self.revealController.frontViewController];
        
    });

}

id observer1,observer2,observer3,observer4;

-(IBAction)pushProfiloButton{
    
    [self.profiloBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    ProfiloViewController *myNewUIViewController = [[ProfiloViewController alloc] init];
    UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
    [self.revealController setFrontViewController:myNavController];
    // Putting back the front view on focus
    [self.revealController showViewController:self.revealController.frontViewController];


    });
}

-(IBAction)pushQRButton{
    
    [self.qrBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    QRReaderViewControllerMain *myNewUIViewController = [[QRReaderViewControllerMain alloc] init];
    UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
    [self.revealController setFrontViewController:myNavController];
    // Putting back the front view on focus
    [self.revealController showViewController:self.revealController.frontViewController];

    });
}

-(IBAction)pushImpostazioniButton{
    
    [self.impostazioniBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Impostazioni Alert" andMessage:@"Temporary - will push to Impostazioni view controller"];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
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

-(IBAction)pushInfoUtiliButton{
    
    [self.infoutiliBtn setTitleColor:customColorGrey forState:UIControlStateHighlighted];
        
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0001 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       
        ExpandingTableViewProjectViewController *myNewUIViewController = [[ExpandingTableViewProjectViewController alloc] init];

        UINavigationController *myNavController = [[UINavigationController alloc] initWithRootViewController:myNewUIViewController];
        [self.revealController setFrontViewController:myNavController];
        // Putting back the front view on focus
        [self.revealController showViewController:self.revealController.frontViewController];
        
    });    
}

-(void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

- (void)viewDidUnload {
    
    [self setCompareBtn:nil];
    [self setMangiareBtn:nil];
    [self setVedereBtn:nil];
    [self setVivereBtn:nil];
    
    [self setHomeBtn:nil];
    
    [self setProfiloBtn:nil];
    [self setOfferteBtn:nil];
    [self setInfoutiliBtn:nil];
    [self setImpostazioniBtn:nil];
    [self setQrBtn:nil];
    
    [super viewDidUnload];
}

@end