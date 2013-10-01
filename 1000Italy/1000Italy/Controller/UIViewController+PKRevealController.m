

#import "UIViewController+PKRevealController.h"
#import "PKRevealController.h"
#import <objc/runtime.h>

@implementation UIViewController (PKRevealController)

static char revealControllerKey;

- (void)setRevealController:(PKRevealController *)revealController
{
    objc_setAssociatedObject(self, &revealControllerKey, revealController, OBJC_ASSOCIATION_ASSIGN);
}

- (PKRevealController *)revealController
{
    return (PKRevealController *)objc_getAssociatedObject(self, &revealControllerKey);
}

@end
