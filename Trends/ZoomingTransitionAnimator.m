//
//  ZoomingTransitionAnimator.m
//  Trends
//
//  Created by Alex Malkoff on 17.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "ZoomingTransitionAnimator.h"

static const NSTimeInterval kForwardAnimationDuration = 0.3;
static const NSTimeInterval kBackwardAnimationDuration = 0.25;

@implementation ZoomingTransitionAnimator

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.isBackward ? kBackwardAnimationDuration : kForwardAnimationDuration;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;

    // being paranoic :)
    if (![self.sourceController conformsToProtocol:@protocol(ZoomingTransitionSourceController)] ||
        ![self.targetController conformsToProtocol:@protocol(ZoomingTransitionTargetController)])
    {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        return;
    }
    
    UIView *faderView = ({
        UIColor *faderColor = self.sourceController.zoomingTransitionFadeColor;
        UIView *view = nil;
        if (![faderColor isEqual:[UIColor clearColor]]) {
            view = [[UIView alloc] initWithFrame:[transitionContext finalFrameForViewController:to]];
            view.backgroundColor = faderColor;
        }
        view;
    });
    
    UIView *animatedView = ({
        UIView *sourceView = self.sourceController.zoomingTransitionSourceView;
        UIView *snapshotView = [sourceView snapshotViewAfterScreenUpdates:NO];
        snapshotView.frame = [containerView convertRect:sourceView.frame fromView:sourceView.superview];
        snapshotView;
    });

    to.view.frame = [transitionContext finalFrameForViewController:to];

    if (self.isBackward) {
        [self _backwardAnimate:animatedView fader:faderView context:transitionContext];
    } else {
        [self _forwardAnimate:animatedView fader:faderView context:transitionContext];
    }
}

- (void) _forwardAnimate:(UIView *)animatedView fader:(UIView *)faderView context:(id<UIViewControllerContextTransitioning>)context {
    UIViewController *to = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = context.containerView;
    
    if (faderView) {
        [containerView addSubview:faderView];
        faderView.alpha = 0;
    }
    to.view.alpha = 0;
    [containerView addSubview:to.view];
    [containerView addSubview:animatedView];
    [containerView layoutIfNeeded];

    [self _aboutToAnimate];
    [UIView animateWithDuration:kForwardAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         faderView.alpha = 0.9;
                         to.view.alpha = 1;
                         UIView *targetView = self.targetController.zoomingTransitionTargetView;
                         CGRect frame = [containerView convertRect:targetView.frame fromView:targetView.superview];
                         animatedView.frame = [self _aspectCorrect:frame sameTo:animatedView.frame];
                     }
                     completion:[self _animationCompletionFor:animatedView fader:faderView context:context]];
}

- (void) _backwardAnimate:(UIView *)animatedView fader:(UIView *)faderView context:(id<UIViewControllerContextTransitioning>)context {
    UIViewController *from = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = context.containerView;

    [containerView insertSubview:to.view belowSubview:from.view];
    if (faderView) {
        [containerView insertSubview:faderView aboveSubview:to.view];
        faderView.alpha = 0.9;
    }
    [containerView addSubview:animatedView];
    [containerView layoutIfNeeded];

    [self _aboutToAnimate];
    [UIView animateWithDuration:kBackwardAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         faderView.alpha = 0;
                         from.view.alpha = 0;
                         UIView *targetView = self.targetController.zoomingTransitionTargetView;
                         CGRect frame = [containerView convertRect:targetView.frame fromView:targetView.superview];
                         animatedView.frame = frame;
                     }
                     completion:[self _animationCompletionFor:animatedView fader:faderView context:context]];
}

- (void(^)(BOOL)) _animationCompletionFor:(UIView *)animatedView fader:(UIView *)faderView context:(id<UIViewControllerContextTransitioning>)context {
    return ^(BOOL finished) {
        [animatedView removeFromSuperview];
        [faderView removeFromSuperview];
        if ([self.sourceController respondsToSelector:@selector(zoomingTransitionAnimator:didAnimate:)]) {
            [self.sourceController zoomingTransitionAnimator:self didAnimate:self.sourceController.zoomingTransitionSourceView];
        }
        if ([self.targetController respondsToSelector:@selector(zoomingTransitionAnimator:didAnimate:)]) {
            [self.targetController zoomingTransitionAnimator:self didAnimate:self.targetController.zoomingTransitionTargetView];
        }
        [context completeTransition:![context transitionWasCancelled]];
    };
}

- (void) _aboutToAnimate {
    if ([self.sourceController respondsToSelector:@selector(zoomingTransitionAnimator:aboutToAnimate:)]) {
        [self.sourceController zoomingTransitionAnimator:self aboutToAnimate:self.sourceController.zoomingTransitionSourceView];
    }
    if ([self.targetController respondsToSelector:@selector(zoomingTransitionAnimator:aboutToAnimate:)]) {
        [self.targetController zoomingTransitionAnimator:self aboutToAnimate:self.targetController.zoomingTransitionTargetView];
    }
}

- (CGRect) _aspectCorrect:(CGRect)frame sameTo:(CGRect)ref {
    CGFloat hratio = frame.size.width / ref.size.width;
    CGFloat vratio = frame.size.height / ref.size.height;
    CGFloat ratio = MIN(hratio, vratio);
    CGFloat w = ref.size.width * ratio;
    CGFloat h = ref.size.height * ratio;
    return CGRectMake(CGRectGetMidX(frame) - w/2., CGRectGetMidY(frame) - h/2., w, h);
}

- (id <UIViewControllerInteractiveTransitioning>) interactiveTransition {
    return [self.sourceController respondsToSelector:@selector(interactiveTransition)] ? [self.sourceController interactiveTransition] : nil;
}

@end
