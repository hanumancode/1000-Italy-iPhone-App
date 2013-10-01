

#import <UIKit/UIKit.h>

@class PKRevealController;

/*
 * This category extends every UIViewController with a revealController property.
 * It can be used in the same way as the navigationController property, thus
 * allowing simple access from all the relevant controllers, to enable quick and
 * easy message forwarding.
 */

@interface UIViewController (PKRevealController)

#pragma mark - Properties
@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end