//
//  MediaStore+CoreDataProperties.h
//  
//
//  Created by Alexander Malkov on 19/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *itemID;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *userFullName;
@property (nullable, nonatomic, retain) NSString *captionText;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSNumber *likesCount;
@property (nullable, nonatomic, retain) NSNumber *commentCount;
@property (nullable, nonatomic, retain) NSString *thumbnailUrl;
@property (nullable, nonatomic, retain) NSValue *thumbnailSize;
@property (nullable, nonatomic, retain) NSString *photoUrl;
@property (nullable, nonatomic, retain) NSValue *photoSize;
@property (nullable, nonatomic, retain) NSNumber *isVideo;
@property (nullable, nonatomic, retain) NSString *videoURL;

@end

NS_ASSUME_NONNULL_END
