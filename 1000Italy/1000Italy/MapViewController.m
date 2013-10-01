//
//  MapViewController.m
//  1000 Italy
//
//  Created by Gareth Jones on 29/05/2013.
//  Copyright (c) 2013  Vitzu Ltd. All rights reserved.
//

#import "MapViewController.h"
#import "MyAnnotation.h"
#import "DetailViewController.h"
#import "SIAlertView.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)requestData {
    
    NSError *requestError = nil;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"token"];
    
    NSString *stringWithToken = [NSString stringWithFormat:@"%@&%@&token=%@",kURL,city_slug, savedValue];

    NSLog(@"string token is %@", stringWithToken);
    
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // request data method on view did load
    [self requestData];

     // map lat lng
    latNum = [[[[publicDataArray objectAtIndex:2] objectForKey:@"address"] objectForKey:@"lat"] doubleValue];
    lngNum = [[[[publicDataArray objectAtIndex:2] objectForKey:@"address"] objectForKey:@"lng"] doubleValue];
    
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(latNum, lngNum);
    
    MKCoordinateSpan span;
    span.latitudeDelta=0.05;
    span.longitudeDelta=0.05;
    
    MKCoordinateRegion ITRegion = MKCoordinateRegionMake(centerCoord, span);
    ITRegion.span=span;
    
    [mapView setRegion: ITRegion animated: YES];
	 
    // set map delegate
	mapView.delegate=self;
	
    // sho user location
    [self.mapView setShowsUserLocation:YES];

    
    for (int i=0; i<[publicDataArray count]; i++) {
        MKPointAnnotation* annotation= [MKPointAnnotation new];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[[publicDataArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"lat"] doubleValue];
        coordinate.longitude = [[[[publicDataArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"lng"] doubleValue];

        NSString *catId = [NSString stringWithFormat:@"%@",[[publicDataArray objectAtIndex:i] objectForKey:@"category_id"]];
        
        if ([catId isEqual: @"9"]) {
            annView.image = [UIImage imageNamed:@"PIN_comprare.png"];//sets image for pin

        } else if ([catId isEqual:@"10"]) {
            
            annView.image = [UIImage imageNamed:@"PIN_mangiare.png"];//sets image for pin
            
        } else if ([catId isEqual:@"11"]) {
            
            annView.image = [UIImage imageNamed:@"PIN_visitare.png"];//sets image for pin
            
        } else  if ([catId isEqualToString:@"12"]){
            
            annView.image = [UIImage imageNamed:@"PIN_vivere.png"];//sets image for pin
            
        }
        
        annotation.coordinate = coordinate;

        annotation.title = [[publicDataArray objectAtIndex:i] objectForKey:@"title"];
        annotation.subtitle = [[[publicDataArray objectAtIndex:i] objectForKey:@"address"] objectForKey:@"address"];
        
        [mapView addAnnotation: annotation];

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
        [rightButton addTarget:self
                        action:@selector(showDetails:)
              forControlEvents:UIControlEventTouchUpInside];
        annView.rightCalloutAccessoryView = rightButton;
        
        annView.canShowCallout = YES;
        
        
    }
    return annView;
}

id observer1,observer2,observer3,observer4;

-(IBAction)showDetails:(id)sender{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Show Map Details Temp Alert"];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
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
                                                                  //        NSLog(@"%@, -willShowHandler3", alertView);
                                                              }];
    observer2 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidShowNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //       NSLog(@"%@, -didShowHandler3", alertView);
                                                             }];
    observer3 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //       NSLog(@"%@, -willDismissHandler3", alertView);
                                                             }];
    observer4 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 //      NSLog(@"%@, -didDismissHandler3", alertView);
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer1];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer2];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer3];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer4];
                                                                 
                                                                 observer1 = observer2 = observer3 = observer4 = nil;
                                                             }];
    
    [alertView show];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

