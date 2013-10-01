//
//  FrontViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface FrontViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate,CLLocationManagerDelegate,MKMapViewDelegate,MBProgressHUDDelegate,UIActionSheetDelegate> {
    
    // progress HUD
    MBProgressHUD *HUD;
     
    // index int for pagination
    int index;
    int indexCity;
    
    // map
    IBOutlet MKMapView *topMapView;
    MKAnnotationView *annView;
    
    // lat and lng doubles
    double latNum;
    double lngNum;
    
    NSNumber *listingIdMap;
    NSNumber *catListingMapId;
    NSNumber *catMapId;
    
    // left bar button item
    UIButton *leftBarButton;
    
    // like and comment images for tableview cells
    UILabel *commentCountLbl;
    UILabel *likeCountLbl;
    UILabel *geoTagCountLbl;
        
    int categoryId;
    
    NSString *citySearchText;
    
    // map launch and close button
    UIButton *mapLaunchButton;
    UIButton *mapCloseButton;
    
    UIButton *qrBarBtn;
    
    NSString *uC;
    NSString *uL;
    NSString *uG;
        
    NSArray *myDictionary;
        
    BOOL cityTableOpen;
    UIView *myview;
    NSString *cellCitySelectedText;
    
    NSString *currentUserLatitude;
    NSString *currentUserLongitude;
    
    NSString *currentStaticLatitude;
    NSString *currentStaticLongitude;
    
    NSString *latFromCity;
    NSString *lonFromCity;
    
    NSNumber *categoryIdNumber;
    
    NSString *savedCitySelectedValue;
    NSString *latFromCitySaved;
    NSString *lonFromCitySaved;
    
    BOOL getFeedRan;
}

@property (strong, nonatomic) CLLocation *selectedLocation;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (strong, nonatomic) NSMutableArray* publicDataCityArray;

// listing nodes array 
@property (nonatomic, strong) NSMutableArray *listingNodesArray;
@property (nonatomic, strong) NSMutableArray *moreItemsArray;

// tableview
@property (nonatomic, retain) IBOutlet UITableView *tableViewNode;
@property (nonatomic, retain) IBOutlet UITableView *tableViewCities;

// search bar
@property(nonatomic, readonly) UISearchBar *searchBar;

// image download queue
@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;

// mapview
@property (nonatomic,retain) IBOutlet MKMapView *topMapView;

@end
