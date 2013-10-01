//
//  CommentTableCell.m
//  ExpandingTableViewProject
//
//  Created by Gareth Jones on 18/07/2013.
//

#import "CommentTableCell.h"


@implementation CommentTableCell

@synthesize commentTextLabel, titleTextLabel,tableImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
