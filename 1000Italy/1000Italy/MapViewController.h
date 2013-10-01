//
//  MapViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 29/05/2013.
//  Copyright (c) 2013  Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <UIApplicationDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate> {
    
    CLLocationManager *locationManager;
    IBOutlet MKMapView *mapView;

    NSMutableArray *publicDataArray;
    NSDictionary *publicDataDict;
    MKAnnotationView *annView;
    
    // lat and lng doubles
    double latNum;
    double lngNum;
    
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;

@end