//
//  FrontViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "FrontViewController.h"
#import "PKRevealController.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "MyAnnotation.h"
#import <CoreImage/CoreImage.h>
#import "DetailViewController.h"
#import "QRReaderViewController.h"
#import "ComprareTableCell.h"
#import "Constants.h"

@implementation FrontViewController

@synthesize searchBar;
@synthesize imageCache,imageDownloadingQueue;
@synthesize tableViewNode,tableViewCities;
@synthesize topMapView;
@synthesize listingNodesArray,moreItemsArray;
@synthesize locationManager;

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated {
    
    leftBarButton.hidden = NO; // reveal left barbtn
   // [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"CitySelected"];
    
    [super viewWillAppear:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = customColorIt;

    savedCitySelectedValue = [[NSUserDefaults standardUserDefaults]
                              stringForKey:@"cellCitySelectedTextSaved"];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"CitySelected"]) {
        savedCitySelectedValue = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"cellCitySelectedTextSaved"];
        latFromCitySaved = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"latFromCitySaved"];
        lonFromCitySaved = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"lonFromCitySaved"];
        NSLog(@"front vc CitySelected");

    } else {
                
        latFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLat"];
        lonFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLng"];
        NSLog(@"front CitySelected not selected");

    }

    NSLog(@"savedCitySelectedValue%@",savedCitySelectedValue);
        
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"CitySelected"]) {
//        
////        savedCitySelectedValue = @"Milano";
////        
////        latFromCitySaved = @"45.4667";
////        lonFromCitySaved = @"9.1833";
//
//        [self userLocationFind];
//        
//        latFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLat"];
//        lonFromCitySaved = [[NSUserDefaults standardUserDefaults] stringForKey:@"userLng"];
//        
//    } else {
//        
//        savedCitySelectedValue = [[NSUserDefaults standardUserDefaults]
//                                  stringForKey:@"cellCitySelectedTextSaved"];
//        latFromCitySaved = [[NSUserDefaults standardUserDefaults]
//                            stringForKey:@"latFromCitySaved"];
//        lonFromCitySaved = [[NSUserDefaults standardUserDefaults]
//                            stringForKey:@"lonFromCitySaved"];
//        
//    }

    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    // mapview
    self.topMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, -75, 320, 165)];
    self.topMapView.delegate=self;
    [self.view addSubview:self.topMapView];
    
    // add map launch button
    mapLaunchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapLaunchButton addTarget:self
                        action:@selector(mapDetailViewDisplay:)
              forControlEvents:UIControlEventTouchDown];
    [mapLaunchButton setTitle:@"" forState:UIControlStateNormal];
    mapLaunchButton.frame = CGRectMake(0, -75.0, 320.0, 150.0);
    mapLaunchButton.backgroundColor = [UIColor clearColor];
    mapLaunchButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    mapLaunchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [mapLaunchButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [self.view addSubview:mapLaunchButton];
    
    //table view
    self.tableViewNode = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.tableViewNode.frame = CGRectMake(10,90,300,self.view.frame.size.height-75);
    self.tableViewNode.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth );
    self.tableViewNode.dataSource = self;
    self.tableViewNode.delegate = self;
    self.tableViewNode.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableViewNode];
    
    cityTableOpen = NO;
    
    self.tableViewCities = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.tableViewCities.frame = CGRectMake(0,0,300,160);
    self.tableViewCities.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth );
    self.tableViewCities.dataSource = self;
    self.tableViewCities.delegate = self;
    self.tableViewCities.backgroundColor = [UIColor whiteColor];
    [self.tableViewCities.layer setBorderWidth: 1.0];
    [self.tableViewCities.layer setMasksToBounds:YES];
    [self.tableViewCities.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    myview=[[UIView alloc] initWithFrame: CGRectMake(10, 0,300,160)];
    myview.backgroundColor=[UIColor clearColor];
    [myview addSubview:self.tableViewCities];
    
    // image download queue
    self.imageDownloadingQueue = [[NSOperationQueue alloc] init];
    self.imageDownloadingQueue.maxConcurrentOperationCount = 4; // many servers limit how many concurrent requests they'll accept from a device, so make sure to set this accordingly
    
    self.imageCache = [[NSCache alloc] init];
    
    // search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 190.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(90.0, 0.0, 230.0, 44.0)];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    
    searchBar.layer.borderColor=[UIColor whiteColor].CGColor;
    
    UITextField *textfield=(UITextField*)[[searchBar subviews] objectAtIndex:1];
    textfield.leftView=nil;
    
    [searchBarView addSubview:searchBar];
    self.navigationItem.titleView = searchBarView;
    
    //cancel btn formatting
    [[UIButton appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@"Cancel" forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor blackColor]];
    
    for (UIView *searchBarSubview in [searchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                
                [(UITextField *)searchBarSubview setBorderStyle:UITextBorderStyleRoundedRect];
                self.searchDisplayController.searchBar.layer.backgroundColor = [UIColor blueColor].CGColor;
                
            }
            @catch (NSException * e) {
                // ignore exception
            }
        }
    }
    
    for (id v in [searchBar subviews]) {
        if (![v isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            [v setAlpha:0.0f];
            [v setHidden:YES];
            
        }
        else {
            [v setBackgroundColor:[UIColor lightGrayColor]];
            [v setAlpha:0.2f];
            
        }
    }
    
    for(UIView *subView in searchBar.subviews){
        if([subView isKindOfClass:UITextField.class]){
            [(UITextField*)subView setTextColor:[UIColor whiteColor]];
            [(UITextField*)subView setFont:[UIFont fontWithName:@"DIN-Regular" size:18]];
        }
    }
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = CGRectMake(320-44, 0 , 44, 44);
    [rightBarButton setImage:[UIImage imageNamed:@"geotag.png"] forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(userLocationFind) forControlEvents:UIControlEventTouchUpInside];
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
    
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        
        // once this is done, if you need to you can call
        // some code on a main thread (delegates, notifications, UI updates...)
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
                [self getFeed:index]; // request listings data
                
                [self.tableViewNode reloadData];
                //           [self hideHudMethod];
                
                [self loadMap]; // load map


            [self citySearchArrayMethod];

        });
    });
    
    // release the dispatch queue
    dispatch_release(jsonParsingQueue);
    
    
}

-(void)loadMap{
    
    CLLocationCoordinate2D coordinate = [self getLocation];
    currentUserLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    currentUserLongitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSLog(@"*dLatitude : %@", currentUserLatitude);
    NSLog(@"*dLongitude : %@",currentUserLongitude);
    
    // map view coords
    latNum = [[[[self.listingNodesArray objectAtIndex:5] objectForKey:@"address"] objectForKey:@"lat"] doubleValue];
    lngNum = [[[[self.listingNodesArray objectAtIndex:5] objectForKey:@"address"] objectForKey:@"lng"] doubleValue];
    
    
    if (self.listingNodesArray == nil) {
//        latNum =45.464461;
//        lngNum = 9.189221;
        
        NSLog(@"list nodes is null hard set coords");
    } else {
        
        latNum = [currentUserLatitude doubleValue];
        lngNum = [currentUserLongitude doubleValue];
        
        NSLog(@"list nodes is not null coords are %f %f",latNum,lngNum);
    }
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(latNum, lngNum);
    
    MKCoordinateSpan span;
    span.latitudeDelta=0.06;
    span.longitudeDelta=0.06;
    
    MKCoordinateRegion ITRegion = MKCoordinateRegionMake(centerCoord, span);
    ITRegion.span=span;
    
    [self.topMapView setRegion: ITRegion animated: YES];
    
    if (!self.listingNodesArray) {
        self.listingNodesArray = [NSMutableArray array];
        self.moreItemsArray = [NSMutableArray array];
    } else {
        
    }
    
  //  CLLocationCoordinate2D coordinate = [self getLocation];
    currentUserLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    currentUserLongitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSLog(@"*dLatitude : %@", currentUserLatitude);
    NSLog(@"*dLongitude : %@",currentUserLongitude);
}

-(void)loadMapCitySearch{
    
    //copy your annotations to an array
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: self.topMapView.annotations];
    
    //Remove all annotations in the array from the mapView
    [self.topMapView removeAnnotations: annotationsToRemove];
    
    latNum = [latFromCity doubleValue];
    lngNum = [lonFromCity doubleValue];
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(latNum, lngNum);
    
    MKCoordinateSpan span;
    span.latitudeDelta=0.55;
    span.longitudeDelta=0.55;
    
    MKCoordinateRegion ITRegion = MKCoordinateRegionMake(centerCoord, span);
    ITRegion.span=span;
    
    [self.topMapView setRegion: ITRegion animated: YES];
    
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        
        // once this is done, if you need to you can call
        // some code on a main thread (delegates, notifications, UI updates...)
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [self getFeed:index]; // request listings data
            
            [self.tableViewNode reloadData];
            //           [self hideHudMethod];
                        
        });
    });
    
    // release the dispatch queue
    dispatch_release(jsonParsingQueue);
    

    
    
    NSLog(@"self.listingNodesArray %@ from loadCityMap",self.listingNodesArray);
    
    NSLog(@"self.listingNodesArray  %lu from map", (unsigned long)[self.listingNodesArray count]);
    
    for (int i=0; i<[self.listingNodesArray count]; i++) {
        
        MyAnnotation* annotation= [MyAnnotation new];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [latFromCity doubleValue];
        coordinate.longitude = [lonFromCity doubleValue];
        
        annotation.coordinate = coordinate;
        
        annotation.title = [[self.listingNodesArray objectAtIndex:i] objectForKey:@"title"];
        annotation.subtitle = [[[self.listingNodesArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"address"];
        
        NSNumber *listingIdNumber = [[self.listingNodesArray objectAtIndex:i] objectForKey:@"id"];
        
        annotation.catListingMapId = listingIdNumber;
        
        
        [self.topMapView addAnnotation: annotation];
        [self.topMapView reloadInputViews];
    }
    
    NSLog(@"load map city search called");
}
//

- (void)getFeed:(NSInteger) pageNumber {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    CLLocationCoordinate2D coordinate = [self getLocation];
    currentUserLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    currentUserLongitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSLog(@"curr user latlon from get Feed %@ %@",currentUserLongitude,currentUserLongitude);
    
    if (cellCitySelectedText == nil) {
        NSString *stringWithToken = [NSString stringWithFormat:@"%@&latlng=%@,%@&page=%d&token=%@",kURL,currentUserLatitude,currentUserLongitude,pageNumber,savedValue];
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
        
        [self.listingNodesArray addObjectsFromArray:moreItemsArray];
        
        [self.tableViewNode reloadData];
        
        
    } else {
        
        NSString *stringWithToken = [NSString stringWithFormat:@"%@&city_slug=%@&page=%d&token=%@",kURL,cellCitySelectedText,pageNumber,savedValue];
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
        
       // [self.tableViewNode reloadData];
        
    }
    
    NSLog(@"*dLatitude getfeed: %@", currentUserLatitude);
    NSLog(@"*dLongitude getfeed: %@",currentUserLongitude);
    
    NSLog(@"self.listingNodesArray %@ from loadMap",self.listingNodesArray);
    
    NSLog(@"self.listingNodesArray  %lu from map", (unsigned long)[self.listingNodesArray count]);
    
    
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
        
        categoryIdNumber = [[self.listingNodesArray objectAtIndex:i] objectForKey:@"category_id"];
        
//        annotation.catMapId = categoryIdNumber;
        NSLog(@"annotation.catMapId %@",annotation.catMapId);
        
        
        // All instances of TestClass will be notified
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TestNotification"
         object:self];
        
        [self.topMapView addAnnotation: annotation];
        
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hideHudMethod)
                                   userInfo:nil
                                    repeats:NO];
    
//    if (self.listingNodesArray.count == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results Found Around You" message:@"Please select a city" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [alert show];
//    }

}

- (void)getFeedUserLocation:(NSInteger) pageNumber {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    //   NSLog(@"countpage %d",index);
    // NSString *stringWithToken = [NSString stringWithFormat:@"%@&city_slug=%@&page=%d&token=%@",kURL,cellCitySelectedText, pageNumber,savedValue];
    
    //    currentUserLatitude = @"45.4667";
    //    currentUserLongitude = @"9.1833";
    
    // NSString *cityText = citySearchText;
    
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@&latlng=%@,%@&page=%d&token=%@",kURL,currentUserLatitude,currentUserLongitude,pageNumber,savedValue];
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
    
    
    [self.listingNodesArray addObjectsFromArray:moreItemsArray];
    
    [self.tableViewNode performSelector:@selector(reloadData) withObject:nil afterDelay:0.14];
    
    NSLog(@"*dLatitude getfeed: %@", currentUserLatitude);
    NSLog(@"*dLongitude getfeed: %@",currentUserLongitude);
    
    [self.tableViewNode reloadData];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hideHudMethod)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [locations lastObject];
    
}

-(void)reverseGeoCityToLatLon {
    
    NSString *city = cellCitySelectedText;
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:city completionHandler:^(NSArray *placemarks, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if ([placemarks count] > 0) {
        
        CLPlacemark *placemark = [placemarks lastObject]; // firstObject is iOS7 only.
        NSLog(@"Location is: %f", placemark.location.coordinate.latitude);
        
        latFromCity = [NSString stringWithFormat:@"%f",placemark.location.coordinate.latitude];
        lonFromCity = [NSString stringWithFormat:@"%f",placemark.location.coordinate.longitude];

        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *valueToSaveLat = latFromCity;
        [[NSUserDefaults standardUserDefaults]
         setObject:valueToSaveLat forKey:@"latFromCitySaved"];

        NSString *valueToSaveLon = lonFromCity;
        [[NSUserDefaults standardUserDefaults]
         setObject:valueToSaveLon forKey:@"lonFromCitySaved"];
        [standardUserDefaults synchronize];
        
        
        NSLog(@"Location long from city is: %@", latFromCity);
        NSLog(@"Location long from city is: %@", lonFromCity);

        [self loadMapCitySearch];

        }
    }];
}

#pragma data

-(CLLocationCoordinate2D) getLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
 //   NSString *string = [NSString stringWithFormat:@"coordinate.latitude %f coordinate.longitude%f",coordinate.latitude,coordinate.longitude];
    
   // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
  //  [alert show];
    
    
    NSString *stringLat = [NSString stringWithFormat:@"%f",coordinate.latitude];

    NSString *stringLng = [NSString stringWithFormat:@"%f",coordinate.longitude];

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userLat = stringLat;
    [[NSUserDefaults standardUserDefaults]
     setObject:userLat forKey:@"userLat"];

    NSString *userLng = stringLng;
    [[NSUserDefaults standardUserDefaults]
     setObject:userLng forKey:@"userLng"];
    
    [standardUserDefaults synchronize];
    
    
    NSLog(@"coordinate.latitude and coordinate.lon from getloation%f %f",coordinate.latitude,coordinate.latitude);
    return coordinate;
}

-(void) hideHudMethod {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)scrollViewDidEndDecelerating: (UIScrollView*)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (self.tableViewNode == scrollView) {
        {
    if (scrollOffset == 0)
        
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        
        // then we are at the end
        index ++;
        [self getFeed:index];
        [self loadMap];

    }
            
        }
    }
    
    if (self.tableViewCities == scrollView) {
        {
            if (scrollOffset == 0)
            {
                // then we are at the top
            }
            else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
            {
               
                
            }
            
        }
    }
}

- (void) citySearchArrayMethod {
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@&token=%@",kCityURL, savedValue];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:stringWithToken]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    
    NSError *jsonParsingError = nil;
    
    if (requestError) {
        NSLog(@"sync. request failed with error: %@", requestError);
    }
    
    else {
        
        // handle data
        self.publicDataCityArray =  [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
        
        myDictionary = [[self.publicDataCityArray valueForKey:@"data"] valueForKey:@"name"];
        
      //  NSLog(@"myDictionary is %@ myDictionary count is %i",   myDictionary,  [myDictionary count]);
        
    }

}

- (void) reloadTableData {
    
    [self.tableViewNode setContentOffset:CGPointMake(0.0f, -self.tableViewNode.contentInset.top) animated:YES];
        
    [UIView animateWithDuration:0.1 animations:^{
        
        [self.tableViewNode performSelector:@selector(reloadData) withObject:nil afterDelay:0.14];
        
        [HUD hide:YES];
        
        NSLog(@"reload data called");
    }];
}

#pragma search delegate methods
- (void)searchBarSearchButtonClicked:(NSString *)searchbar {
    
    [self citySearchArrayMethod];
    
    [searchBar resignFirstResponder];
    
    NSLog(@"citySearchText is %@",citySearchText);
    
    cellCitySelectedText = citySearchText;
    
    [self getFeed:index];
    [self reloadTableData];
    [self.tableViewNode setContentOffset:CGPointMake(0, ([self.listingNodesArray count]-10)*200) animated:YES];
    
    
   // [self citySearchQueryFromUser];
    
    [self hideCityDropDownTable];
}

- (void)citySearchQueryFromUser {
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        
    NSString *stringWithToken = [NSString stringWithFormat:@"%@&city_slug=%@&token=%@",kURL,citySearchText,savedValue];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:stringWithToken]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    
    NSError *jsonParsingError = nil;
    
    if (requestError) {
        NSLog(@"sync. request failed with error: %@", requestError);
    }
    
    else {
        
        // handle data
        self.publicDataCityArray =  [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
        
        myDictionary = [[self.publicDataCityArray valueForKey:@"data"] valueForKey:@"name"];
        
      //  NSLog(@"myDictionary is %@ myDictionary count is %i",   myDictionary,  [myDictionary count]);
        
    }
    
    [self.tableViewCities reloadData];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchbar {
	searchBar.text = nil;

    [self hideCityDropDownTable];
    
    searchBar.frame = CGRectMake(0.0, 0.0, 190.0, 44.0);

    //  NSLog(@"button touched cancel search");
	
    //	[self filterContent:searchBar.text];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [searchBar resignFirstResponder];
    
    qrBarBtn.hidden = NO;

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchbar {
	
    [self slideDownTableView];

    searchBar.showsScopeBar = YES;
	[searchBar sizeToFit];
    
	[searchBar setShowsCancelButton:YES animated:YES];
    
    qrBarBtn.hidden = YES;
    
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar {
	searchBar.showsScopeBar = NO;
	[searchBar sizeToFit];
    
	[searchBar setShowsCancelButton:NO animated:YES];
    
    searchBar.frame = CGRectMake(0.0, 0.0, 190.0, 44.0);

	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        
    self.searchBar.text = searchText;
    
    citySearchText = searchText;

}

#pragma mark - UITableView methods

//Change the Height of the Cell [Default is 45]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([tableView isEqual:self.tableViewNode])
    {
        return 200;
    }
    if ([tableView isEqual:self.tableViewCities])
    {
        return 40;
    }
    else
    {
        return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.tableViewNode])
    {
        return [self.listingNodesArray count];
    }
    if ([tableView isEqual:self.tableViewCities])
    {
        return [myDictionary count];
    }
    
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([tableView isEqual:self.tableViewNode])
    {
        return 1;
    }
    if ([tableView isEqual:self.tableViewCities])
    {
        return 1;
    }
    
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([tableView isEqual:self.tableViewCities]){
        
        static NSString *simpleTableIdentifier = @"tableViewCitiesIdentifier";
        
        self.tableViewCities.backgroundColor = [UIColor whiteColor];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
      
            cell.textLabel.font = [UIFont fontWithName:@"DIN-Bold" size:12];

        }
        
        cell.textLabel.text = [myDictionary objectAtIndex:indexPath.row];

        return cell;
    }
    
    if([tableView isEqual:self.tableViewNode]){

        static NSString *simpleTableIdentifier = @"ComprareTableCell";
        
        ComprareTableCell *cell = (ComprareTableCell *)[self.tableViewNode dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        self.tableViewNode.backgroundColor = customColorLightGrey;
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ComprareTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];

        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
        separatorLineView.backgroundColor = customColorIt;
        [cell.contentView addSubview:separatorLineView];
      
        cell.nameLabel.font = [UIFont fontWithName:@"DIN-Bold" size:12];
        cell.tableTextViewLbl.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        cell.separator.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        
        // count labels
        cell.commentCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        cell.likeCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
        cell.geoTagCountLabel.font = [UIFont fontWithName:@"DIN-Regular" size:10];
       
    }
    
    if([tableView isEqual:self.tableViewNode]){
        NSString *uppercaseTitle =   [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        NSString *uppercase = [uppercaseTitle uppercaseString];
        
        cell.nameLabel.text = uppercase;

    }
    else if([tableView isEqual:self.tableViewCities]){
        cell.nameLabel.text = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"title"];

    }
    
    // cell title and subtitle

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
    
    
        
    NSNumber *catId = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"category_id"];
        
        uC = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_comments"];
        uL = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_likes"];
        uG = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"user_checkins"];
      
        int a = [uC integerValue];
        int b = [uL integerValue];
        int c = [uG integerValue];
        
        NSLog(@"catid is %@",catId);
    
    if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (a == 0)) {
       
            cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];
        
           cell.salvaBtnImage.image = [UIImage imageNamed:@"home_verde_commentsOFF.png"];
    }
        
     else if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (a != 0)) {
         
         cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];
                        
         cell.salvaBtnImage.image = [UIImage imageNamed:@"home_verde_commentsOFF.png"];
         
    }
        
        
     if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (b == 0)) {
         cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];

         cell.likeBtnImage.image = [UIImage imageNamed:@"home_verde_likeOFF.png"];
         
     }
     
     else if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (b != 0)) {
         cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];

         cell.likeBtnImage.image = [UIImage imageNamed:@"home_verde_likeON.png"];
     }
     
        
     if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (c == 0)) {
         cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];

         cell.geoBtnImage.image = [UIImage imageNamed:@"home_verde_geotagOFF.png"];
     }
     
     
     else if ([catId isEqualToNumber:[NSNumber numberWithInt:9]] && (c != 0)) {
         cell.cornerImageView.image = [UIImage imageNamed:@"cellComprareCorner.png"];

         cell.geoBtnImage.image = [UIImage imageNamed:@"home_verde_geotagOFF.png"];

     }

    //10
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (a == 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellBlueCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_giallo_commentsOFF.png"]; 

       }
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (a != 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellMangiareCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_giallo_commentsON.png"];   
        }
        
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (b == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellMangiareCorner.png"];

            cell.likeBtnImage.image = [UIImage imageNamed:@"home_giallo_likeOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (b != 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellMangiareCorner.png"];

            cell.likeBtnImage.image = [UIImage imageNamed:@"home_giallo_likeON.png"];
        }

        if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (c == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellMangiareCorner.png"];

            cell.geoBtnImage.image = [UIImage imageNamed:@"home_giallo_geotagOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:10]] && (c != 0)) {

            cell.cornerImageView.image = [UIImage imageNamed:@"cellMangiareCorner.png"];
            
            cell.geoBtnImage.image = [UIImage imageNamed:@"home_giallo_geotagON.png"];
        }

        //11
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (a == 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_rosso_commentsOFF.png"];
            
        }
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (a != 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_rosso_commentsON.png"];
        }
        
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (b == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.likeBtnImage.image = [UIImage imageNamed:@"home_rosso_likeOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (b != 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.likeBtnImage.image = [UIImage imageNamed:@"home_rosso_likeON.png"];
        }
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (c == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.geoBtnImage.image = [UIImage imageNamed:@"home_rosso_geotagOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:11]] && (c != 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVisitareCorner.png"];
            
            cell.geoBtnImage.image = [UIImage imageNamed:@"home_rosso_geotagON.png"];
        }
        
        
      //12
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (a == 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_blu_commentsOFF.png"];
            
        }
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (a != 0)) {
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.salvaBtnImage.image = [UIImage imageNamed:@"home_blu_commentsON.png"];
        }
        
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (b == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.likeBtnImage.image = [UIImage imageNamed:@"home_blu_likeOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (b != 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.likeBtnImage.image = [UIImage imageNamed:@"home_blu_likeON.png"];
        }
        
        if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (c == 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.geoBtnImage.image = [UIImage imageNamed:@"home_blu_geotagOFF.png"];
        }
        
        
        else if ([catId isEqualToNumber:[NSNumber numberWithInt:12]] && (c != 0)) {
            
            cell.cornerImageView.image = [UIImage imageNamed:@"cellVivereCorner.png"];
            
            cell.geoBtnImage.image = [UIImage imageNamed:@"home_blu_geotagON.png"];
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
                    
                    ComprareTableCell *updateCell = (ComprareTableCell *)[self.tableViewNode cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        cell.thumbnailImageView.image = image;
                    
                }];
            }
        }];
    }
    
    return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 //   NSLog(@"Row selected: %d",indexPath.row);
    
    if([tableView isEqual:self.tableViewCities]){

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cellCitySelectedText = cell.textLabel.text;
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *valueToSave = cellCitySelectedText;
        [[NSUserDefaults standardUserDefaults]
         setObject:valueToSave forKey:@"cellCitySelectedTextSaved"];
        
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CitySelected"];
        
        [standardUserDefaults synchronize];
        
        NSLog(@"city selected is %@",cellCitySelectedText);

        [self getFeed:index]; // request listings data
        [self reloadTableData];
        [self.tableViewNode setContentOffset:CGPointMake(0, ([self.listingNodesArray count]-10)*200) animated:YES];

        [self hideCityDropDownTable];
        
        [self reverseGeoCityToLatLon];

        
    } else if ([tableView isEqual:self.tableViewNode]){

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
    [self.tableViewNode deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    detailViewController.listingId = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"id"];

    detailViewController.catId = [[self.listingNodesArray objectAtIndex:indexPath.row] objectForKey:@"category_id"];

    [self.navigationController pushViewController:detailViewController animated:YES];
        
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
        });
    }

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
        
        MyAnnotation* annotation= [MyAnnotation new];
        
        annotation.catMapId = categoryIdNumber;
        NSLog(@"annotation.catMapId %@",annotation.catMapId);
        
            
            if (annotation.catMapId == [NSNumber numberWithInt:9]) {
                annView.image = [UIImage imageNamed:@"PIN_comprare.png"];
                
            }
            
            if (annotation.catMapId == [NSNumber numberWithInt:10]) {
                annView.image = [UIImage imageNamed:@"PIN_mangiare.png"];
                
            }
            
            if (annotation.catMapId == [NSNumber numberWithInt:11]) {
                annView.image = [UIImage imageNamed:@"PIN_visitare.png"];
                
            }
            
            if (annotation.catMapId == [NSNumber numberWithInt:12]) {
                annView.image = [UIImage imageNamed:@"PIN_vivere.png"];
                
            }
     
        annView.canShowCallout = YES;
        
    }
    
    return annView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
  	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
  	MyAnnotation *theAnnotation = (MyAnnotation *) pin.annotation;
    
    detailViewController.listingId = [theAnnotation.catListingMapId stringValue];
    
    detailViewController.catId = [theAnnotation.catMapId stringValue];
        
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
    
    self.topMapView.frame = CGRectMake(0,-75,320,160);
    
    [UIView commitAnimations];
        
    mapCloseButton.hidden = YES;
    mapLaunchButton.enabled = YES;
        
    // add map launch button
    mapLaunchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapLaunchButton addTarget:self
                        action:@selector(mapDetailViewDisplay:)
              forControlEvents:UIControlEventTouchDown];
    [mapLaunchButton setTitle:@"" forState:UIControlStateNormal];
    mapLaunchButton.frame = CGRectMake(0, -75.0, 320.0, 150.0);
    mapLaunchButton.backgroundColor = [UIColor clearColor];
    mapLaunchButton.titleLabel.textColor = [UIColor colorWithRed:(240/255.0) green:(229/255.0) blue:(225/255.0) alpha:1];
    mapLaunchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [mapLaunchButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    [self.view addSubview:mapLaunchButton];
    
    self.topMapView.zoomEnabled = NO;
    self.topMapView.scrollEnabled = NO;
    self.topMapView.userInteractionEnabled = NO;
    
}

#pragma mark - Left and Right menu swipe methods

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

- (void)userLocationFind {
    
    if (locationManager.location == nil)
    {
        NSLog(@"user location not found yet or service disabled/denied");
    }
    else
    {
        // Change map center (preserving current zoom level)...
        [self.topMapView setCenterCoordinate:locationManager.location.coordinate animated:YES];
        NSLog(@"user location was found ");
    
      //  [self getFeed:index];
    //  [self getFeedUserLocation:index];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"CitySelected"];
        
    CLLocation* currentLocation = [locationManager location];
    
    NSString *loc = [NSString stringWithFormat:@"%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSLog(@"location from loc btn touch:%@", loc);
    
    NSString *curLat = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    NSString *curLon = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];

    currentUserLatitude = curLat;
    currentUserLongitude = curLon;
    
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *clearSavedCity = @"";
        [[NSUserDefaults standardUserDefaults]
         setObject:clearSavedCity forKey:@"cellCitySelectedTextSaved"];
      
        [standardUserDefaults synchronize];

        
  //  [self getFeed:index];
        [self getFeedUserLocation:index];
        
        [self.topMapView setShowsUserLocation:YES];
        [self.topMapView reloadInputViews];
        
    }
    
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
    
    leftBarButton.hidden = YES;
    
    [super viewWillDisappear:YES];
    
}

- (void)slideDownTableView {
    
    if (!cityTableOpen) {
        
        [self.view addSubview:myview];
        myview.frame = CGRectMake(10, 0,300,-180); // somewhere offscreen, in the direction you want it to appear from
        [UIView animateWithDuration:0.05
                         animations:^{
                             myview.frame = CGRectMake(10, 0,300,180); // its final location
                         }];
        
    }
    
}

-(void)hideCityDropDownTable {
    
    [UIView animateWithDuration:0.01
                     animations:^{
                         myview.frame = CGRectMake(10, 0,300,-180); // move city tableview up and hide
                     }];
    
    qrBarBtn.hidden = NO;
    
    [searchBar resignFirstResponder];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

@end
