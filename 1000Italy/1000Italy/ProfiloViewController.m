//
//
//  Created by Gareth Jones on 08/07/13.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "ProfiloViewController.h"
#import "PKRevealController.h"
#import "SIAlertView.h"
#import "TimelineTableCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

#define kIDURL @"http://stg.1000italy.com/api/node/"

@implementation ProfiloViewController {

    NSMutableArray *tableData;
    NSMutableArray *message;
    NSMutableArray *imageTimeline;
    NSMutableArray *userName;
    NSMutableArray *titleTimeline;
    NSMutableArray *timeStamp;
    
    NSString *firstName;
    NSString *lastName;
    
    NSString *userProfileImageUrl;
    NSNumber *checkinCount;
    NSNumber *likesCount;
    NSNumber *savedCount;
    NSNumber *pointsCount;
    
    // user timeline
    NSString *titleUserTimeline;
    NSArray *verbUserTimeline;
    NSString *urlUserTimeline;
    NSNumber *catIdUserTimeline;
    NSDate *createdAtUserTimeline;
    
    NSArray *commentId;

}

// static int calendarShadowOffset = (int)-20;

@synthesize listingId, catId, contentView = _contentView;
@synthesize likesCount = _likesCount;
@synthesize imageCache,imageDownloadingQueue;

#pragma mark - View lifecycle

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        // Custom initialization.
//		calendar = 	[[TKCalendarMonthView alloc] init];
//		calendar.delegate = self;
//		calendar.dataSource = self;
    }
    return self;
}
*/

-(void)requestData {
        
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    // use token with url for json data from contents of url
    NSString *savedUserIdValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"userId"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"http://stg.1000italy.com/api/profile/%@?token=%@",savedUserIdValue, savedValue];
    
    NSLog(@"user profile string token is %@", stringWithToken);
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:stringWithToken]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    
    NSError *jsonParsingError = nil;
    
    if (requestError)
    {
        NSLog(@"sync. request failed with error: %@", requestError);
    }
    else
    {
        // handle data
        NSDictionary *publicData =  [NSJSONSerialization JSONObjectWithData:response
                                                                    options:0
                                                                      error:&jsonParsingError];
        publicDataArray = [publicData objectForKey:@"data"];
        
    }
    
    NSLog(@"data output for user profile is %@",publicDataArray);

    firstName = [publicDataArray valueForKey:@"first_name"];
    lastName = [publicDataArray valueForKey:@"last_name"];
    
    userProfileImageUrl = [publicDataArray valueForKey:@"picture"];
    
    checkinCount = [publicDataArray valueForKey:@"checkins_count"];
    likesCount = [publicDataArray valueForKey:@"likes_count"];
    savedCount = [publicDataArray valueForKey:@"saved_count"];
    pointsCount = [publicDataArray valueForKey:@"points"];
    
    commentId = [publicDataArray valueForKey:@"id"];

}

-(void) requestUserTimelineData {
            
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    // use token with url for json data from contents of url
    NSString *savedUserIdValue = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"userId"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"http://stg.1000italy.com/api/profile/%@/timeline?token=%@",savedUserIdValue, savedValue];
    
    NSURL *nodeUserTimelineURL = [NSURL URLWithString:stringWithToken];
    NSData *jsonData = [NSData dataWithContentsOfURL:nodeUserTimelineURL];
    
    NSError *error = nil;
    NSDictionary *userTimelineDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    //   NSLog(@"userCommentsDictionary %@",userCommentsDictionary);
    
    NSArray *data = userTimelineDictionary[@"data"];
//  NSArray *from = [data valueForKey:@"from"];
    NSArray *node = [data valueForKey:@"node"];

    userName = [node valueForKey:@"title"];
    timeStamp = [data valueForKey:@"created"];
    verbUserTimeline = [data valueForKey:@"verb"];
    imageTimeline = [node valueForKey:@"image"];
//    NSLog(@"data is %@ ",data);
//    NSLog(@"from is %@ ",from);
//    NSLog(@"name is %@ ",name);

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestData];
    
    [self requestUserTimelineData];
    
    // create headerView, set frame and add a label with text title and add it to the navbar
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 280, 48)];
    tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 324, 48)];
    tlabel.text=self.navigationItem.title;
    
    [tlabel setText:NSLocalizedString(@"IL MIO PROFILO", nil)];

    tlabel.font = [UIFont fontWithName:@"DIN-Bold" size:20];
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.textAlignment = UITextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:tlabel];
    self.navigationItem.titleView = headerView;

    // left navbar button
   UIButton * leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0 , 44, 44);
    [leftBarButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:leftBarButton];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds; //scroll view occupies full parent view
    //specify CGRect bounds in place of self.view.bounds to make it as a portion of parent view
    
    CGSize scrollViewSize = CGSizeMake(320, 850);
    [_scrollView setContentSize:scrollViewSize];
        
    [self.view addSubview:_scrollView];   //adding to parent view
    
    _scrollView.backgroundColor = customColorIt;
    
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

    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 240)];

    //content view appearance
    _contentView.backgroundColor = customColorIt;
    _scrollView.backgroundColor = customColorIt;

    // add user profile image to _contentView
    UIImageView *userImageView;

    UIImage *userImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userProfileImageUrl]]];

    userImageView=[[UIImageView alloc]initWithImage:userImage];
    userImageView.frame=CGRectMake(10,10,90,100);
    
    [_contentView addSubview:userImageView];
    
    // user name lable
    CGRect userNameFrame = CGRectMake(110, 60, 100, 50 );
    UILabel* userNameLabel = [[UILabel alloc] initWithFrame: userNameFrame];
    [userNameLabel setText: firstName];
    [userNameLabel setTextColor: [UIColor blackColor]];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:14]];
    
    [_contentView addSubview:userNameLabel];
    
    // user last name label
    CGRect userLastNameFrame = CGRectMake(110, 75, 100, 50 );
    UILabel* userLastNameLabel = [[UILabel alloc] initWithFrame: userLastNameFrame];
    [userLastNameLabel setText: lastName];
    [userLastNameLabel setTextColor: [UIColor blackColor]];
    [userLastNameLabel setBackgroundColor:[UIColor clearColor]];
    [userLastNameLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:14]];
    
    [_contentView addSubview:userLastNameLabel];

    // user checkin view
    UIView *userCheckinView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 300, 25)];
    userCheckinView.backgroundColor = customColorGrey;
    [_contentView addSubview:userCheckinView];

    // check in label
    UILabel* userCheckInLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 100, 20)];
    [userCheckInLabel setText: @"CHECK-IN"];
    userCheckInLabel.backgroundColor = customColorGrey;
    userCheckInLabel.textColor = customColorIt;
    [userCheckInLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userCheckinView addSubview:userCheckInLabel];

    // image
    UIImageView *checkinImg = [[UIImageView alloc]
                             initWithImage:[UIImage imageNamed:@"classifica_geotag_C.png"]];
    checkinImg.frame = CGRectMake(5, 0, 24, 24);
    [userCheckinView addSubview:checkinImg];
    
    // check in label
    UILabel* userCheckInCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 2, 20, 20)];
    [userCheckInCountLabel setText: [checkinCount stringValue]];
    userCheckInCountLabel.backgroundColor = customColorGrey;
    userCheckInCountLabel.textColor = customColorIt;
    [userCheckInCountLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userCheckinView addSubview:userCheckInCountLabel];

    
    // user salvati view
    UIView *userSalvatiView = [[UIView alloc] initWithFrame:CGRectMake(10, 150, 300, 25)];
    userSalvatiView.backgroundColor = customColorGrey;
    [_contentView addSubview:userSalvatiView];
    
    // salvati label
    UILabel* userSalvatiLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 100, 20)];
    [userSalvatiLabel setText:NSLocalizedString(@"SALVATI", nil)];

    userSalvatiLabel.backgroundColor = customColorGrey;
    userSalvatiLabel.textColor = customColorIt;
    [userSalvatiLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userSalvatiView addSubview:userSalvatiLabel];
    
    // image
    UIImageView *salvaImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"classifica_salvaMod.png"]];
    salvaImg.frame = CGRectMake(5, 0, 24, 24);
    [userSalvatiView addSubview:salvaImg];

    // salva count label
    UILabel* userSalvaCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 2, 20, 20)];
    [userSalvaCountLabel setText: [savedCount stringValue]];
    userSalvaCountLabel.backgroundColor = customColorGrey;
    userSalvaCountLabel.textColor = customColorIt;
    [userSalvaCountLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userSalvatiView addSubview:userSalvaCountLabel];

    
    // user like view
    UIView *userLikeView = [[UIView alloc] initWithFrame:CGRectMake(10, 180, 300, 25)];
    userLikeView.backgroundColor = customColorGrey;
    [_contentView addSubview:userLikeView];
    
    // like label
    UILabel* userLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 100, 20)];
    [userLikeLabel setText: @"LIKE"];
    userLikeLabel.backgroundColor = customColorGrey;
    userLikeLabel.textColor = customColorIt;
    [userLikeLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userLikeView addSubview:userLikeLabel];
    
    // image
    UIImageView *likeImg = [[UIImageView alloc]
                             initWithImage:[UIImage imageNamed:@"classifica_like_C.png"]];
    likeImg.frame = CGRectMake(5, 0, 24, 24);
    [userLikeView addSubview:likeImg];

    
    // user like label
    UILabel* userLikeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 2, 20, 20)];
    [userLikeCountLabel setText: [likesCount stringValue]];
    userLikeCountLabel.backgroundColor = customColorGrey;
    userLikeCountLabel.textColor = customColorIt;
    [userLikeCountLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
    
    [userLikeView addSubview:userLikeCountLabel];

    
    // la mia bacheca like view
    userLaMiaView = [[UIView alloc] initWithFrame:CGRectMake(10, 230, 300, 25)];
    userLaMiaView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:userLaMiaView];
    
    
    // like label
    UILabel* userLaMiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 150, 20)];
    [userLaMiaLabel setText:NSLocalizedString(@"LA MIA BACHECA", nil)];

    userLaMiaLabel.backgroundColor = [UIColor clearColor];
    userLaMiaLabel.textColor = customColorGrey;
    [userLaMiaLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:10]];
    
    [userLaMiaView addSubview:userLaMiaLabel];

   
    // grey line view below la mia label
    userGreyLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 248, 300, 1.5)];
    userGreyLineView.backgroundColor = customColorGrey;
    [_contentView addSubview:userGreyLineView];
    

    // detail info view
    UIView *detailInfoView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
    
    //content view appearance
    detailInfoView.backgroundColor = [UIColor whiteColor];

    [_scrollView addSubview:detailInfoView];

    // add contentview to the view
    [_scrollView addSubview:_contentView];

    
    // add black btns below photo
    UIView *colorFixView = [[UIView alloc] initWithFrame:CGRectMake(0, 350, 300, 40)];
    colorFixView.backgroundColor = [UIColor greenColor];
    
    [detailInfoView addSubview:colorFixView];

    detailInfoView.backgroundColor = customColorMangiare;
    
    // comments table added to scrollview
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 270, 300, 350)];
    
    // add the comments table to the scrollview
    [_scrollView addSubview:tableView];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    // image download queue
    self.imageDownloadingQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadingQueue.maxConcurrentOperationCount = 4; // many servers limit how many concurrent requests they'll accept from a device, so make sure to set this accordingly
    
    self.imageCache = [[NSCache alloc] init];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionHeader.textAlignment = UITextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"DIN-Bold" size:6];

    sectionHeader.textColor = [UIColor lightGrayColor];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TimelineTableCell";
    
    TimelineTableCell *cell = (TimelineTableCell *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TimelineTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.nameLabel setFont:[UIFont fontWithName:@"DIN-Bold" size:12]];
        [cell.tableTextViewLbl setFont:[UIFont fontWithName:@"DIN-Regular" size:12]];
        [cell.timeStampLabel setFont:[UIFont fontWithName:@"DIN-Regular" size:8]];
        
    }
    
    cell.nameLabel.text = [userName objectAtIndex:indexPath.row]; // name
    cell.tableTextViewLbl.text = [verbUserTimeline objectAtIndex:indexPath.row]; // message
    
    // timestamp conversion
    NSString *str = [timeStamp objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    
    NSDate *dte = [dateFormat dateFromString:str];
    
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm"];
    cell.timeStampLabel.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:dte]];
    
    
    imageUrlString = [imageTimeline objectAtIndex:indexPath.row];
    
    if (imageUrlString == (id)[NSNull null] || [imageUrlString isEqualToString:@"null"] || [imageUrlString isEqualToString:@""])
    {
        
    } else {
        
        
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:imageUrlString]
                                placeholderImage:[UIImage imageNamed:@"rest.png"]];
        
    }
    
    return cell;

}

/*
 
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
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
 
    }
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [userName count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
    
    NSString *str = [publicDataArray objectAtIndex:indexPath.row];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"%f",size.height);
    return size.height + 10;
}

#pragma Alert

id observer1,observer2,observer3,observer4;

- (void)webLinkPress:(id)sender {
    
    // [self alertForgotPass:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.1000Italy.com"]];
    
}

- (void)emailLinkPress:(id)sender {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"emailBtnPress" andMessage:@"email launch method goes here"];
    
    [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
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
    
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

/*
 #pragma Calendar
 
 // Show/Hide the calendar by sliding it down/up from the top of the device.
 - (void)toggleCalendar {
 
 NSLog(@"toggle calendar");
 
 // If calendar is off the screen, show it, else hide it (both with animations)
 if (calendar.frame.origin.y == -calendar.frame.size.height+calendarShadowOffset) {
 // Show
 
 _scrollView.scrollEnabled = NO;
 
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:.50];
 calendar.frame = CGRectMake(0, 230, calendar.frame.size.width, calendar.frame.size.height);
 calendar.hidden = NO;
 
 
 userLaMiaView.alpha = 0;
 userGreyLineView.alpha = 0;
 
 [UIView commitAnimations];
 
 
 } else {
 // Hide
 
 calendar.hidden = YES;
 _scrollView.scrollEnabled = YES;
 
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:.75];
 calendar.frame = CGRectMake(0, -calendar.frame.size.height+calendarShadowOffset, calendar.frame.size.width, calendar.frame.size.height);
 
 userLaMiaView.alpha = 1;
 userGreyLineView.alpha = 1;
 
 [UIView commitAnimations];
 
 }
 }
 */

/*
 #pragma mark TKCalendarMonthViewDelegate methods
 
 - (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
 NSLog(@"calendarMonthView didSelectDate %@",d);
 }
 
 - (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d {
 NSLog(@"calendarMonthView monthDidChange");
 }
 
 #pragma mark -
 #pragma mark TKCalendarMonthViewDataSource methods
 
 - (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
 NSLog(@"calendarMonthView marksFromDate toDate");
 NSLog(@"Make sure to update 'data' variable to pull from CoreData, website, User Defaults, or some other source.");
 // When testing initially you will have to update the dates in this array so they are visible at the
 // time frame you are testing the code.
 NSArray *data = [NSArray arrayWithObjects:
 @"2011-01-01 00:00:00 +0000", @"2011-01-09 00:00:00 +0000", @"2011-01-22 00:00:00 +0000",
 @"2011-01-10 00:00:00 +0000", @"2011-01-11 00:00:00 +0000", @"2011-01-12 00:00:00 +0000",
 @"2011-01-15 00:00:00 +0000", @"2011-01-28 00:00:00 +0000", @"2011-01-04 00:00:00 +0000",
 @"2011-01-16 00:00:00 +0000", @"2011-01-18 00:00:00 +0000", @"2011-01-19 00:00:00 +0000",
 @"2011-01-23 00:00:00 +0000", @"2011-01-24 00:00:00 +0000", @"2011-01-25 00:00:00 +0000",
 @"2011-02-01 00:00:00 +0000", @"2011-03-01 00:00:00 +0000", @"2011-04-01 00:00:00 +0000",
 @"2011-05-01 00:00:00 +0000", @"2011-06-01 00:00:00 +0000", @"2011-07-01 00:00:00 +0000",
 @"2011-08-01 00:00:00 +0000", @"2011-09-01 00:00:00 +0000", @"2011-10-01 00:00:00 +0000",
 @"2011-11-01 00:00:00 +0000", @"2011-12-01 00:00:00 +0000", nil];
 
 
 // Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
 NSMutableArray *marks = [NSMutableArray array];
 
 // Initialise calendar to current type and set the timezone to never have daylight saving
 NSCalendar *cal = [NSCalendar currentCalendar];
 [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 
 // Construct DateComponents based on startDate so the iterating date can be created.
 // Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed
 // with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first
 // iterating date then times would go up and down based on daylight savings.
 NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit |
 NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit)
 fromDate:startDate];
 NSDate *d = [cal dateFromComponents:comp];
 
 // Init offset components to increment days in the loop by one each time
 NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
 [offsetComponents setDay:1];
 
 
 // for each date between start date and end date check if they exist in the data array
 while (YES) {
 // Is the date beyond the last date? If so, exit the loop.
 // NSOrderedDescending = the left value is greater than the right
 if ([d compare:lastDate] == NSOrderedDescending) {
 break;
 }
 
 // If the date is in the data array, add it to the marks array, else don't
 if ([data containsObject:[d description]]) {
 [marks addObject:[NSNumber numberWithBool:YES]];
 } else {
 [marks addObject:[NSNumber numberWithBool:NO]];
 }
 
 // Increment day using offset components (ie, 1 day in this instance)
 d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
 }
 
 return [NSArray arrayWithArray:marks];
 }
 */

@end
