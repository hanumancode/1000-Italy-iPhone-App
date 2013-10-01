//
//  QRReaderViewController.m
//  1000 Italy
//
//  Created by GJ on 06/08/2013.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import "QRReaderViewController.h"
#import "PKRevealController.h"
#import "SIAlertView.h"

#define kIDURL @"http://1000it.tuelv.net/api/node/"

@interface QRReaderViewController ()

@end

@implementation QRReaderViewController
@synthesize resultImage, resultText;



#pragma mark - Left and Right menu methods

- (void)showLeftView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

/*
- (void)showRightView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.rightViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.rightViewController];
    }
}

 */

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return(YES);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // navbar buttons
   
    // left navbar button
    UIButton * leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0 , 44, 44);
    [leftBarButton setImage:[UIImage imageNamed:@"reveal_menu_icon_portrait.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:leftBarButton];
}

- (IBAction) scanButtonTapped
{
    NSLog(@"TBD: scan barcode here...");
    
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    
}
-(IBAction)checkInBtnPress {
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *urlString = resultText.text;
    
    NSLog(@"urlstring for checkin is %@",urlString);

    
    NSURL* url = [NSURL URLWithString:urlString];
   
    /*
     NSString* reducedUrl = [NSString stringWithFormat:
                            @"%@://%@/%@",
                            url.scheme,
                            url.host,
                            [url.pathComponents objectAtIndex:1]];
     */
   
    NSLog(@"path component is %@",[url.pathComponents objectAtIndex:2]);
    
    NSString *nodeString = [url.pathComponents objectAtIndex:2];
    
    NSString *urlStringForCheckin = [NSString stringWithFormat:@"%@%@/checkins?token=%@", kIDURL, nodeString,savedValue];

    NSLog(@"urlStringForCheckin for checkin is %@",urlStringForCheckin);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringForCheckin]];
   [request setHTTPMethod:@"POST"];
        
    // generates an autoreleased NSURLConnection
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    [self checkinAlertSuccess];
    
}

- (void)checkinAlertSuccess {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Checkin Success!" andMessage:@"checked in!"];
    
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
       [alertView show];
    
    [self dismissModalViewControllerAnimated:YES];

}
    
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    resultText.text = symbol.data;
    
    
    
    // EXAMPLE: do something useful with the barcode image
    resultImage.image =
    [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    
    /*
     
     7/09/2013 17:20:44] Marcello Stani: remember, i wrote you the url format for the qrcode
     [07/09/2013 17:20:58] Marcello Stani: you must check for it to be well formatted
     [07/09/2013 17:21:00] Marcello Stani: so:
     [07/09/2013 17:21:49] Marcello Stani: www.1000italy.com/node/NODE_ID/CITY_SLUG/CATEGORY_SLUG/TITLE_SLUG
     [07/09/2013 17:22:12] Marcello Stani: so basically you should check that the url starts with: www.1000italy.com/node/
     [07/09/2013 17:22:18] Marcello Stani: and then extract the node id
     [07/09/2013 17:22:26] Marcello Stani: you can bypass the rest
     [07/09/2013 17:22:39] Marcello Stani: nothing to complicated
     [07/09/2013 17:22:49] Gareth Jones: ok
     [07/09/2013 17:22:55] Marcello Stani: and after a successfully checkin show the related view
     

*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
