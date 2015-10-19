//
//  MediaItem.h
//  Trends
//
//  Created by Alex Malkoff on 18.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InstagramMedia;

@interface Photo : NSObject

@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) CGSize size;
@property (atomic, readonly, strong) UIImage *image;

- (void) loadImageWithCompletion:(void(^)(UIImage *image, NSError *error))completion;
- (void) cancelLoading;

+ (instancetype) photoWithImageURL:(NSURL *)imageURL size:(CGSize)size;
- (instancetype) initWithImageURL:(NSURL *)imageURL size:(CGSize)size;

@end


@interface MediaItem : NSObject

@property (nonatomic, copy) NSString *itemID;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userFullName;
@property (nonatomic, copy) NSString *captionText;

@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic) NSInteger likesCount;
@property (nonatomic) NSInteger commentCount;

@property (nonatomic, strong) Photo *thumbnail;
@property (nonatomic, strong) Photo *photo;

@property (nonatomic) BOOL isVideo;
@property (nonatomic, strong) NSURL *videoURL;

+ (instancetype) itemWithInstagramMedia:(InstagramMedia *)media;
- (instancetype) initWithInstagramMedia:(InstagramMedia *)media;

@end
