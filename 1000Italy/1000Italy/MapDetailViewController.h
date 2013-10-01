//
//  MapDetailViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 31/05/2013.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"

@interface MapDetailViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate> {
    
    
    CLLocationManager *locationManager;
    IBOutlet MKMapView *mapView;

}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSNumber *latStr;
@property (nonatomic, retain) NSNumber *lngStr;

@end
