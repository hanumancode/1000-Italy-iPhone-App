//
//  MapViewAnnotation.m
//  1000 Italy
//
//  Created by GJ on 05/09/2013.
//  Copyright (c) 2013 vitzu.com. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {

	title = ttl;
	coordinate = c2d;
	return self;
}


@end