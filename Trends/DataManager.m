//
//  DataManager.m
//  Trends
//
//  Created by Alex Malkoff on 18.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "DataManager.h"
#import "MediaItem.h"
#import "MediaStore.h"
#import "AppDelegate.h"
#import <InstagramKit/InstagramKit.h>



@implementation DataManager

+ (instancetype) sharedManager {
    static DataManager *__self = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __self = [[self alloc] init];
    });
    return __self;
}

- (NSManagedObjectContext *) _mainContext {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

- (BOOL) hasCachedItems {
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaStore" inManagedObjectContext:self._mainContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSUInteger count = [self._mainContext countForFetchRequest:request error:&error];
    return count != NSNotFound && count > 0;
}

- (void) loadPopularMediaWithCompletion:(LoadingCompletionBlock)completion {
    if (!completion) return;
    [[InstagramEngine sharedEngine]
     getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
         __block NSMutableArray *items = [NSMutableArray arrayWithCapacity:media.count];
         [media enumerateObjectsUsingBlock:^(InstagramMedia *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             [items addObject:[MediaItem itemWithInstagramMedia:obj]];
         }];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(items, nil);
         });
     }
     failure:^(NSError *error, NSInteger serverStatusCode) {
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(nil, error);
         });
     }];
}

- (void) loadPopularMedia:(LoadingErrorBlock)errorBlock {
    [[InstagramEngine sharedEngine]
     getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
         __block NSMutableArray *items = [NSMutableArray arrayWithCapacity:media.count];
         [media enumerateObjectsUsingBlock:^(InstagramMedia *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             [items addObject:[MediaItem itemWithInstagramMedia:obj]];
         }];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [self _storeMediaCollection:[items copy]];
             if (errorBlock) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     errorBlock(nil);
                 });
             }
         });
     }
     failure:^(NSError *error, NSInteger serverStatusCode) {
         if (errorBlock) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorBlock(error);
             });
         }
     }];
}

- (void) _storeMediaCollection:(NSArray *)collection {
    NSManagedObjectContext *localThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [localThreadContext setParentContext:self._mainContext];
    
    [localThreadContext performBlock:^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaStore" inManagedObjectContext:self._mainContext];
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:entity];
        
        __block NSMutableArray *ids = [NSMutableArray arrayWithCapacity:collection.count];
        [collection enumerateObjectsUsingBlock:^(MediaItem *_Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [ids addObject:item.itemID];
        }];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"itemID IN %@", [ids copy]]];
        
        NSError *error = nil;
        NSArray *result = [localThreadContext executeFetchRequest:request error:&error];
        
        if (!error) {
            for (MediaStore *store in result) {
                MediaItem *item = [collection objectAtIndex:[collection indexOfObjectPassingTest:^BOOL(MediaItem *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [store.itemID isEqualToString:obj.itemID];
                }]];
                [store updateWithMediaItem:item];
                [ids removeObject:store.itemID];
            }
        }
        
        [ids enumerateObjectsUsingBlock:^(NSString *_Nonnull itemID, NSUInteger idx, BOOL * _Nonnull stop) {
            MediaItem *item = [collection objectAtIndex:[collection indexOfObjectPassingTest:^BOOL(MediaItem *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [itemID isEqualToString:obj.itemID];
            }]];
            MediaStore *store = [[MediaStore alloc] initWithEntity:entity insertIntoManagedObjectContext:localThreadContext];
            [store updateWithMediaItem:item];
        }];
        
        if (localThreadContext.hasChanges) {
            error = nil;
            [localThreadContext save:&error];
            [self._mainContext performBlock:^{
                NSError *error;
                [self._mainContext save:&error];
            }];
        }
    }];
}

@end
