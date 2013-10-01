//
//  QRReaderViewController.h
//  1000 Italy
//
//  Created by GJ on 06/08/2013.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface QRReaderViewController : UIViewController     <ZBarReaderDelegate> {

    UIImageView *resultImage;
    UITextView *resultText;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
- (IBAction) scanButtonTapped;
-(IBAction)checkInBtnPress;

@end