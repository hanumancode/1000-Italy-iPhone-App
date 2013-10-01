//
//  ManigareViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ComprareTableCell.h"
#import "MBProgressHUD.h"

@interface ManigareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate,MBProgressHUDDelegate> {
    
    // progress HUD
    MBProgressHUD *HUD;
    
    // index int for pagination
    int index;
    
    // map
    CLLocationManager *locationManager;
    IBOutlet MKMapView *topMapView;
    MKAnnotationView *annView;
    
    UIButton *leftBarButton;
    UILabel* tlabel;

    // like and comment images for tableview cells
    UIImageView *imgViewComment;
    UIImageView *imgViewLike;
    UILabel *commentCountLbl;
    UILabel *geoTagCountLbl;
    UILabel *likeCountLbl;
    
    // lat and lng doubles
    double latNumMang;
    double lngNumMang;
    
    // map launch and close button
    UIButton *mapLaunchButton;
    UIButton *mapCloseButton;
    
    UIButton *qrBarBtn;
    NSString *savedCitySelectedValue;
    NSString *latFromCitySaved;
    NSString *lonFromCitySaved;
}

// listing nodes array
@property (nonatomic, strong) NSMutableArray *listingNodesArray;
@property (nonatomic, strong) NSMutableArray *moreItemsArray;

// image download queue
@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;

// tableview
@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;

// mapview
@property (nonatomic,retain) IBOutlet MKMapView *topMapView;

@end



