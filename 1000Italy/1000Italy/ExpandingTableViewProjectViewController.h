//
//  ExpandingTableViewProjectViewController.h
//  ExpandingTableViewProject
//
//  Created by Gareth Jones on 18/07/2013.
//

#import <UIKit/UIKit.h>

@interface ExpandingTableViewProjectViewController : UIViewController <UITableViewDelegate> {
   
    UILabel *tlabel;

    //This array will store our coments
    NSMutableArray *textArray;
    NSMutableArray *titleArray;

    
    //This is the index of the cell which will be expanded
    NSInteger selectedIndex;
}

@end

