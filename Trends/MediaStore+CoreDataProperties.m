//
//  MediaStore+CoreDataProperties.m
//  
//
//  Created by Alexander Malkov on 19/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaStore+CoreDataProperties.h"

@implementation MediaStore (CoreDataProperties)

@dynamic itemID;
@dynamic username;
@dynamic userFullName;
@dynamic captionText;
@dynamic createdDate;
@dynamic likesCount;
@dynamic commentCount;
@dynamic thumbnailUrl;
@dynamic thumbnailSize;
@dynamic photoUrl;
@dynamic photoSize;
@dynamic isVideo;
@dynamic videoURL;

@end
