//
//  ThumbViewCell.m
//  Trends
//
//  Created by Alex Malkoff on 15.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "ThumbViewCell.h"

@interface ThumbViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end


@implementation ThumbViewCell

- (void) awakeFromNib {
    self.containerView.layer.cornerRadius = 4;
    self.containerView.layer.borderColor = [UIColor extra_colorWithHex:0xe3e3e3].CGColor;
    self.containerView.layer.borderWidth = 1;
    self.containerView.clipsToBounds = YES;
}

- (void) configureShadow {
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:4.0].CGPath;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.cornerRadius = 4.0;
    self.shadowView.layer.shadowRadius = 4.0;
    self.shadowView.layer.shadowOpacity = 0.23;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self configureShadow];
}

- (void) prepareForReuse {
    [self setBusy:NO];
    self.imageView.image = nil;
    self.likesLabel.text = nil;
    self.commentsLabel.text = nil;
    self.userLabel.text = nil;
}

- (void) setBusy:(BOOL)busy {
    if (busy) {
        [self.indicatorView startAnimating];
    }
    else {
        [self.indicatorView stopAnimating];
    }
}

@end
