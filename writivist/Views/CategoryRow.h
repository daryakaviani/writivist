//
//  CategoryRow.h
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryRow : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSNumber *tester;
@property (strong, nonatomic) NSArray *templates;

- (void) setCategory: (NSString *) category;

@end

NS_ASSUME_NONNULL_END
