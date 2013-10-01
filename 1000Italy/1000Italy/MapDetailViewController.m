//
//  MapDetailViewController.m
//  1000 Italy
//
//  Created by Gareth Jones on 31/05/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "MapDetailViewController.h"
#import "DisplayMap.h"

#define METERS_PER_MILE 1609.344

@interface MapDetailViewController ()

@end

@implementation MapDetailViewController

@synthesize mapView,latStr,lngStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [latStr doubleValue];
    zoomLocation.longitude= [lngStr doubleValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.8*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    
    [mapView setRegion:viewRegion animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self.mapView setShowsUserLocation:YES];
    
    MKCoordinateRegion region;
    region.center.latitude = [latStr doubleValue];
    region.center.longitude = [lngStr doubleValue];
    
    DisplayMap *ann = [[DisplayMap alloc] init];
    ann.title=@"put 1000 IT title here";
    ann.coordinate = region.center;
    [mapView addAnnotation:ann];
    
    self.mapView.delegate = self;
    
    NSLog(@"%@ latstr", self.latStr);
    NSLog(@"%@ latstr", self.latStr);
        
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    else {
        [mapView.userLocation setTitle:@"Current Location"];
    }
    return pinView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
