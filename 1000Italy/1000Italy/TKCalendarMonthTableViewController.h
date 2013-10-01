//
//  TKCalendarMonthTableViewController.h
//  Created by Devin Ross on 10/31/09.

#import <UIKit/UIKit.h>
#import "TKCalendarMonthViewController.h"

@interface TKCalendarMonthTableViewController : TKCalendarMonthViewController <UITableViewDelegate, UITableViewDataSource>  {
	UITableView *_tableView;
}
@property (retain,nonatomic) UITableView *tableView;
- (void) updateTableOffset:(BOOL)animated;
@end
