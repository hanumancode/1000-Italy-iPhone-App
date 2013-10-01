//
//  DaterViewController.m
//  Created by Devin Ross on 7/28/09.
//

#import "TKCalendarMonthViewController.h"
#import "TKCalendarMonthView.h"


@implementation TKCalendarMonthViewController
@synthesize monthView = _monthView;

- (id) init{
	return [self initWithSunday:YES];
}
- (id) initWithSunday:(BOOL)sundayFirst{
	if(!(self = [super init])) return nil;
	_sundayFirst = sundayFirst;
	return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void) viewDidUnload {
	self.monthView.delegate = nil;
	self.monthView.dataSource = nil;
	self.monthView = nil;
}
- (void) dealloc {
	self.monthView.delegate = nil;
	self.monthView.dataSource = nil;
	self.monthView = nil;
    [super dealloc];
}


- (void) loadView{
	[super loadView];
	
	_monthView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:_sundayFirst];
	_monthView.delegate = self;
	_monthView.dataSource = self;
	[self.view addSubview:_monthView];
	[_monthView reload];
	
}


- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	return nil;
	
}


@end
