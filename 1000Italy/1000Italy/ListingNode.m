

#import "ListingNode.h"

@implementation ListingNode

- (id) initWithTitle:(NSString *)title {
    self = [super init];
    
    if ( self ){
        self.title = title;
        self.subTitle = nil;
        self.thumbnail = nil;
        self.geoCount = nil;
        self.tags = nil;
        self.url = nil;
        self.likeCount = nil;
        self.catId = nil;
        self.commentCount = nil;
        self.listingId = nil;
        self.cityName = nil;

    }
    
    return self;
}

+ (id) listingNodeWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}

- (NSURL *) thumbnailURL {
//    NSLog(@"%@",[self.thumbnail class]);
    return [NSURL URLWithString:self.thumbnail];
}


- (NSString *) formattedDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tempDate = [dateFormatter dateFromString:self.date];
    
    [dateFormatter setDateFormat:@"EE MMM,dd"];
    return [dateFormatter stringFromDate:tempDate];
    
}






@end
