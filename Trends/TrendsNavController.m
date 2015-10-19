//
//  TrendsNavController.m
//  Trends
//
//  Created by Alex Malkoff on 17.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "TrendsNavController.h"
#import "ZoomingTransitionAnimator.h"

@interface TrendsNavController () <UINavigationControllerDelegate>

@end

@implementation TrendsNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    id <ZoomingTransitionSourceController> source = (id<ZoomingTransitionSourceController>)fromVC;
    id <ZoomingTransitionTargetController> target = (id<ZoomingTransitionTargetController>)toVC;
    if ([source conformsToProtocol:@protocol(ZoomingTransitionSourceController)] &&
        [target conformsToProtocol:@protocol(ZoomingTransitionTargetController)]) {
        ZoomingTransitionAnimator *animator = [[ZoomingTransitionAnimator alloc] init];
        animator.backward = (operation == UINavigationControllerOperationPop);
        animator.sourceController = source;
        animator.targetController = target;
        return animator;
    }
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return [animationController isKindOfClass:ZoomingTransitionAnimator.class]
    ? ((ZoomingTransitionAnimator *) animationController).interactiveTransition : nil;
}


@end
