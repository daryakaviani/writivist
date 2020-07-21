//
//  HomeViewController.h
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *body;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;

@end

NS_ASSUME_NONNULL_END
