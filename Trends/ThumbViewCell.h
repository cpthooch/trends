//
//  ThumbViewCell.h
//  Trends
//
//  Created by Alex Malkoff on 15.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaItem;


@interface ThumbViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

- (void) setBusy:(BOOL)busy;
@property (strong, nonatomic) MediaItem *mediaItem;

@end
