//
//  QRReaderViewController.h
//  1000 Italy
//
//  Created by GJ on 06/08/2013.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "MBProgressHUD.h"
@interface QRReaderViewControllerMain : UIViewController <ZBarReaderDelegate,MBProgressHUDDelegate> {

    UIImageView *resultImage;
    UITextView *resultText;
    MBProgressHUD *HUD;

}

@property (strong, nonatomic) IBOutlet UIImageView *checkinSuccessImage;

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
- (IBAction) scanButtonTapped;
-(void)checkInBtnPress;

@end