//
//  CommentTableCell.h
//  ExpandingTableViewProject
//
//  Created by Gareth Jones on 18/07/2013.
//

#import <UIKit/UIKit.h>


@interface CommentTableCell : UITableViewCell {
    
    IBOutlet UILabel *commentTextLabel;

    IBOutlet UILabel *titleTextLabel;
    IBOutlet UIImageView *tableImage;
}

@property(nonatomic,retain)IBOutlet UILabel *commentTextLabel;
@property (nonatomic,retain) IBOutlet UILabel *titleTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *tableImage;

@end
