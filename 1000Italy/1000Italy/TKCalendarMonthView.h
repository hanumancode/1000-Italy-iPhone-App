//
//  TKCalendarMonthView.h
//  Created by Devin Ross on 6/10/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class TKCalendarMonthTiles;
@protocol TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource;


@interface TKCalendarMonthView : UIView {

	TKCalendarMonthTiles *currentTile,*oldTile;
	UIButton *leftArrow, *rightArrow;
	UIImageView *topBackground, *shadow;
	UILabel *monthYear;
	UIScrollView *tileBox;
	BOOL sunday;

	id <TKCalendarMonthViewDelegate> delegate;
	id <TKCalendarMonthViewDataSource> dataSource;

}
- (id) initWithSundayAsFirst:(BOOL)sunday; // or Monday

@property (nonatomic,assign) id <TKCalendarMonthViewDelegate> delegate;
@property (nonatomic,assign) id <TKCalendarMonthViewDataSource> dataSource;

- (NSDate*) dateSelected;
- (NSDate*) monthDate;
- (void) selectDate:(NSDate*)date;
- (void) reload;

@end


@protocol TKCalendarMonthViewDelegate <NSObject>
@optional
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date;
- (BOOL) calendarMonthView:(TKCalendarMonthView*)monthView monthShouldChange:(NSDate*)month animated:(BOOL)animated;
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthWillChange:(NSDate*)month animated:(BOOL)animated;
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month animated:(BOOL)animated;
@end

@protocol TKCalendarMonthViewDataSource <NSObject>
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
@end