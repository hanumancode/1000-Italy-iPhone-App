

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FXImageView.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "MapViewAnnotation.h"
#import "fileUploadEngine.h"

@class KNThirdViewController;

@interface DetailViewController : UIViewController <UIApplicationDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate, UIActionSheetDelegate,UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate> {
    
    MBProgressHUD *HUD;

    UIView *pView;
    KNThirdViewController * semiVC; // comment popup view

    IBOutlet MKMapView *mapView;
    MapViewAnnotation *newAnnotation;
    CLLocationManager *locationManager;
    
    // map launch and close button
    UIButton *mapLaunchButton;
    UIButton *mapCloseButton;
    
    __strong IBOutlet UILabel *countLabel;
            
    // page control for image
    int pageNo;
    int pageNumber;
    UIButton *buttonItem;
    NSMutableArray *pageArray;
    
    UIButton *leftBarBtnItem;
    
    UIButton *likeButton;
    UIButton *checkInButton;
    
    UIButton *qrBarBtn;
    
    UIImage *imageCrown;

    int categoryId;
        
    BOOL toggleLikeIsOn;
    NSString *likeStringForButton;
    
    NSString *imageUrlString;
    NSString *imageUrlPhotoFromUserCommentsString;
    NSArray *imageUrlPhotoFromUserCommentsArray;
    
    
    // user comments table data
    NSArray *userCommentDataArray;
    NSArray *message;
    NSArray *name;
    NSArray *userName;
    NSArray *userImageArray;
    NSArray *photosFromCommentsArray;
    NSArray *timeStamp;
    
    // detail listing info
    NSString *listingTitle;
    NSArray *listingTags;
    NSString *listingShortDescription;
    NSString *listingAddress;
    NSString *listingPhoneNumber;
    NSString *listingWebAddress;
    NSString *listingEmailAddress;
    NSString *listingMainImageURL;
    NSNumber *likesCount;
    NSNumber *lat;
    NSNumber *lng;
    NSString *listingOpenings;
    NSString *listingSpecialita;
    NSString *listingPrice;
    NSString *listingOffers;
    
    NSNumber *checkIn_count;
    NSNumber *comments_count;
    NSNumber *userLiked;
    NSNumber *userCheckedIn;
    
    NSNumber *userIdLike;
    NSMutableArray *userLikesArray;
    NSArray *commentId;
    NSArray *userId;
    
    // photo info
    NSString *photoURL;
    NSMutableArray *photoArray;
    
    UITextField *textFieldComment;
    NSString *messageComment;

    BOOL isFullScreen;
    CGRect prevFrame;
    UIImageView * userSubmittedImageView;
}

// views
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIView *detailInfoView;

// tableview
@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;
// mapview
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
// description text view
@property (nonatomic,strong) IBOutlet UITextView *descriptionTextView;

// array & dict for user data, comments
@property (nonatomic,strong) NSMutableArray *publicDetailDataArray;
@property (nonatomic,strong) NSDictionary *publicDetailDataDict;

// array & dict for user data, comments
@property (nonatomic,strong) NSMutableArray *publicExtendedDetailDataArray;
@property (nonatomic,strong) NSDictionary *publicExtendedDetailDataDict;

// strings
@property (nonatomic, retain) NSString *listingId;
@property (nonatomic, retain) NSString *catId;
@property (nonatomic, retain) NSNumber *listingMapId;

// page control for image
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageArrayOld;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIButton *previousButton;

// file upload eng
@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

// map launch action
- (void)mapDetailViewDisplay:(id)sender;

// page control for image
-(void)handlePagination:(id)sender;
-(void) swipeLeft;
-(void) swipeRight;

// open mail
- (void)openMail;

@end
