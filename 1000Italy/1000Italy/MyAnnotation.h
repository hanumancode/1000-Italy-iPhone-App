//
//  MyAnnotation.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation> {
	
	CLLocationCoordinate2D	coordinate;
	NSString*				title;
	NSString*				subtitle;
    NSNumber *latString;
    NSNumber *lngString;
    
    NSNumber *catMapId;
    NSNumber *catListingMapId;

}

@property (nonatomic, assign)	CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString*				title;
@property (nonatomic, copy)		NSString*				subtitle;

@property (nonatomic,copy) NSNumber *latString;
@property (nonatomic,copy) NSNumber *lngString;
@property (nonatomic,copy) NSNumber *catMapId;
@property (nonatomic,copy) NSNumber *catListingMapId;

@end
