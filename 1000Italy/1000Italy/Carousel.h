//
//  Carousel.h
//  1000 Italy
//
//  Created by Gareth Jones on 24/06/2013.
//  Copyright (c) 2013 zuui.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Carousel : UIView <UIScrollViewDelegate>
{
    UIPageControl *pageControl;
    NSArray *images;
}

@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSArray *images;

- (void)setup;

@end