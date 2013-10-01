

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PKRevealControllerContainerView : UIView

#pragma mark - Properties
@property (nonatomic, weak, readwrite) UIViewController *viewController;

#pragma mark - Methods
- (id)initForController:(UIViewController *)controller;
- (id)initForController:(UIViewController *)controller shadow:(BOOL)hasShadow;

- (void)enableUserInteractionForContainedView;
- (void)disableUserInteractionForContainedView;

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration;

- (BOOL)hasShadow;

@end