//
//  DaterViewController.h
//  Created by Devin Ross on 7/28/09.
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthView.h"

@class TKCalendarMonthView;
@protocol TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource;

@interface TKCalendarMonthViewController : UIViewController <TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource> {
	TKCalendarMonthView *_monthView;
	BOOL _sundayFirst;
}

- (id) init;
- (id) initWithSunday:(BOOL)sundayFirst;

@property (retain,nonatomic) TKCalendarMonthView *monthView;


@end

