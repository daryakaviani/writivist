//
//  HomeViewController.h
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) NSMutableArray *selectedReps;

@end

NS_ASSUME_NONNULL_END
