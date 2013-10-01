//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNThirdViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>
#import "FrontViewController.h"
#import "PKRevealController.h"
#import "DetailViewController.h"

@interface KNThirdViewController ()

@end

@implementation KNThirdViewController
@synthesize helpLabel;
@synthesize dismissButton;
@synthesize resizeButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  dismissButton.layer.cornerRadius  = 10.0f;
  dismissButton.layer.masksToBounds = YES;
  resizeButton.layer.cornerRadius   = 10.0f;
  resizeButton.layer.masksToBounds  = YES;
    
}

- (void)viewDidUnload {
  [self setHelpLabel:nil];
  [self setDismissButton:nil];
  [self setResizeButton:nil];
  [super viewDidUnload];
}

- (IBAction)dismissButtonDidTouch:(id)sender {

//    [[self dismissModalViewControllerAnimated:NO];

     [self dismissViewControllerAnimated:YES completion:nil];
  // Here's how to call dismiss button on the parent ViewController
  // be careful with view hierarchy
//  UIViewController * parent = [self.view containingViewController];
//  if ([parent respondsToSelector:@selector(dismissSemiModalView)]) {
//    [parent dismissSemiModalView];
//  }

   // [self.parentViewController dismissModalViewControllerAnimated:YES];
    
 //   [self.modalViewController dismissModalViewControllerAnimated:YES];
    
    NSLog(@"save touched");
    // Step 3: Instantiate your PKRevealController.
//    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
//                                                                     leftViewController:leftViewController
//                                                                    rightViewController:rightViewController
//                                                                                options:options];
    
 //   [self dismissModalViewControllerAnimated:self.revealController animated:YES completion:nil];


}

- (IBAction)resizeSemiModalView:(id)sender {

    UIViewController * parent = [self.view containingViewController];
  if ([parent respondsToSelector:@selector(resizeSemiView:)]) {
    [parent resizeSemiView:CGSizeMake(320, arc4random() % 280 + 180)];
      
      
  }
}

@end
