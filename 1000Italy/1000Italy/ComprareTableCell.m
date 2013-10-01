//
//  ComprareTableCell.m
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import "ComprareTableCell.h"

@implementation ComprareTableCell

@synthesize nameLabel = _nameLabel;
@synthesize tableTextViewLbl = _tableTextViewLbl;
@synthesize thumbnailImageView = _thumbnailImageView;

@synthesize commentCountLabel = _commentCountLabel;
@synthesize likeCountLabel = _likeCountLabel;

@synthesize cornerImageView = _cornerImageView;

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

    // Configure the view for the selected state
}

@end
