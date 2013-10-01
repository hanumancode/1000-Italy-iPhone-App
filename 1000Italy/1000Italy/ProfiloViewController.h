

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FXImageView.h"
//#import "TKCalendarMonthView.h"

@interface ProfiloViewController : UIViewController <UIApplicationDelegate,CLLocationManagerDelegate,UITextFieldDelegate, UIActionSheetDelegate,UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource> {
    
    UIView *userLaMiaView;
    UIView *userGreyLineView;

    // data array
    NSMutableArray *publicDataArray;
    
    // user timeline
    NSMutableArray *userTimeLineDataArray;
    
    UILabel *tlabel;

    NSString *imageUrlString;

}

// image download queue
@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) NSMutableArray *timelineNodesArray;

@property (nonatomic,strong) NSMutableArray *publicDetailDataArray;
@property (nonatomic,strong) NSDictionary *publicDetailDataDict;

// tableview
@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, retain) NSArray *items;

@property (nonatomic, retain) NSNumber *likesCount;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSString *listingId;
@property (nonatomic, retain) NSString *catId;

@property (strong, nonatomic) IBOutlet UIView *imageViewPlaceholder;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
