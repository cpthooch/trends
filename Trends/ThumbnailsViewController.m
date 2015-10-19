//
//  ThumbnailsViewController.m
//  Trends
//
//  Created by Alex Malkoff on 13.10.15.
//  Copyright (c) 2015 cpthooch. All rights reserved.
//

#import "ThumbnailsViewController.h"
#import "MediaItemViewController.h"
#import "ZoomingTransitionAnimator.h"
#import "ThumbViewCell.h"
#import "DataManager.h"
#import "MediaItem.h"
#import "MediaStore.h"
#import "AppDelegate.h"

@interface ThumbnailsViewController () <NSFetchedResultsControllerDelegate, ZoomingTransitionSourceController, ZoomingTransitionTargetController>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ThumbnailsViewController {
    NSMutableArray *_sectionChanges;
    NSMutableArray *_itemChanges;
}

- (NSManagedObjectContext *) managedObjectContext {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MediaStore"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"MediaStoreCache"];
    [_fetchedResultsController setDelegate:self];
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshItemCollection) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    [self.collectionView sendSubviewToBack:refreshControl];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideNavbarWithFade:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNavbarWithFade:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NSFetchedResultsController deleteCacheWithName:@"MediaStoreCache"];
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        // fallback to loading item collection
        [self loadItemCollection];
    }
    if (![DataManager sharedManager].hasCachedItems) {
        [self.activityIndicator startAnimating];
        [self loadItemCollection];
    }
    else {
        [self.collectionView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:MediaItemViewController.class]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        if (selectedIndexPath != nil) {
            MediaItemViewController *target = segue.destinationViewController;
            MediaStore *store = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
            target.mediaItem = store.asMediaItem;
        }
    }
}

- (void) hideNavbarWithFade:(BOOL)hide {
    [self.navigationController setNavigationBarHidden:hide animated:NO];
    [UIView transitionWithView:self.navigationController.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        [self.navigationController setNavigationBarHidden:hide animated:NO];
                    }
                    completion:nil];
}

- (void) refreshItemCollection {
    if (self.fetchedResultsController.fetchedObjects.count) {
        [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(MediaStore *_Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [item cancelImageLoads];
        }];
    }
    [self loadItemCollection];
}

- (void) loadItemCollection {
    @weakify(self);
    [[DataManager sharedManager] loadPopularMedia:^(NSError *error) {
        @strongify(self);
        if (error) {
            // try to repeat loading operation
            [self loadItemCollection];
            return;
        }
        [self.activityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - UICollectionViewControllerDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count ?: 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Thumb" forIndexPath:indexPath];
    
    MediaStore *store = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MediaItem *item = store.asMediaItem;
    cell.mediaItem = item;
    cell.userLabel.text = item.username;
    cell.likesLabel.text = [NSString stringWithFormat:@"%ld", (long)item.likesCount];
    cell.commentsLabel.text = [NSString stringWithFormat:@"%ld", (long)item.commentCount];
    if (item.thumbnail.image) {
        cell.imageView.image = item.thumbnail.image;
    }
    else {
        [cell setBusy:YES];
        @weakify(self);
        [item.thumbnail loadImageWithCompletion:^(UIImage *image, NSError *error) {
            @strongify(self); if (!self) return;
            if ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                ThumbViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell setBusy:NO];
                cell.imageView.image = image ?: [UIImage imageNamed:@"no_photo"];
            }
            
        }];
    }
    
    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                }
            }];
        }
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
    }];
}


#pragma mark - ZoomingTransition

- (UIView *) zoomingTransitionSourceView {
    ThumbViewCell *cell = (ThumbViewCell*)[self.collectionView cellForItemAtIndexPath:[[self.collectionView indexPathsForSelectedItems] firstObject]];
    return cell.imageView;
}

- (UIColor *) zoomingTransitionFadeColor {
    return [UIColor extra_colorWithHex:0xfafafa];
}

- (UIView *) zoomingTransitionTargetView {
    return [self zoomingTransitionSourceView];
}

- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator aboutToAnimate:(UIView *)view {
    view.hidden = YES;
}

- (void) zoomingTransitionAnimator:(ZoomingTransitionAnimator *)animator didAnimate:(UIView *)view {
    view.hidden = NO;
}

@end
