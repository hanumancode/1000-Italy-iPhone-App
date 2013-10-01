//
//  SimpleTableCell.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell
@synthesize nameLabel = _nameLabel;
@synthesize tableTextViewLbl = _tableTextViewLbl;
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize timeStampLabel = _timeStampLabel;
@synthesize userSubmittedImageView = _userSubmittedImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
     
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure view for the selected state
}

@end
