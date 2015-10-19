//
//  ZoomingTransitionAnimator.h
//  Trends
//
//  Created by Alex Malkoff on 17.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZoomingTransitionAnimator;


@protocol ZoomingTransitionDelegate <NSObject>

@optional
- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator aboutToAnimate:(UIView *)view;
- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator didAnimate:(UIView *)view;

@end


@protocol ZoomingTransitionSourceController <ZoomingTransitionDelegate>

- (UIView *) zoomingTransitionSourceView;
- (UIColor *) zoomingTransitionFadeColor;

@optional
- (id<UIViewControllerInteractiveTransitioning>) interactiveTransition;

@end


@protocol ZoomingTransitionTargetController <ZoomingTransitionDelegate>

- (UIView *) zoomingTransitionTargetView;

@end


@interface ZoomingTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, getter=isBackward) BOOL backward;

@property (nonatomic, weak) id<ZoomingTransitionSourceController> sourceController;
@property (nonatomic, weak) id<ZoomingTransitionTargetController> targetController;

@property (nonatomic, readonly) id<UIViewControllerInteractiveTransitioning> interactiveTransition;

@end
