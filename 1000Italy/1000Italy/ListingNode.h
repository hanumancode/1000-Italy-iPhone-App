

#import <Foundation/Foundation.h>

@interface ListingNode : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSNumber *geoCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSString *catId;
@property (nonatomic, strong) NSString *listingId;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSArray *tags;

// Designated Initializer
- (id) initWithTitle:(NSString *)title;
+ (id) listingNodeWithTitle:(NSString *)title;

- (NSURL *) thumbnailURL;
- (NSString *) formattedDate;

@end
