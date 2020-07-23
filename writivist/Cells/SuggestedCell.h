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
@property (strong, nonatomic) NSArray *senderTemplates;
@property (strong, nonatomic) NSArray *likeTemplates;
@property (strong, nonatomic) NSArray *templates;
@property (strong, nonatomic) NSArray *myTemplates;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) TemplateLibraryViewController *templateLibrary;
@property (nonatomic) NSInteger *indexPathItem;
@property (nonatomic, strong) NSMutableDictionary *dict;

- (void) setCategory: (NSString *) category;
- (void)fetchTemplates;
@end


NS_ASSUME_NONNULL_END
