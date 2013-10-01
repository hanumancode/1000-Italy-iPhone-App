//
//  ComprareTableCell.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComprareTableCell : UITableViewCell

// cell labels
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tableTextViewLbl;
@property (weak, nonatomic) IBOutlet UILabel *separator;

// count labels
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *geoTagCountLabel;

// cell thumb images
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

// corner img view
@property (nonatomic, weak) IBOutlet UIImageView *cornerImageView;

// count imgs
@property (strong, nonatomic) IBOutlet UIImageView *likeBtnImage;
@property (strong, nonatomic) IBOutlet UIImageView *salvaBtnImage;
@property (strong, nonatomic) IBOutlet UIImageView *geoBtnImage;

@end

