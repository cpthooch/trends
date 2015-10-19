//
//  MediaItem.m
//  Trends
//
//  Created by Alex Malkoff on 18.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "MediaItem.h"
#import <InstagramKit/InstagramKit.h>
#import <SDWebImage/SDWebImageManager.h>

@interface Photo ()
@property (atomic, readwrite, strong) UIImage *image;
@end

@implementation Photo {
    id<SDWebImageOperation> _operation;
}

- (void) loadImageWithCompletion:(void(^)(UIImage *image, NSError *error))completion {
    if (self.image && completion) {
        completion(self.image, nil);
    }
    else if (!self.image) {
        @weakify(self);
        _operation = [[SDWebImageManager sharedManager] downloadImageWithURL:self.imageURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self); if (!self) return;
            self->_operation = nil;
            self.image = image;
            if (image) {
                self->_size = image.size;
            }
            if (completion) {
                completion(image, error);
            }
        }];
    }
}

- (void) cancelLoading {
    if (_operation) {
        [_operation cancel];
    }
}

+ (instancetype) photoWithImageURL:(NSURL *)imageURL size:(CGSize)size {
    return [[self alloc] initWithImageURL:imageURL size:size];
}

- (instancetype) initWithImageURL:(NSURL *)imageURL size:(CGSize)size {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _size = size;
    }
    return self;
}

@end


@implementation MediaItem

+ (instancetype) itemWithInstagramMedia:(InstagramMedia *)media {
    return [[self alloc] initWithInstagramMedia:media];
}

- (instancetype) initWithInstagramMedia:(InstagramMedia *)media {
    self = [super init];
    if (self) {
        self.itemID = media.Id;
        self.username = media.user.username;
        self.userFullName = media.user.fullName;
        self.captionText = media.caption.text;
        self.createdDate = media.createdDate;
        self.likesCount = media.likesCount;
        self.commentCount = media.commentCount;
        self.thumbnail = [Photo photoWithImageURL:media.thumbnailURL size:media.thumbnailFrameSize];
        self.photo = [Photo photoWithImageURL:media.standardResolutionImageURL size:media.standardResolutionImageFrameSize];
        self.isVideo = media.isVideo;
        self.videoURL = media.standardResolutionVideoURL;
    }
    return self;
}

@end
