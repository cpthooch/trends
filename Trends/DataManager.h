//
//  DataManager.h
//  Trends
//
//  Created by Alex Malkoff on 18.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadingCompletionBlock)(NSArray *items, NSError *error);
typedef void (^LoadingErrorBlock)(NSError *error);

@interface DataManager : NSObject

+ (instancetype) sharedManager;

@property (nonatomic, readonly) BOOL hasCachedItems;

- (void) loadPopularMediaWithCompletion:(LoadingCompletionBlock)completion;

- (void) loadPopularMedia:(LoadingErrorBlock)errorBlock;

@end
