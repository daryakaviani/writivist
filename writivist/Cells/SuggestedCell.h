//
//  SuggestedCell.h
//  writivist
//
//  Created by dkaviani on 7/22/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateCell.h"
#import "TemplateLibraryViewController.h"
@class TemplateLibraryViewController;
NS_ASSUME_NONNULL_BEGIN

@interface SuggestedCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSNumber *tester;
@property (strong, nonatomic) NSArray *templates;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) TemplateLibraryViewController *templateLibrary;
@property (nonatomic) NSInteger *indexPathItem;

- (void) setCategory: (NSString *) category;
- (void)fetchTemplates;
@end


NS_ASSUME_NONNULL_END
