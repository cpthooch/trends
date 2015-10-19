//
//  MediaStore.h
//  
//
//  Created by Alexander Malkov on 19/10/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem;

NS_ASSUME_NONNULL_BEGIN

@interface MediaStore : NSManagedObject

- (MediaItem *) asMediaItem;
- (void) updateWithMediaItem:(MediaItem *)mediaItem;

- (void) cancelImageLoads;

@end

NS_ASSUME_NONNULL_END

#import "MediaStore+CoreDataProperties.h"
