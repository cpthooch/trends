//
//  MediaItemViewController.m
//  Trends
//
//  Created by Alex Malkoff on 19.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "MediaItemViewController.h"
#import "MediaItem.h"
#import "ZoomingTransitionAnimator.h"

@interface MediaItemViewController () <ZoomingTransitionSourceController, ZoomingTransitionTargetController>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation MediaItemViewController {
    CADisplayLink *_activeDisplayLink;
}

- (void) _loadImage {
    if (!self.mediaItem.photo.image) {
        @weakify(self);
        [self.mediaItem.photo loadImageWithCompletion:^(UIImage *image, NSError *error) {
            @strongify(self);
            if (!error) {
                [self _updateImage:image];
            }
            else {
                [self _loadImage];
            }
        }];
    }
}

- (void) _updateImage:(UIImage *)image {
    [self.indicatorView stopAnimating];
    _activeDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateViewImageWithFade)];
    [_activeDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) _updateViewImageWithFade {
    [_activeDisplayLink invalidate];
    _activeDisplayLink = nil;
    
    UIImageView *snapshot = (id)[self.imageView snapshotViewAfterScreenUpdates:NO];
    [self.imageView.superview insertSubview:snapshot belowSubview:self.imageView];
    snapshot.frame = self.imageView.frame;
    
    self.imageView.alpha = 0.;
    self.imageView.image = self.mediaItem.photo.image;
    
    [UIView animateWithDuration:1. delay:0. options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.imageView.alpha = 1.;
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.authorLabel.text = self.mediaItem.userFullName;
    self.messageLabel.text = self.mediaItem.captionText;
    self.imageView.image = self.mediaItem.thumbnail.image;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mediaItem.photo.image) {
        [self.indicatorView stopAnimating];
        [self _updateImage:self.mediaItem.photo.image];
    }
    else {
        [self.indicatorView startAnimating];
        [self _loadImage];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mediaItem.photo cancelLoading];
}

#pragma mark - UIGestureRecognizer

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}

#pragma mark - ZoomingTransition

- (UIView *) zoomingTransitionSourceView {
    return self.imageView;
}

- (UIColor *) zoomingTransitionFadeColor {
    return [UIColor extra_colorWithHex:0xfafafa];
}

- (id<UIViewControllerInteractiveTransitioning>) interactiveTransition {
    return nil;
    //    return self.interactivePopTransition;
}

- (UIView *) zoomingTransitionTargetView {
    return [self zoomingTransitionSourceView];
}

- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator aboutToAnimate:(UIView *)view {
    self.imageView.hidden = YES;
}

- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator didAnimate:(UIView *)view {
    self.imageView.hidden = NO;
}


@end
