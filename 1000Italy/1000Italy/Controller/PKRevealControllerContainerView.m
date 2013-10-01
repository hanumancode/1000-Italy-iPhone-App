
#import "PKRevealControllerContainerView.h"

@interface PKRevealControllerContainerView()

#pragma mark - Properties
@property (nonatomic, assign, readwrite, getter = hasShadow) BOOL shadow;

@end

@implementation PKRevealControllerContainerView

#pragma mark - Initialization

- (id)initForController:(UIViewController *)controller
{
    return [self initForController:controller shadow:NO];
}

- (id)initForController:(UIViewController *)controller shadow:(BOOL)hasShadow
{
    self = [super initWithFrame:controller.view.bounds];
    
    if (self != nil)
    {
        self.viewController = controller;
        if (hasShadow)
        {
            [self setupShadow];
        }
        self.shadow = hasShadow;
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupShadow
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Layouting

- (void)layoutSubviews
{
    [super layoutSubviews];
    // layout controller view
    self.viewController.view.frame = self.viewController.view.bounds;
    
}

- (void)refreshShadowWithAnimationDuration:(NSTimeInterval)duration
{
    UIBezierPath *existingShadowPath = [UIBezierPath bezierPathWithCGPath:self.layer.shadowPath];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    if (existingShadowPath != nil)
    {
        CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        transition.fromValue = (__bridge id)(existingShadowPath.CGPath);
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = duration;
    
        [self.layer addAnimation:transition forKey:@"transition"];
    }
}

#pragma mark - Accessors

- (void)setViewController:(UIViewController *)controller
{
    if (_viewController != controller)
    {
        [_viewController.view removeFromSuperview];
        _viewController = controller;
        _viewController.view.frame = _viewController.view.bounds;
        [self addSubview:_viewController.view];
    }
}

#pragma mark - API

- (void)enableUserInteractionForContainedView
{
    [self.viewController.view setUserInteractionEnabled:YES];
}

- (void)disableUserInteractionForContainedView
{
    [self.viewController.view setUserInteractionEnabled:NO];
}

@end