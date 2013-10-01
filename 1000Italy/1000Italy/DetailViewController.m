//
//
//  Created by Gareth Jones on 08/07/13.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "PKRevealController.h"
#import "SIAlertView.h"
#import "SimpleTableCell.h"
#import "SimpleTableCellSmall.h"
#import "AsyncImageView.h"
#import "QRReaderViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "KNThirdViewController.h"
#import "MapViewAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImage/UIImageView+WebCache.h"

#define kIDURL @"http://stg.1000italy.com/api/node/"
#define kIDURLPhoto @"stg.1000italy.com/api/node/"
#define GRAY_ICON @"grayicon.png"
#define BLUE_ICON @"blueicon.png"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation DetailViewController

@synthesize detailInfoView, mapView, tableView, listingId,listingMapId, catId, contentView = _contentView, imageArray;
@synthesize flUploadEngine = _flUploadEngine;
@synthesize flOperation = _flOperation;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
        // take ownership of the ViewController that is being presented
        semiVC = [[KNThirdViewController alloc] initWithNibName:@"KNThirdViewController" bundle:nil];
    }
    
    return self;
}

// request extended data table
-(void) requestExtendedData {
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@%@?token=%@", kIDURL, listingId, savedValue];
    
    NSURL *nodeUserCommentsURL = [NSURL URLWithString:stringWithToken];
    NSData *jsonData = [NSData dataWithContentsOfURL:nodeUserCommentsURL];
    
    NSError *error = nil;
    NSDictionary *extendedDataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    NSLog(@"extendedDataDictionary output %@",extendedDataDictionary);
    
    NSArray *data = extendedDataDictionary[@"data"];
    
    listingTitle = [data valueForKey:@"title"];
    listingTags = [data valueForKey:@"tags"];
    listingShortDescription = [data valueForKey:@"short_description"];
    listingAddress = [[data valueForKey:@"address"] valueForKey:@"address"];
    listingPhoneNumber = [data valueForKey:@"phone_number"];

    lat = [[data valueForKey:@"address"] valueForKey:@"lat"];
    lng = [[data valueForKey:@"address"] valueForKey:@"lng"];
    
    listingWebAddress = [data valueForKey:@"website"];
    listingEmailAddress = [data valueForKey:@"email"];
    
    listingMainImageURL = [data valueForKey:@"image"];
    
    likesCount = [data valueForKey:@"likes_count"];
    
    listingOpenings = [data valueForKey:@"openings"];
    
    listingSpecialita = [data valueForKey:@"notable"];
    
    listingPrice = [data valueForKey:@"prices"];
    listingOffers = [data valueForKey:@"offers"];
    
    checkIn_count = [data valueForKey:@"checkins_count"];
    comments_count = [data valueForKey:@"comments_count"];
    
    userLiked = [data valueForKey:@"user_likes"];
    
    userCheckedIn = [data valueForKey:@"user_checkins"];
    
    NSLog(@"usercheckin count %@",userCheckedIn);

    NSLog(@"userLiked count %@",userLiked);

}

-(void) requestUserLikes {
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@%@/likes?token=%@", kIDURL, listingId, savedValue];
    
    NSURL *nodeUserCommentsURL = [NSURL URLWithString:stringWithToken];
    NSData *jsonData = [NSData dataWithContentsOfURL:nodeUserCommentsURL];
    
    NSError *error = nil;
    NSDictionary *userLikesDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    //   NSLog(@"userLikesDictionary %@",userLikesDictionary);
    
    NSArray *data = userLikesDictionary[@"data"];
    userName = [data valueForKey:@"name"];
    userIdLike = [data valueForKey:@"id"];
    userLikesArray = [data valueForKey:@"id"];
}

// request data for user comments table
-(void) requestLikesUpdatedData {
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@%@?token=%@", kIDURL, listingId, savedValue];
    
    NSURL *nodeUserCommentsURL = [NSURL URLWithString:stringWithToken];
    NSData *jsonData = [NSData dataWithContentsOfURL:nodeUserCommentsURL];
    
    NSError *error = nil;
    NSDictionary *extendedDataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
    NSArray *data = extendedDataDictionary[@"data"];

    likesCount = [data valueForKey:@"likes_count"];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [locations lastObject];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        [self requestUserData]; // request user comments data
        
        // comments table added to scrollview
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 770, 310, 400)];
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        // add the comments table to the scrollview
  
        [_scrollView addSubview:self.tableView];

        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];

        categoryId = [catId intValue];
        
            dispatch_async(dispatch_get_main_queue(), ^{

            [self loadImagePageControl];
            [self loadLowerDetail];
            
            UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 10, 10)];
            UIImageView *cornerViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(280, 10, 20, 20)];
            
            [cornerView addSubview:cornerViewImage];
            
            [_scrollView insertSubview:cornerView atIndex:2];

            // set corner color images based on cat id
            
            switch (categoryId) {
                case 9:
                    cornerViewImage.image = [UIImage imageNamed:@"cellComprareCorner.png"];
                    break;
                case 10:
                    cornerViewImage.image = [UIImage imageNamed:@"cellMangiareCorner.png"];
                    break;
                case 11:
                    cornerViewImage.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
                    break;
                case 12:
                    cornerViewImage.image = [UIImage imageNamed:@"cellVivereCorner.png"];
                    break;
                default:
                    break;
            }
            
            [HUD hide:YES];
            
        });
    });
    
    // release the dispatch queue
    dispatch_release(jsonParsingQueue);
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = CGRectMake(320-44, 0 , 44, 44);
    [rightBarButton setImage:[UIImage imageNamed:@"geotag.png"] forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(showRightView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightBarButton];
    
// custom left bar btn
    leftBarBtnItem = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarBtnItem.frame = CGRectMake(0, 0, 80, 50);
   // [leftBarBtnItem setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"barButtonArrow" ofType:@"png"]] forState:UIControlStateNormal];
    [leftBarBtnItem addTarget:self action:@selector(backBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:leftBarBtnItem];
    
    UIImageView *leftBarBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,25,25)];
    [leftBarBtnImg setImage:[UIImage imageNamed:@"barButtonArrow.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtnImg];

    // qr code btn
    qrBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrBarBtn.frame=CGRectMake(245, 10, 24, 24);
    [qrBarBtn addTarget:self action:@selector(presentQR) forControlEvents:UIControlEventTouchDown];
    [qrBarBtn setImage:[UIImage imageNamed:@"qr.png"] forState:0];
    [self.navigationController.navigationBar addSubview:qrBarBtn];
    
    // scrollview alloc and init
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds; //scroll view occupies full parent view
    //specify CGRect bounds in place of self.view.bounds to make it as a portion of parent view
    
    CGSize scrollViewSize = CGSizeMake(320, 1250);
    [_scrollView setContentSize:scrollViewSize];
        
    [self.view addSubview:_scrollView];  //adding to parent view
    // Adjust scroll view content size, set background colour and turn on paging
    
  //  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 12,
                                      //  scrollView.frame.size.height);

    _scrollView.backgroundColor = [UIColor whiteColor];
    
    // Generate content for scrollView using the frame height and width as the reference point
    
    int i = 0;
    while (i<=11) {
        
        UIView *views = [[UIView alloc]
                         initWithFrame:CGRectMake(((_scrollView.frame.size.width)*i)+20, 10,
                                                  (_scrollView.frame.size.width)-40, _scrollView.frame.size.height-20)];
        views.backgroundColor= [UIColor clearColor];
        [views setTag:i];
        [_scrollView addSubview:views];
        
        i++;
    }
    
    // set content view
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];

    //content view appearance
    _contentView.backgroundColor = [UIColor clearColor];

    // add contentview to the view
    [_scrollView addSubview:_contentView];

    [self requestExtendedData]; // request extended listing info data

    // add black btns below photo img
    
    
    detailInfoView = [[UIView alloc] initWithFrame:CGRectMake(5, 370, 310, 500)];
    
    //content view appearance
    detailInfoView.backgroundColor = [UIColor clearColor];
    
    [_scrollView insertSubview: detailInfoView atIndex:5];

    
    CGRect titleFrame = CGRectMake(10, 0, 260, 30);
    UILabel* titleLabel = [[UILabel alloc] initWithFrame: titleFrame];
    titleLabel.numberOfLines = 2;
    
    // check for null value on web addr to avoid crash
    if (![listingTitle isKindOfClass:[NSNull class]])
    {
        
        NSString *uppercase = [listingTitle uppercaseString];
        [titleLabel setText: uppercase];
        
    } else {
        
       [titleLabel setText:@""];
        
    }

    [titleLabel setTextColor: [UIColor blackColor]];
    [titleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:16]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    [detailInfoView addSubview:titleLabel];    
    
    CGRect tagsFrame = CGRectMake(10, 25, 260, 30);
    UILabel* tagsLabel = [[UILabel alloc] initWithFrame: tagsFrame];
    tagsLabel.numberOfLines = 2;
    
    NSString * resultTags = [listingTags componentsJoinedByString:@", "];
    
 
        tagsLabel.text = resultTags;
        
    
    [tagsLabel setTextColor: [UIColor grayColor]];
    [tagsLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    [tagsLabel setBackgroundColor:[UIColor clearColor]];
    
    [detailInfoView addSubview:tagsLabel];
    
    CGRect descriptionFrame = CGRectMake(0, 55, 310, 100);
     self.descriptionTextView = [[UITextView alloc] initWithFrame: descriptionFrame];
    [self.descriptionTextView setText: listingShortDescription];
    
    
    [self.descriptionTextView setTextColor: [UIColor blackColor]];
    [self.descriptionTextView setFont:[UIFont fontWithName:@"DIN-Regular" size:15]];
    [self.descriptionTextView setBackgroundColor:[UIColor clearColor]];

    self.descriptionTextView.editable = NO;

    [detailInfoView addSubview:self.descriptionTextView];
    
    // map view placement
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.userInteractionEnabled = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
  //  [self.mapView setShowsUserLocation:YES];
    
    MKCoordinateRegion region;
    region.center.latitude = [lat doubleValue];
    region.center.longitude = [lng doubleValue];
    
    categoryId = [catId intValue];
    
    // Set some coordinates for position of node
	CLLocationCoordinate2D location;
	location.latitude = [lat doubleValue];
	location.longitude = [lng doubleValue];

	// Add the annotation to our map view
	newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[listingTitle mutableCopy] andCoordinate:location];
	[self.mapView addAnnotation:newAnnotation];
    
    // add map to the content view
    [_scrollView insertSubview:self.mapView atIndex:5];
    
    // add map launch button
    mapLaunchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapLaunchButton addTarget:self
                        action:@selector(mapDetailViewDisplay:)
              forControlEvents:UIControlEventTouchDown];
    [mapLaunchButton setTitle:@"" forState:UIControlStateNormal];
    mapLaunchButton.frame = CGRectMake(0, 0.0, 320.0, 120.0);
    mapLaunchButton.backgroundColor = [UIColor clearColor];
    mapLaunchButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    mapLaunchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [mapLaunchButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [_contentView addSubview:mapLaunchButton];
    
    UIView *lowerTierButtonsView = [[UIView alloc] initWithFrame:CGRectMake(10, 740, 310, 31)];
    lowerTierButtonsView.backgroundColor = [UIColor clearColor];
    
    [_scrollView addSubview:lowerTierButtonsView];
    
    // Scrivi Btn
    UIButton *scriviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scriviButton addTarget:self
                     action:@selector(scriviBtnPress)
           forControlEvents:UIControlEventTouchDown];

    NSString *scriviStringForButton = NSLocalizedString(@"SCRIVI", nil);

    UIImage *scriviButtonImage = [UIImage imageNamed:@"commento.png"];
    
    [scriviButton setTitle:scriviStringForButton forState:UIControlStateNormal];
    [scriviButton setImage:scriviButtonImage forState:UIControlStateNormal];
    
    scriviButton.frame = CGRectMake(0.0, 0.0, 150.0, 28.0);
    scriviButton.backgroundColor = [UIColor blackColor];
    [scriviButton.titleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:14]];
    scriviButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    scriviButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [scriviButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [lowerTierButtonsView addSubview:scriviButton];
    
    // carica Btn
    UIButton *carciaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [carciaButton addTarget:self
                     action:@selector(uploadPhoto:)
           forControlEvents:UIControlEventTouchDown];

    NSString *carciaStringForButton = NSLocalizedString(@"CARICA", nil);

    UIImage *carciaButtonImage = [UIImage imageNamed:@"carica.png"];
    
    [carciaButton setTitle:carciaStringForButton forState:UIControlStateNormal];
    [carciaButton setImage:carciaButtonImage forState:UIControlStateNormal];
    
    
    carciaButton.frame = CGRectMake(160.0, 0.0, 140.0, 28.0);
    carciaButton.backgroundColor = [UIColor blackColor];
    [carciaButton.titleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:14]];
    carciaButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    carciaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [carciaButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [lowerTierButtonsView addSubview:carciaButton];
    
   // [self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];

}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    CGRect frame = self.tableView.frame;
    frame.size = self.tableView.contentSize;
    self.tableView.frame = frame;
    
    CGSize scrollViewSize = CGSizeMake(320, 950+[tableView contentSize].height);
    [_scrollView setContentSize:scrollViewSize];
    
}
*/

-(void)loadLowerDetail {

    // Check-In Btn
    checkInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkInButton addTarget:self
                      action:@selector(checkInBtnPress)
            forControlEvents:UIControlEventTouchUpInside];
    
    NSString *checkInStringForButton = [NSString stringWithFormat:@"CHECK-IN [%@]",checkIn_count];
    UIImage *checkInButtonImage = [UIImage imageNamed:@"classifica_geotag_C.png"];
    
    [checkInButton setTitle:checkInStringForButton forState:UIControlStateNormal];
    [checkInButton setImage:checkInButtonImage forState:UIControlStateNormal];
    
    checkInButton.frame = CGRectMake(165, 330.0, 145, 28.0);

    if ([userCheckedIn integerValue] == 1) {
        switch (categoryId) {
            case 9:
                checkInButton.backgroundColor = customColorComprare;
                break;
            case 10:
                checkInButton.backgroundColor = customColorMangiare;
                break;
            case 11:
                checkInButton.backgroundColor =  customColorVisitare;
                break;
            case 12:
                checkInButton.backgroundColor = customColorVivere;
                break;
            default:
                break;
        }
        
    } else {
        
        checkInButton.backgroundColor = [UIColor blackColor];
        
    }
    
    checkInButton.backgroundColor = [UIColor blackColor];
    [checkInButton.titleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:10]];
    checkInButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    checkInButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [checkInButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [_scrollView insertSubview:checkInButton atIndex:1];

    // Like Btn
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton addTarget:self
                   action:@selector(likeBtnPress)
         forControlEvents:UIControlEventTouchUpInside];
    
    likeStringForButton = [NSString stringWithFormat:@"LIKE [%@]",likesCount];

    UIImage *likeInButtonImage = [UIImage imageNamed:@"classifica_like_C.png"];
    
    
    [likeButton setTitle:likeStringForButton forState:UIControlStateNormal];
    [likeButton setImage:likeInButtonImage forState:UIControlStateNormal];
    
    likeButton.frame = CGRectMake(10.0, 330.0, 145.0, 28.0);
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userIdValue =   [defaults objectForKey:@"userId"];
    
 //   NSLog(@"userLikesArray is %@",userLikesArray);
    
    if ([userLikesArray containsObject:userIdValue]) {
        switch (categoryId) {
            case 9:
                likeButton.backgroundColor = customColorComprare;
                break;
            case 10:
                likeButton.backgroundColor = customColorMangiare;
                break;
            case 11:
                likeButton.backgroundColor =  customColorVisitare;
                break;
            case 12:
                likeButton.backgroundColor = customColorVivere;
                break;
            default:
                break;
        }
        
    } else {
        
        likeButton.backgroundColor = [UIColor blackColor];
        
    }
    
    [likeButton.titleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:10]];
    likeButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [likeButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [_scrollView insertSubview:likeButton atIndex:2];

    // check for null value on specialita addr to avoid crash
    if (![listingSpecialita isKindOfClass:[NSNull class]])
    {
        // specialtyFrame rect and label added to the scroll view
        CGRect specialtyFrame = CGRectMake(10, 165, 100, 30);
        UILabel* specialtyLabel = [[UILabel alloc] initWithFrame: specialtyFrame];
        [specialtyLabel setText: NSLocalizedString(@"SPECIALITA", nil)];
        
        switch (categoryId) {
            case 9:
                [specialtyLabel setTextColor: customColorComprare];
                break;
            case 10:
                [specialtyLabel setTextColor: customColorMangiare];
                break;
            case 11:
                [specialtyLabel setTextColor: customColorVisitare];
                break;
            case 12:
                [specialtyLabel setTextColor: customColorVivere];
                break;
            default:
                break;
        }
        
        // specialtyFrame rect and label added to the scroll view
        CGRect specialtyTextFrame = CGRectMake(80, 165, 100, 30);
        UILabel* specialtyTextLabel = [[UILabel alloc] initWithFrame: specialtyTextFrame];
        
        [specialtyTextLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:11]];
        specialtyTextLabel.backgroundColor = [UIColor clearColor];
        [specialtyTextLabel setText: listingSpecialita];
        
        [detailInfoView addSubview:specialtyTextLabel];
        
        specialtyLabel.backgroundColor = [UIColor clearColor];
        [specialtyLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:11]];
        
        [detailInfoView addSubview:specialtyLabel];
        

    } else {
        
        // don't display the ui control
        
    }
        
    // check for null value on fascia/price addr to avoid crash
    if (![listingPrice isKindOfClass:[NSNull class]])
    {
        // fasciaFrame rect and label added to the scroll view
        CGRect fasciaFrame = CGRectMake(10, 180, 110, 30);
        UILabel* fasciaLabel = [[UILabel alloc] initWithFrame: fasciaFrame];
        [fasciaLabel setText: NSLocalizedString(@"FASCIAPREZZO", nil)];

        // color fascia label based on catId val
        switch (categoryId) {
            case 9:
                [fasciaLabel setTextColor: customColorComprare];
                break;
            case 10:
                [fasciaLabel setTextColor: customColorMangiare];
                break;
            case 11:
                [fasciaLabel setTextColor: customColorVisitare];
                break;
            case 12:
                [fasciaLabel setTextColor: customColorVivere];
                break;
            default:
                break;
        }
        
        fasciaLabel.backgroundColor = [UIColor clearColor];
        [fasciaLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
        
        // fasciaFrame rect and label added to the scroll view
        CGRect fasciaTextFrame = CGRectMake(120, 180, 180, 30);
        UILabel* fasciaTextLabel = [[UILabel alloc] initWithFrame: fasciaTextFrame];
        fasciaTextLabel.backgroundColor = [UIColor clearColor];
        [fasciaTextLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
        [fasciaTextLabel setText: listingPrice];
        
        [detailInfoView addSubview:fasciaTextLabel];
        [detailInfoView addSubview:fasciaLabel];
        
    } else {
        // don't display the ui control
    }
        
    // check for null value on fascia/price addr to avoid crash
    if (![listingOffers isKindOfClass:[NSNull class]])
    {
        // offers rect and label added to the scroll view
        CGRect offerteFrame = CGRectMake(10, 210, 110, 30);
        UILabel* offerteLabel = [[UILabel alloc] initWithFrame: offerteFrame];

        [offerteLabel setText: NSLocalizedString(@"OFFERTE", nil)];

        // color offers label based on catId val
        switch (categoryId) {
            case 9:
                [offerteLabel setTextColor: customColorComprare];
                break;
            case 10:
                [offerteLabel setTextColor: customColorMangiare];
                break;
            case 11:
                [offerteLabel setTextColor: customColorVisitare];
                break;
            case 12:
                [offerteLabel setTextColor: customColorVivere];
                break;
            default:
                break;
        }
        
        offerteLabel.backgroundColor = [UIColor clearColor];
        [offerteLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
        
        // fasciaFrame rect and label added to the scroll view
        CGRect offersTextFrame = CGRectMake(120, 210, 110, 30);
        UILabel* offersTextLabel = [[UILabel alloc] initWithFrame: offersTextFrame];
        offersTextLabel.backgroundColor = [UIColor clearColor];
        [offersTextLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
        [offersTextLabel setText: listingOffers];
        
        [detailInfoView addSubview:offersTextLabel];
        [detailInfoView addSubview:offerteLabel];
        
    } else {
        // don't display the ui control
    }
    
    // check for null value on fascia/price addr to avoid crash
    if (![listingOpenings isKindOfClass:[NSNull class]])
    {
                
        // openings/orario rect and label added to the scroll view
        CGRect openingsFrame = CGRectMake(10, 235, 100, 20);
        UILabel* openingsTitleLabel = [[UILabel alloc] initWithFrame: openingsFrame];

        [openingsTitleLabel setText: NSLocalizedString(@"ORARIO", nil)];

        [openingsTitleLabel setTextColor: [UIColor grayColor]];
        openingsTitleLabel.backgroundColor = [UIColor clearColor];
        [openingsTitleLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
        
        [detailInfoView addSubview:openingsTitleLabel];
        
        // openings/orario rect and label added to the scroll view
        CGRect openingsContentFrame = CGRectMake(10, 248, 290, 30);
        UILabel* openingsLabel = [[UILabel alloc] initWithFrame: openingsContentFrame];
        

        [openingsLabel setText: listingOpenings];

        openingsLabel.numberOfLines = 3;
        [openingsLabel sizeToFit];
        [openingsLabel setTextColor: [UIColor grayColor]];
        openingsLabel.backgroundColor = [UIColor clearColor];
        [openingsLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
        
        [detailInfoView addSubview:openingsLabel];
        
    } else {
        // don't display the ui control
    }
    
    // check for null value on web addr to avoid crash
    if (![listingWebAddress isKindOfClass:[NSNull class]])
    {
        // web rect and label added to the scroll view
        CGRect webFrame = CGRectMake(10, 305, 140, 20);
        UILabel* webLabel = [[UILabel alloc] initWithFrame: webFrame];
        [webLabel setText:listingWebAddress];
        
        // color fascia label based on catId val
        switch (categoryId) {
            case 9:
                [webLabel setTextColor: customColorComprare];
                break;
            case 10:
                [webLabel setTextColor: customColorMangiare];
                break;
            case 11:
                [webLabel setTextColor: customColorVisitare];
                break;
            case 12:
                [webLabel setTextColor: customColorVivere];
                break;
            default:
                break;
        }
        
        webLabel.backgroundColor = [UIColor clearColor];
        [webLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:11]];
        
        // Weblink Btn
        UIButton *webLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [webLinkButton addTarget:self
                          action:@selector(webLinkPress:)
                forControlEvents:UIControlEventTouchDown];
        [webLinkButton setTitle:@"" forState:UIControlStateNormal];
        webLinkButton.frame = CGRectMake(10, 305, 140, 20);
        webLinkButton.backgroundColor = [UIColor clearColor];
        
        [detailInfoView addSubview:webLinkButton];
        [detailInfoView addSubview:webLabel];
        
    } else {
        // don't display the ui control   
    }
    
    // check for null value on web addr to avoid crash
    if (![listingEmailAddress isKindOfClass:[NSNull class]])
    {
        // email rect and label added to the scroll view
        CGRect emailFrame = CGRectMake(180, 305, 120, 20);
        UILabel* emailLabel = [[UILabel alloc] initWithFrame: emailFrame];
        
        [emailLabel setText:listingEmailAddress];

        // color email label based on catId val
        switch (categoryId) {
            case 9:
                [emailLabel setTextColor: customColorComprare];
                break;
            case 10:
                [emailLabel setTextColor: customColorMangiare];
                break;
            case 11:
                [emailLabel setTextColor: customColorVisitare];
                break;
            case 12:
                [emailLabel setTextColor: customColorVivere];
                break;
            default:
                break;
        }

        [detailInfoView addSubview:emailLabel];
        
        emailLabel.backgroundColor = [UIColor clearColor];
        [emailLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:11]];
        
        // Email Btn
        UIButton *emailLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emailLinkButton addTarget:self
                            action:@selector(openMail)
                  forControlEvents:UIControlEventTouchDown];
        [emailLinkButton setTitle:@"" forState:UIControlStateNormal];
        emailLinkButton.frame = CGRectMake(180, 305, 120, 25);
        emailLinkButton.backgroundColor = [UIColor clearColor];
        
        [detailInfoView addSubview:emailLinkButton];
        
    } else {
        // don't display the ui control
    }
      
    // address & phone view with colored cat bg
    UIView *addressPhoneView = [[UIView alloc] initWithFrame:CGRectMake(5, 330, 300, 30)];
    //addressPhoneView view appearance
    
    // color address phone view bg based on catId val
    switch (categoryId) {
        case 9:
            addressPhoneView.backgroundColor = customColorComprare;
            break;
        case 10:
            addressPhoneView.backgroundColor = customColorMangiare;
            break;
        case 11:
            addressPhoneView.backgroundColor = customColorVisitare;
            break;
        case 12:
            addressPhoneView.backgroundColor = customColorVivere;
            break;
        default:
            break;
    }
    
    // address rect and label added to the scroll view
    CGRect addressFrame = CGRectMake(10, 0, 180, 30);
    UILabel* addressLabel = [[UILabel alloc] initWithFrame: addressFrame];
    //    [addressLabel setText: _addressStr];
    [addressLabel setText:listingAddress];
    [addressLabel setTextColor: [UIColor whiteColor]];
    addressLabel.backgroundColor = [UIColor clearColor];
    [addressLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:11]];
    
    [addressPhoneView addSubview:addressLabel];
    
    
    CGRect phoneFrame = CGRectMake(205, 0, 120, 30);
    UILabel* phoneLabel = [[UILabel alloc] initWithFrame: phoneFrame];
    
    // check for null value on phone number to avoid crash
    if (![listingPhoneNumber isKindOfClass:[NSNull class]])
    {
        // do your task here
        
        [phoneLabel setText:listingPhoneNumber];
        
    } else {
        
        [phoneLabel setText:@"no phone"];
        
    }
    
    [phoneLabel setTextColor: [UIColor whiteColor]];
    phoneLabel.backgroundColor = [UIColor clearColor];
    [phoneLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:11]];
    
    [addressPhoneView addSubview:phoneLabel];
    
    
    
    // Email Btn
    UIButton *phoneLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneLinkButton addTarget:self
                        action:@selector(callPhone:)
              forControlEvents:UIControlEventTouchDown];
    [phoneLinkButton setTitle:@"" forState:UIControlStateNormal];
    phoneLinkButton.frame = CGRectMake(205, 0, 120, 30);
    phoneLinkButton.backgroundColor = [UIColor clearColor];
            
    [detailInfoView addSubview:addressPhoneView];
    [addressPhoneView insertSubview:phoneLinkButton aboveSubview:phoneLabel];

    // add black btns below photo
    
    UIView *colorFixView = [[UIView alloc] initWithFrame:CGRectMake(0, 350, 310, 40)];
    colorFixView.backgroundColor = [UIColor clearColor];
    
    [detailInfoView addSubview:colorFixView];
    
}

-(void) loadImagePageControl {
    
    // add image asynchronously
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 130, 300, 180)];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 300, 180)];
    
    NSString *imageURL = listingMainImageURL;
    AsyncImageView *async = [[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 180)];
    [async loadImageFromURL:[NSURL URLWithString:imageURL]];
    [v addSubview:async];
    
    [_scrollView insertSubview:v atIndex:1];

    [v addSubview:iv];
    
   // NSLog(@"imge url %@ ",listingMainImageURL);
    
    UIImage *photoCoverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:listingMainImageURL]]];

    self.imageArray = [NSMutableArray arrayWithObjects:@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",nil];
    
    pageNo = 0;
    pageNumber = 0;
    self.image = [[UIImageView alloc] initWithImage:photoCoverImage ];
    self.image.frame = CGRectMake(0, 0, 300, 180);
    self.image.userInteractionEnabled = YES;
    [v addSubview:self.image];
    pageArray = [[NSMutableArray alloc] init];
    for(int i = 0 ; i < [self.imageArray count] ; i++)
    {
        if(i==0){
            buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonItem setImage:[UIImage imageNamed:BLUE_ICON] forState:UIControlStateNormal];
            [buttonItem setBackgroundColor:[UIColor clearColor]];
            buttonItem.frame=CGRectMake(25+(i*25), 160, 10, 10);
            buttonItem.tag =i;
            [buttonItem addTarget:self action:@selector(handlePagination:) forControlEvents:UIControlEventTouchUpInside];
            
            [v addSubview:buttonItem];
            self.previousButton= buttonItem;
            [pageArray addObject:buttonItem];
            
        }else{
            buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonItem setImage:[UIImage imageNamed:GRAY_ICON] forState:UIControlStateNormal];
            [buttonItem setBackgroundColor:[UIColor clearColor]];
            buttonItem.frame=CGRectMake(25+(i*25), 160, 10, 10);
            buttonItem.tag =i;
            [buttonItem addTarget:self action:@selector(handlePagination:) forControlEvents:UIControlEventTouchUpInside];
            [v addSubview:buttonItem];
            [pageArray addObject:buttonItem];
        }
    }
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    swipeGestureLeft.numberOfTouchesRequired = 1;
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.image addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGestureRight.numberOfTouchesRequired = 1;
    [self.image addGestureRecognizer:swipeGestureRight];
    
}

#pragma MapView delegate methods

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 50, 50);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    // try to dequeue an existing pin view first
    static NSString* myAnnotationIdentifier = @"MyAnnotationIdentifier";
    
    // If an existing pin view was not available, create one
    MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myAnnotationIdentifier];
            
     switch (categoryId) {
     case 9:
     customPinView.image = [UIImage imageNamed:@"PIN_comprare.png"];
     break;
     case 10:
     customPinView.image = [UIImage imageNamed:@"PIN_mangiare.png"];
     break;
     case 11:
     customPinView.image = [UIImage imageNamed:@"PIN_visitare.png"];
     break;
     case 12:
     customPinView.image = [UIImage imageNamed:@"PIN_vivere.png"];
     break;
     default:
     break;
             
     }

  //  customPinView.canShowCallout = YES;

    return customPinView;

}

#pragma map display action
- (void)mapDetailViewDisplay:(id)sender {
    
    mapCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapCloseButton.frame = CGRectMake(275.0, 20.0, 40.0, 40.0);

    [mapCloseButton addTarget:self
                       action:@selector(resignMapDetailViewDisplay:)
             forControlEvents:UIControlEventTouchDown];
    [mapCloseButton setTitle:@"X" forState:UIControlStateNormal];
    
    [mapCloseButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.mapView.frame = CGRectMake(0,0,320,self.view.bounds.size.height);
        
    mapCloseButton.hidden = NO;
    mapLaunchButton.enabled = NO;
    
    [UIView commitAnimations];
    
    [self.mapView selectAnnotation:newAnnotation animated:YES];
    
    [_scrollView insertSubview:self.mapView aboveSubview:detailInfoView];
   
    [self.view addSubview:mapCloseButton];
    
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.userInteractionEnabled = YES;
}

- (IBAction)resignMapDetailViewDisplay:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
    self.mapView.frame = CGRectMake(0,0,320,120);
    
    [UIView commitAnimations];
    
    [self.mapView deselectAnnotation:newAnnotation animated:YES];
    
    mapCloseButton.hidden = YES;
    mapLaunchButton.enabled = YES;

    [_scrollView insertSubview:self.mapView atIndex:6];
    
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.userInteractionEnabled = NO;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
    if (isFullScreen) {

    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        [userSubmittedImageView setFrame:prevFrame];
    }completion:^(BOOL finished){
        isFullScreen = FALSE;;
    }];
    return;
    }
    
}

#pragma Table View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionHeader.textAlignment = UITextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"DIN-Bold" size:8];

    sectionHeader.textColor = [UIColor lightGrayColor];
    
    sectionHeader.text= [NSString stringWithFormat:@"  %i COMMENTI", [message count]];

    return sectionHeader;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier1 = @"SimpleTableCellSmall";
    static NSString *simpleTableIdentifier2 = @"SimpleTableCell";

    
    NSString *description = [photosFromCommentsArray objectAtIndex:indexPath.row];
    
    //   NSLog(@"description is %@",description);
    
    if(description == (id)[NSNull null])
    {
    
        SimpleTableCellSmall *cell = (SimpleTableCellSmall *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier1];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCellSmall" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.nameLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
            [cell.tableTextViewLbl setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
            [cell.timeStampLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:8]];

        }

        imageUrlString = [userImageArray objectAtIndex:indexPath.row];

        if (imageUrlString == (id)[NSNull null] || [imageUrlString isEqualToString:@"null"] || [imageUrlString isEqualToString:@""])
        {
            
        } else {

        
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:imageUrlString]
                       placeholderImage:[UIImage imageNamed:@"rest.png"]];

        }
        
        cell.nameLabel.text = [name objectAtIndex:indexPath.row]; // name
        
        // check for null value on web addr to avoid crash
        if (![[message objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
        {
            
            cell.tableTextViewLbl.text = [message objectAtIndex:indexPath.row]; // message
            
        } else {
            
            cell.tableTextViewLbl.text = @"";
        }
        
        // check for null value on web addr to avoid crash
        if (![[timeStamp objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
            
            // timestamp conversion
            NSString *str = [timeStamp objectAtIndex:indexPath.row];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
            
            NSDate *dte = [dateFormat dateFromString:str];
            
            [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm"];
            cell.timeStampLabel.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:dte]];
            
            
        } else {
            
            cell.timeStampLabel.text = @"";
        }
        
        // check for null value on user profile image url string
        
        return cell;
        
    }
    
    else {
    
        
    SimpleTableCell *cell = (SimpleTableCell *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier2];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
      
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.nameLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
        [cell.tableTextViewLbl setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
        [cell.timeStampLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:8]];
        
    }
    
        imageUrlString = [userImageArray objectAtIndex:indexPath.row];
        
        if (imageUrlString == (id)[NSNull null] || [imageUrlString isEqualToString:@"null"] || [imageUrlString isEqualToString:@""])
        {
            
        } else {
            
            
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:imageUrlString]
                                    placeholderImage:[UIImage imageNamed:@"rest.png"]];
            
        }

        cell.nameLabel.text = [name objectAtIndex:indexPath.row]; // name

        
    // check for null value on web addr to avoid crash
    if (![[message objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]])
    {
        
       cell.tableTextViewLbl.text = [message objectAtIndex:indexPath.row]; // message
  
    } else {
        
        cell.tableTextViewLbl.text = @"";
    }

    // check for null value on web addr to avoid crash
    if (![[timeStamp objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        
        // timestamp conversion
        NSString *str = [timeStamp objectAtIndex:indexPath.row];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
        
        NSDate *dte = [dateFormat dateFromString:str];
        
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm"];
        cell.timeStampLabel.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:dte]];
        
        
    } else {
        
        cell.timeStampLabel.text = @"";
    }

        
        imageUrlPhotoFromUserCommentsArray = [photosFromCommentsArray objectAtIndex:indexPath.row];

        
        if (imageUrlPhotoFromUserCommentsArray == (id)[NSNull null] || [imageUrlPhotoFromUserCommentsArray containsObject:NULL])
        {
            
            imageUrlPhotoFromUserCommentsString = @"";
        
        
        } else {
            
            NSString * result = [imageUrlPhotoFromUserCommentsArray objectAtIndex:0];

            
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.userSubmittedImageView setImageWithURL:[NSURL URLWithString:result]
                                    placeholderImage:[UIImage imageNamed:@"rest.png"]];
            NSLog(@"imageUrlPhotoFromUserCommentsString %@",result);
            
}
 
        
        cell.userSubmittedImageView.userInteractionEnabled = YES;
        cell.userSubmittedImageView.tag = indexPath.row;
        
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFunction:)];
        tapped.numberOfTapsRequired = 1;
        [cell.userSubmittedImageView addGestureRecognizer:tapped];
        
    return cell;
        
    }
    
    return nil;

}


-(void)myFunction :(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"Tag = %d", gesture.view.tag);
    
    userSubmittedImageView = (UIImageView *)gesture.view;
    
    if (!isFullScreen) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            prevFrame = userSubmittedImageView.frame;
                        
            UIView *popupImageViewForTableCell = [[UIView alloc] initWithFrame: CGRectMake ( 0, 0, 300, 200)];
            
            [userSubmittedImageView setFrame:[popupImageViewForTableCell bounds]];

            
        }completion:^(BOOL finished){
            isFullScreen = TRUE;
        }];
        return;
    }
    else{
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            [userSubmittedImageView setFrame:prevFrame];
        }completion:^(BOOL finished){
            isFullScreen = FALSE;;
        }];
        return;
    }
    
    
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
   
    return NO;
    
   /*
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"userId"];
    
    NSNumber *userIdNumber = [userId objectAtIndex:indexPath.row];
    
    NSNumber  *aNum = [NSNumber numberWithInteger: [savedValue integerValue]];
    
    if([userIdNumber isEqualToNumber:aNum]){
        return YES;
    }else{
        return NO;
    }
 
    */
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
      
        [self reloadTableData];

        // use token with url for json data from contents of url
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"token"];
        
        NSNumber *commentIdNumber = [commentId objectAtIndex:indexPath.row];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@/comment/%@?token=%@", kIDURL, listingId, commentIdNumber, savedValue];
        
        NSLog(@"urlstring for delete comment is %@",urlString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"DELETE"];
        
        // generates an autoreleased NSURLConnection
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        [self reloadTableData];
       
        [UIView animateWithDuration:0.5 animations:^{
                        
            [self commentDeletedAlert];
            
            NSLog(@"reload data called");
        }];

    }
}

-(void)saveComment {
      
    messageComment = textFieldComment.text;
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/comments?&token=%@", kIDURL, listingId, savedValue];
    
    NSLog(@"urlstring for comment is %@",urlString);
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    NSString *postString = [NSString stringWithFormat:@"message=%@",messageComment];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    
    // generates an autoreleased NSURLConnection
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    [self dismissSemiModalView];
    
    [self reloadTableData];
    
    [self saveCommentAlert];
    
}

-(void) saveCommentAlert {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Comment Posted!" andMessage:@"posted successfully"];
        
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
        
    }];

}
-(void) commentDeletedAlert {
    
    
    [UIView animateWithDuration:0.5 animations:^{
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Comment Deleted!" andMessage:@"deleted successfully"];
        
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
        
    }];
}

- (void) reloadTableData {
    
  [tableView setContentOffset:CGPointMake(0.0f, -tableView.contentInset.top) animated:YES];  
   
    [self requestUserData];

    [UIView animateWithDuration:0.1 animations:^{
        
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.14];
        
       [HUD hide:YES];

        NSLog(@"reload data called");
    }];
}

// request data for user comments table
-(void) requestUserData {
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@%@/comments?token=%@", kIDURL, listingId, savedValue];
    
    NSURL *nodeUserCommentsURL = [NSURL URLWithString:stringWithToken];
    NSData *jsonData = [NSData dataWithContentsOfURL:nodeUserCommentsURL];
    
    NSError *error = nil;
    NSDictionary *userCommentsDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
  //  NSLog(@"userCommentsDictionary %@",userCommentsDictionary);
    
    userCommentDataArray = userCommentsDictionary[@"data"];
    NSArray *from = [userCommentDataArray valueForKey:@"from"];
    photoArray = [userCommentDataArray valueForKey:@"photos"];
    name = [from valueForKey:@"name"];
    message = [userCommentDataArray valueForKey:@"message"];
    timeStamp = [userCommentDataArray valueForKey:@"created"];
    userImageArray = [from valueForKey:@"picture"];
    photosFromCommentsArray = [photoArray valueForKey:@"url"];
    commentId = [userCommentDataArray valueForKey:@"id"];
    userId = [from valueForKey:@"id"];
    
    NSLog(@"photoArray is %@",    photoArray = [userCommentDataArray valueForKey:@"photos"]);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userCommentDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *description = [photosFromCommentsArray objectAtIndex:indexPath.row];
    
 //   NSLog(@"description is %@",description);

    if(description == (id)[NSNull null])
        
        return 70;
    
    else
        return 200;
    
}

/*
-(CGFloat) tableViewHeight:(UITableView *)tableView {
    NSInteger lastSection = self.tableView.numberOfSections - 1;
    while (lastSection >= 0 && [self.tableView numberOfRowsInSection:lastSection] <= 0)
        lastSection--;
    if (lastSection < 0)
        return 0;
    CGRect lastFooterRect = [self.tableView rectForFooterInSection:lastSection];
    return lastFooterRect.origin.y + lastFooterRect.size.height;
}
*/

#pragma Alert

id observer1,observer2,observer3,observer4;

-(void)checkInBtnPress {
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/checkins?via=button&token=%@", kIDURL, listingId, savedValue];
    
    NSLog(@"urlstring for checkin is %@",urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
        
    // generates an autoreleased NSURLConnection
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    switch (categoryId) {
        case 9:
            checkInButton.backgroundColor = customColorComprare;
            break;
        case 10:
            checkInButton.backgroundColor = customColorMangiare;
            break;
        case 11:
            checkInButton.backgroundColor =  customColorVisitare;
            break;
        case 12:
            checkInButton.backgroundColor = customColorVivere;
            break;
        default:
            break;
    }

}

-(void)likeBtnPress {
    
    if(!toggleLikeIsOn) {

        NSLog(@"like button first pressed toggleValue is %d",toggleLikeIsOn);
        // use token with url for json data from contents of url
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"token"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@/likes?token=%@", kIDURL, listingId, savedValue];
        
        NSLog(@"urlstring is %@",urlString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        // generates an autoreleased NSURLConnection
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        switch (categoryId) {
            case 9:
                likeButton.backgroundColor = customColorComprare;
                break;
            case 10:
                likeButton.backgroundColor = customColorMangiare;
                break;
            case 11:
                likeButton.backgroundColor =  customColorVisitare;
                break;
            case 12:
                likeButton.backgroundColor = customColorVivere;
                break;
            default:
                break;
        }
        
    }
    
    else {
        
        NSLog(@"like button second pressed toggleValue is %d",toggleLikeIsOn);

        // use token with url for json data from contents of url
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"token"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@/likes?token=%@", kIDURL, listingId, savedValue];
        
        NSLog(@"urlstring is %@",urlString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"DELETE"];
        
        // generates an autoreleased NSURLConnection
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        likeButton.backgroundColor = [UIColor blackColor];

       // toggleLikeIsOn = NO;
    }

    toggleLikeIsOn = !toggleLikeIsOn;
  //  [likeButton setImage:[UIImage imageNamed:toggleLikeIsOn ? @"on.png" :@"off.png"] forState:UIControlStateNormal];

}

-(void)scriviBtnPress {
        
    // You can also present a UIViewController with complex views in it
    // and optionally containing an explicit dismiss button for semi modal
    [self presentSemiViewController:semiVC withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(NO),
     KNSemiModalOptionKeys.animationDuration : @(0.5),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
     }];
    
    textFieldComment = [[UITextField alloc] initWithFrame:CGRectMake(20, 50, 280, 40)];
    textFieldComment.borderStyle = UITextBorderStyleRoundedRect;
    textFieldComment.font = [UIFont systemFontOfSize:15];
    textFieldComment.placeholder = @"enter a comment";
    textFieldComment.autocorrectionType = UITextAutocorrectionTypeNo;
    textFieldComment.keyboardType = UIKeyboardTypeDefault;
    textFieldComment.returnKeyType = UIReturnKeyDone;
    textFieldComment.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFieldComment.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textFieldComment.delegate = self;
    [semiVC.view addSubview:textFieldComment];
    
    UIButton *removeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    removeBtn.frame=CGRectMake(180, 100, 80, 35);
    [removeBtn addTarget:self action:@selector(dismissSemiModalView) forControlEvents:UIControlEventTouchDown];

    [removeBtn setTitle:@"CANCEL" forState:UIControlStateNormal];
    
    removeBtn.backgroundColor = customColorVisitare;

    [semiVC.view addSubview:removeBtn];
    
    UIButton *saveBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame=CGRectMake(45, 100, 80, 35);
    [saveBtn addTarget:self action:@selector(saveComment) forControlEvents:UIControlEventTouchDown];
    
    saveBtn.backgroundColor = [UIColor blackColor];
    [saveBtn setTitle:@"SAVE" forState:UIControlStateNormal];
    
    [semiVC.view addSubview:saveBtn];

}

- (void)webLinkPress:(id)sender {
        
    NSString *webString = [NSString stringWithFormat:@"%@", listingWebAddress];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webString]];
}

#pragma Page Control For Image
// page control for image
-(void) swipeLeft {
    self.previousButton.tag = pageNo;
    int prePage = pageNo;
    
    [self.previousButton setImage:[UIImage imageNamed:GRAY_ICON] forState:UIControlStateNormal];
    [self.previousButton setBackgroundColor:[UIColor clearColor]];
    self.previousButton.frame=CGRectMake(25+(prePage*25), 160, 10, 10);
    
    if(pageNo<([imageArray count]-1))
    {
        pageNo = pageNo+1;
    }
    else {
        pageNo =0;
    }
    pageNumber = pageNo;
    UIButton *buton = (UIButton *) [pageArray objectAtIndex:pageNo];
    [buton setImage:[UIImage imageNamed:BLUE_ICON] forState:UIControlStateNormal];
    [buton setBackgroundColor:[UIColor clearColor]];
    buton.frame=CGRectMake(25+(pageNumber*25), 160, 10, 10);
    
    self.previousButton= buton;
    self.image.image = [UIImage imageNamed:[self.imageArray objectAtIndex:pageNumber]];
}

-(void) swipeRight {
    self.previousButton.tag = pageNo;
    int prePage = pageNo;
    
    [self.previousButton setImage:[UIImage imageNamed:GRAY_ICON] forState:UIControlStateNormal];
    [self.previousButton setBackgroundColor:[UIColor clearColor]];
    self.previousButton.frame=CGRectMake(25+(prePage*25), 160, 10, 10);
    if(pageNo == 0)
    {
        pageNo = ([imageArray count]-1);
    }
    else if(pageNo<=([imageArray count]-1))
    {
        pageNo = pageNo-1;
    }
    else {
        pageNo=0;
    }
    pageNumber = pageNo;
    UIButton *buton = (UIButton *)[pageArray objectAtIndex:pageNo];
    [buton setImage:[UIImage imageNamed:BLUE_ICON] forState:UIControlStateNormal];
    [buton setBackgroundColor:[UIColor clearColor]];
    buton.frame=CGRectMake(25+(pageNumber*25), 160, 10, 10);
    
    self.previousButton= buton;
    self.image.image = [UIImage imageNamed:[self.imageArray objectAtIndex:pageNumber]];
}

-(void)handlePagination:(id)sender {
    int prePage = self.previousButton.tag;
    
    [self.previousButton setImage:[UIImage imageNamed:GRAY_ICON] forState:UIControlStateNormal];
    [self.previousButton setBackgroundColor:[UIColor clearColor]];
    self.previousButton.frame=CGRectMake(25+(prePage*25), 160, 10, 10);
    UIButton *button;
    button = (UIButton*)sender;
    pageNumber = button.tag;
    pageNo = pageNumber;
    [button setImage:[UIImage imageNamed:BLUE_ICON] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    button.frame=CGRectMake(25+(pageNumber*25), 160, 10, 10);
    
    self.previousButton= button;
    self.image.image = [UIImage imageNamed:[self.imageArray objectAtIndex:pageNumber]];
}

// send email

- (void)openMail {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"A Message from 1000 Italy"];
        NSArray *toRecipients = [NSArray arrayWithObjects:listingEmailAddress, nil];
        [mailer setToRecipients:toRecipients];
        UIImage *myImage = [UIImage imageNamed:@"icon.png"];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"icon"];
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
     //       NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
      //      NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
      //      NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
      //      NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
       //     NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)backBtnPress {
        [self.navigationController popViewControllerAnimated:YES]; // Back
        self.navigationItem.leftBarButtonItem = nil;
}

-(void)presentQR {
    
    QRReaderViewController *qr = [[QRReaderViewController alloc]initWithNibName:@"QRReaderViewController" bundle:nil];

    UIButton *removeQRBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    removeQRBtn.frame=CGRectMake(260, 10, 60, 40);
    [removeQRBtn addTarget:self action:@selector(removeQR) forControlEvents:UIControlEventTouchDown];
    [removeQRBtn setImage:[UIImage imageNamed:@"qrcode.png"] forState:0];

    [qr.view addSubview:removeQRBtn];
    qr.view.backgroundColor = customColorGrey;
    qr.modalPresentationStyle =  UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:qr animated:YES];
    
}

-(void)removeQR {
    
    [self dismissModalViewControllerAnimated:YES];

}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                imagePicker.allowsEditing = NO;
                [self presentModalViewController:imagePicker animated:YES];
            }
            else {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"This device doesn't have a camera."
                                                  delegate:self cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
			break;
		}
		case 1:
		{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                [self presentModalViewController:imagePicker animated:YES];
            }
            else {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"This device doesn't support photo libraries."
                                                  delegate:self cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
			break;
		}
	}
}

- (IBAction)uploadPhoto:(id)sender {
    UIActionSheet *photoSourcePicker = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Take Photo",
                                        @"Choose from Library",
                                        nil,
                                        nil];
    
    [photoSourcePicker showInView:self.view];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSData *image = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.1);
    
    // use token with url for json data from contents of url
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/photos?token=%@", kIDURLPhoto, listingId, savedValue];
    
    NSLog(@"urlstring for comment is %@",urlString);

    
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:urlString customHeaderFields:nil];
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"image", @"caption",
                                       nil];
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:nil];
    [self.flOperation addData:image forKey:@"picture" mimeType:@"image/jpeg" fileName:@"upload.jpg"];
    
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        NSLog(@"%@", [operation responseString]);
        /*
         This is where you handle a successful 200 response
         */
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Photo Submitted!" andMessage:@"Photo posted successfully"];
            
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
            

        }];

        
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  NSLog(@"%@", error);
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:[error localizedDescription]
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Dismiss"
                                                                        otherButtonTitles:nil];
                                  [alert show];        
                              }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation ];  
    [self reloadTableData];

}

-(IBAction)callPhone:(id)sender {
    
    NSString *phNo = listingPhoneNumber;
    NSString *modifiedPhone = [phNo stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",modifiedPhone]];
    
    //NSLog(@"phNo is %@", modifiedPhone);
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
    
}

- (void)showRightView:(id)sender
{
    
    if (locationManager.location == nil)
    {
        NSLog(@"user location not found yet or service disabled/denied");
    }
    else
    {
        // Change map center (preserving current zoom level)...
        [self.mapView  setCenterCoordinate:locationManager.location.coordinate animated:YES];
        NSLog(@"user location was found ");
        
        // Change map region usingdistance (meters)...
        //        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
        //        (locationManager.location.coordinate, 1000, 1000);
        //        [self.topMapView setRegion:region animated:YES];
        
    }
    
    [self.mapView setShowsUserLocation:YES];
    [self.mapView reloadInputViews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    leftBarBtnItem.hidden = NO;
    leftBarBtnItem.enabled = YES;
    qrBarBtn.hidden = NO;
    qrBarBtn.enabled = YES;
    
    [self requestUserLikes];
    
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    leftBarBtnItem.hidden = YES;
    leftBarBtnItem.enabled = NO;
    qrBarBtn.hidden = YES;
    qrBarBtn.enabled = NO;
    
    [super viewWillDisappear:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
