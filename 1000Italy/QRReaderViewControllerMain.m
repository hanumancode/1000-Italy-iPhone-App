//
//  QRReaderViewController.m
//  1000 Italy
//
//  Created by GJ on 06/08/2013.
//

#import "QRReaderViewControllerMain.h"
#import "PKRevealController.h"
#import "SIAlertView.h"

#define kIDURL @"http://stg.1000italy.com/api/node/"

@interface QRReaderViewControllerMain ()

@end

@implementation QRReaderViewControllerMain
@synthesize resultImage, resultText,checkinSuccessImage;

#pragma mark - Left and Right menu methods

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    checkinSuccessImage.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    
}

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
    
    /*
    // right navbar btn
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightNavButton.frame = CGRectMake(320-44, 0 , 44, 44);
    [rightNavButton setImage:[UIImage imageNamed:@"geotag.png"] forState:UIControlStateNormal];
    [rightNavButton addTarget:self action:@selector(showRightView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightNavButton];
    */
    
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

-(void)checkInBtnPress {
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *urlString = resultText.text;
    
    NSLog(@"urlstring for checkin is %@",urlString);

    
    NSURL* url = [NSURL URLWithString:urlString];
    NSString* reducedUrl = [NSString stringWithFormat:
                            @"%@",
                            url.host
                            ];
    
    NSLog(@"reducedUrl is %@",reducedUrl);

    
    if ([reducedUrl isEqualToString:@"www.1000italy.com"] || [reducedUrl isEqualToString:@"1000italy.com"] ) {
        NSLog(@"path component is %@",[url.pathComponents objectAtIndex:2]);
        
        NSString *nodeString = [url.pathComponents objectAtIndex:2];
        
        NSString *urlStringForCheckin = [NSString stringWithFormat:@"%@%@/checkins?via=qrcode&token=%@", kIDURL, nodeString,savedValue];
        
        NSLog(@"urlStringForCheckin for checkin is %@",urlStringForCheckin);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringForCheckin]];
        [request setHTTPMethod:@"POST"];
        
        // generates an autoreleased NSURLConnection
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        [self checkinAlertSuccess];

    } else {
        
   //     NSLog(@"bad url");
        
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Checkin Failed!" andMessage:@"Incorrect QR Code Scanned"];
        
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

    }
            [HUD hide:YES];

    
}

//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse*)response
//{
//    if ([response statusCode] == 200) {
//        // Handle valid response (You can probably just let the connection continue)
//        NSLog(@"req success" );
//        [self checkinAlertSuccess];
//
//
//    }
//    else {
//        // Other status code logic here (perhaps cancel the NSURLConnection and show error)
//        
//        NSLog(@"req fail" );
//
//    }
//}

- (void)checkinAlertSuccess {
    
    checkinSuccessImage.hidden = NO;
      
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
    
    [self performSelector:@selector(checkInBtnPress) withObject:nil afterDelay:1.5];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCheckinSuccessImage:nil];
    [super viewDidUnload];
}
@end
