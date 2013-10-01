//
//  ComprareViewController.m
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "ComprareViewController.h"
#import "PKRevealController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyAnnotation.h"
#import "SIAlertView.h"
#import <CoreImage/CoreImage.h>
#import "DetailViewController.h"
#import "QRReaderViewController.h"

#define catID @"9"

@implementation ComprareViewController
@synthesize imageCache,imageDownloadingQueue;
@synthesize tableView;
@synthesize topMapView;
@synthesize listingNodesArray,moreItemsArray;

#pragma mark - View Lifecycle

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [locations lastObject];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"CitySelected"]) {

     //   savedCitySelectedValue = @"Milano";
        
       // latFromCitySaved = @"45.4667";
       // lonFromCitySaved = @"9.1833";
         latFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLat"];
        lonFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLng"];
        
    } else {
    
        savedCitySelectedValue = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"cellCitySelectedTextSaved"];
        latFromCitySaved = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"latFromCitySaved"];
        lonFromCitySaved = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"lonFromCitySaved"];

         }
    

       
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    self.view.backgroundColor = customColorIt;

    self.listingNodesArray = [NSMutableArray array];
    
    self.moreItemsArray = [NSMutableArray array];
    
    
    [self getFeed:index]; // request listings data
    
    NSLog(@"self.listingNodesArray %@",self.listingNodesArray);
    

    // create headerView, set frame and add a label with text title and add it to the navbar
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 280, 48)];
    tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 324, 48)];
    tlabel.text=self.navigationItem.title;
        
    tlabel.text = NSLocalizedString(@"COMPRARE", nil);

    tlabel.font = [UIFont fontWithName:@"DIN-Bold" size:20];
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.textAlignment = UITextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:tlabel];
    self.navigationItem.titleView = headerView;
    
    
    // image download queue
    self.imageDownloadingQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadingQueue.maxConcurrentOperationCount = 4; // many servers limit how many concurrent requests they'll accept from a device, so make sure to set this accordingly
    
    self.imageCache = [[NSCache alloc] init];
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = CGRectMake(320-44, 0 , 44, 44);
    [rightBarButton setImage:[UIImage imageNamed:@"geotag.png"] forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(showRightView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightBarButton];
    
    leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0 , 44, 44);
    [leftBarButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:leftBarButton];
    
    // qr code btn
    qrBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrBarBtn.frame=CGRectMake(245, 10, 24, 24);
    [qrBarBtn addTarget:self action:@selector(presentQR) forControlEvents:UIControlEventTouchDown];
    [qrBarBtn setImage:[UIImage imageNamed:@"qr.png"] forState:0];
    [self.navigationController.navigationBar addSubview:qrBarBtn];
    
    // mapview
    self.topMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, -75, 320, 165)];

    
    // map view coords
    //latNumComp = [[[[self.listingNodesArray objectAtIndex:2] objectForKey:@"address"] objectForKey:@"lat"] doubleValue];
    //lngNumComp = [[[[self.listingNodesArray objectAtIndex:2] objectForKey:@"address"] objectForKey:@"lng"] doubleValue];
    
    
    latNumComp = [latFromCitySaved doubleValue];
    lngNumComp = [lonFromCitySaved doubleValue];
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(latNumComp, lngNumComp);
    
    MKCoordinateSpan span;
    span.latitudeDelta=0.04;
    span.longitudeDelta=0.04;
    
    MKCoordinateRegion ITRegion = MKCoordinateRegionMake(centerCoord, span);
    ITRegion.span=span;
    
    [self.topMapView setRegion: ITRegion animated: YES];
    
	self.topMapView.delegate=self;
    self.topMapView.zoomEnabled = NO;
    self.topMapView.scrollEnabled = NO;
    self.topMapView.userInteractionEnabled = NO;
    
    [self.topMapView setShowsUserLocation:YES];
    
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        
        // once this is done, if you need to you can call
        // some code on a main thread (delegates, notifications, UI updates...)
        dispatch_async(dispatch_get_main_queue(), ^{
            
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.delegate = self;
            [HUD show:YES];
            
            [self.tableView reloadData];
            
            [HUD hide:YES];
            
        });
    });
    
    // release the dispatch queue
    dispatch_release(jsonParsingQueue);
    
    for (int i=0; i<[self.listingNodesArray count]; i++) {
        MyAnnotation* annotation= [MyAnnotation new];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[[self.listingNodesArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[[[self.listingNodesArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"lng"] doubleValue];
        
        
        annotation.coordinate = coordinate;
        
        annotation.title = [[self.listingNodesArray objectAtIndex:i] objectForKey:@"title"];
        annotation.subtitle = [[[self.listingNodesArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"address"];
      
        NSNumber *listingIdNumber = [[self.listingNodesArray objectAtIndex:i] objectForKey:@"id"];
        
        annotation.catListingMapId = listingIdNumber;
        
        [self.topMapView addAnnotation: annotation];
        
    }
    
    [self.view addSubview:self.topMapView];
    
    // add map launch button
    mapLaunchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapLaunchButton addTarget:self
                        action:@selector(mapDetailViewDisplay:)
              forControlEvents:UIControlEventTouchDown];
    [mapLaunchButton setTitle:@"" forState:UIControlStateNormal];
    mapLaunchButton.frame = CGRectMake(0, -75.0, 320.0, 145.0);
    mapLaunchButton.backgroundColor = [UIColor clearColor];
    mapLaunchButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    mapLaunchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [mapLaunchButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [self.view addSubview:mapLaunchButton];
    

    // table view

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(10,90,300,self.view.frame.size.height-75);
    self.tableView.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth );
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    leftBarButton.hidden = NO;
    
    [super viewWillAppear:YES];
    
}

- (void)getFeed:(NSInteger) pageNumber {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSLog(@"countpage %d",index);
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@&category_id=%@&city_slug=%@&page=%d&token=%@",kURL,catID,savedCitySelectedValue, pageNumber, savedValue];
    
    NSLog(@"string token is %@", stringWithToken);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:stringWithToken]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    
    NSError *jsonParsingError = nil;
    
    if (requestError) {
        NSLog(@"sync. request failed with error: %@", requestError);
    }
    
    else {
        
        // handle data
        NSDictionary *publicData =  [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
        moreItemsArray = [publicData objectForKey:@"data"];
        
    }
    
    NSLog(@"moreItemsArray data output is %@",moreItemsArray);
    
    [self.listingNodesArray addObjectsFromArray:moreItemsArray];
    
    [self.tableView reloadData];
    
    NSLog(@"updated self.listingNodesArray %@ and count is %d",self.listingNodesArray, [self.listingNodesArray count]);
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hideHudMethod)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) hideHudMethod {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSLog(@"scrollViewDidEndDecelerating");
    
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        index ++;
        [self getFeed:index];
    }
}

#pragma mark - UITableView methods

//Change the Height of the Cell [Default is 45]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listingNodesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ComprareTableCell";
    
    ComprareTableCell *cell = (ComprareTableCell *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    self.tableView.backgroundColor = customColorLightGrey;
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ComprareTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
        separatorLineView.backgroundColor = customColorIt;
        [cell.contentView addSubview:separatorLineView];
        
        cell.nameLabel.font = [UIFont fontWithName:@"DIN-Bold" size:12];
        cell.tableTextViewLbl.font = [UIFont fontWithName:@"DIN-Regular" size:12];
        cell.separator.font = [UIFont fontWithName:@"DIN-Regular" size:12];
        
        // count labels
        cell.commentCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        cell.likeCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        cell.geoTagCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        
    }
    
    // cell title and subtitle
    
    NSString *uppercaseTitle =   [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"title"];

    NSString *uppercase = [uppercaseTitle uppercaseString];
    
    cell.nameLabel.text = uppercase;
    
    NSString * resultTags = [[[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"tags"] componentsJoinedByString:@", "];

    if ([[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"tags"] == nil || [[[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"tags"] count] == 0) {
        cell.tableTextViewLbl.text = @"";

    } else {
    
    cell.tableTextViewLbl.text = resultTags;
        
    }
    
    // cell comments count
    NSNumber *commentsNum = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"comments_count"];
    cell.commentCountLabel.text = [commentsNum stringValue];
    
    // cell likes count
    NSNumber *likesNum = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"likes_count"];
    cell.likeCountLabel.text = [likesNum stringValue];
    
    // cell likes count
    NSNumber *checkinNum = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"checkins_count"];
    cell.geoTagCountLabel.text = [checkinNum stringValue];
    
    cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];
    
    NSString *uC = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_comments"];
    NSString *uL = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_likes"];
    NSString *uG = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_checkins"];
    
//    NSString *usercommentsstring = [NSString stringWithFormat:@"%@",uC];
//    NSLog(@"usercommentsstring is %@",usercommentsstring);

    int a = [uC integerValue];
    int b = [uL integerValue];
    int c = [uG integerValue];

  //  NSLog(@"c int is %d",a);
    
    if (a == 0) {

        cell.salvaBtnImage.image = [UIImage imageNamed:@"home_verde_commentsOFF.png"];


    } else {
    
        cell.salvaBtnImage.image = [UIImage imageNamed:@"home_verde_commentsON.png"];

        
    }
    if (b == 0) {

        cell.likeBtnImage.image = [UIImage imageNamed:@"home_verde_likeOFF.png"];


    }
    else {
       
        cell.likeBtnImage.image = [UIImage imageNamed:@"home_verde_likeON.png"];


    }

    if (c == 0) {
        
        cell.geoBtnImage.image = [UIImage imageNamed:@"home_verde_geotagOFF.png"];


    } else {
        
        cell.geoBtnImage.image = [UIImage imageNamed:@"home_verde_geotagON.png"];


        
    }

        
    
    // cell image
    // set the image url & image caching
    NSString *imageUrlString = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"image"];
    UIImage *cachedImage = [self.imageCache objectForKey:imageUrlString];
    
    if (cachedImage) {
        cell.thumbnailImageView.image = cachedImage;
    }
    
    else {
        cell.thumbnailImageView.image = [UIImage imageNamed:@"rest.png"]; // initialize the image with placeholder image
        
        // download in the image in the background
        [self.imageDownloadingQueue addOperationWithBlock:^{
            
            NSURL *imageUrl   = [NSURL URLWithString:imageUrlString];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
            UIImage *image    = nil;
            if (imageData)
                image = [UIImage imageWithData:imageData];
            
            if (image)
            {
                
                [self.imageCache setObject:image forKey:imageUrlString]; // add the image to your cache
                
                // finally, update the user interface in the main queue
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // make sure the cell is still visible
                    
                    ComprareTableCell *updateCell = (ComprareTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        cell.thumbnailImageView.image = image;
                    
                }];
            }
        }];
    }
    
    return cell;

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //   NSLog(@"Row selected: %d",indexPath.row);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        
        detailViewController.listingId = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"id"];
        
        NSNumber *catNumber = [NSNumber numberWithInt:[catID intValue]];
        
        detailViewController.catId = [catNumber stringValue];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapingView viewForAnnotation:(id <MKAnnotation>) annotation {
    annView = nil;
    if(annotation != mapingView.userLocation)
    {
        
        static NSString *defaultPinID = @"";
        annView = (MKAnnotationView *)[mapingView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( annView == nil )
            annView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
        
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        //   [rightButton addTarget:self
        //               action:@selector(showDetails:)
        //   forControlEvents:UIControlEventTouchUpInside];
        annView.rightCalloutAccessoryView = rightButton;
        annView.image = [UIImage imageNamed:@"PIN_comprare.png"];// sets image for pin

        annView.canShowCallout = YES;
        
    }
    
    return annView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
  	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
  	MyAnnotation *theAnnotation = (MyAnnotation *) pin.annotation;
    
    detailViewController.listingId = [theAnnotation.catListingMapId stringValue];
    
    NSNumber *catNumber = [NSNumber numberWithInt:[catID intValue]];
    
    detailViewController.catId = [catNumber stringValue];
    
  	[self.navigationController pushViewController:detailViewController animated:YES];
    
    [self hideHudMethod];
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
    self.topMapView.frame = CGRectMake(0,0,320,self.view.bounds.size.height);
    
    mapCloseButton.hidden = NO;
    mapLaunchButton.enabled = NO;
    
    [UIView commitAnimations];
    
   // [self.topMapView selectAnnotation:newAnnotation animated:YES];
    
    [self.view addSubview:self.topMapView];
    
    [self.view addSubview:mapCloseButton];
    
    self.topMapView.zoomEnabled = YES;
    self.topMapView.scrollEnabled = YES;
    self.topMapView.userInteractionEnabled = YES;
    
}

- (IBAction)resignMapDetailViewDisplay:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    self.topMapView.frame = CGRectMake(0,-75,320,165);
    
    [UIView commitAnimations];
    
  //  [self.topMapView deselectAnnotation:newAnnotation animated:YES];
    
    mapCloseButton.hidden = YES;
    mapLaunchButton.enabled = YES;
    
    [self.view insertSubview:mapLaunchButton atIndex:6];
    
    self.topMapView.zoomEnabled = NO;
    self.topMapView.scrollEnabled = NO;
    self.topMapView.userInteractionEnabled = NO;
    
}

#pragma Alert

id observer1,observer2,observer3,observer4;

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

- (void)showRightView:(id)sender
{
    
    if (locationManager.location == nil)
    {
        NSLog(@"user location not found yet or service disabled/denied");
    }
    else
    {
        // Change map center (preserving current zoom level)...
        [self.topMapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
        NSLog(@"user location was found ");
        
        // Change map region using distance (meters)...
        //        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
        //        (locationManager.location.coordinate, 1000, 1000);
        //        [self.topMapView setRegion:region animated:YES];
        
    }
    
    [self getFeed:index];
    [self.topMapView setShowsUserLocation:YES];
    [self.topMapView reloadInputViews];
    
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

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self hideLeftBarBtn];
    
}

-(void) hideLeftBarBtn {
    leftBarButton.hidden = YES;
    
}

@end