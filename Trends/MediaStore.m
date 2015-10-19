//
//  MediaStore.m
//  
//
//  Created by Alexander Malkov on 19/10/15.
//
//

#import "MediaStore.h"
#import "MediaItem.h"

#define UPDATE_IF_CHANGED_OBJ(Prop, Val) \
if (((Val) == nil && Prop != nil) || ((Val) != nil && Prop == nil) || ![Prop isEqual:(Val)]) Prop = (Val)

#define UPDATE_IF_CHANGED_SCL(Prop, Val) \
if (Prop != (Val)) Prop = (Val)


@implementation MediaStore {
    MediaItem *_media;
}

- (MediaItem *) asMediaItem {
    if (!_media) {
        _media = [MediaItem new];
    }
    UPDATE_IF_CHANGED_OBJ(_media.itemID, self.itemID);
    UPDATE_IF_CHANGED_OBJ(_media.username, self.username);
    UPDATE_IF_CHANGED_OBJ(_media.userFullName, self.userFullName);
    UPDATE_IF_CHANGED_OBJ(_media.captionText, self.captionText);
    UPDATE_IF_CHANGED_OBJ(_media.createdDate, self.createdDate);
    UPDATE_IF_CHANGED_SCL(_media.likesCount, [self.likesCount integerValue]);
    UPDATE_IF_CHANGED_SCL(_media.commentCount, [self.commentCount integerValue]);
    UPDATE_IF_CHANGED_SCL(_media.isVideo, [self.isVideo boolValue]);
    UPDATE_IF_CHANGED_OBJ(_media.videoURL, [NSURL URLWithString:self.videoURL]);
    
    if (![_media.thumbnail.imageURL.absoluteString isEqualToString:self.thumbnailUrl]) {
        _media.thumbnail = [Photo photoWithImageURL:[NSURL URLWithString:self.thumbnailUrl]
                                               size:self.thumbnailSize.CGSizeValue];
    }
    if (![_media.photo.imageURL.absoluteString isEqualToString:self.photoUrl]) {
        _media.photo = [Photo photoWithImageURL:[NSURL URLWithString:self.photoUrl]
                                           size:self.photoSize.CGSizeValue];
    }
    return _media;
}

- (void) updateWithMediaItem:(MediaItem *)mediaItem {
    self.itemID = mediaItem.itemID;
    self.username = mediaItem.username;
    self.userFullName = mediaItem.userFullName;
    self.captionText = mediaItem.captionText;
    self.createdDate = mediaItem.createdDate;
    self.likesCount = @(mediaItem.likesCount);
    self.commentCount = @(mediaItem.commentCount);
    self.thumbnailUrl = mediaItem.thumbnail.imageURL.absoluteString;
    self.thumbnailSize = [NSValue valueWithCGSize:mediaItem.thumbnail.size];
    self.photoUrl = mediaItem.photo.imageURL.absoluteString;
    self.photoSize = [NSValue valueWithCGSize:mediaItem.photo.size];
    self.isVideo = @(mediaItem.isVideo);
    self.videoURL = mediaItem.videoURL.absoluteString;
}

- (void) cancelImageLoads {
    if (_media) {
        [_media.thumbnail cancelLoading];
        [_media.photo cancelLoading];
    }
}

@end
