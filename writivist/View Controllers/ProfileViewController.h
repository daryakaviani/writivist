//
//  ProfileViewController.h
//  writivist
//
//  Created by dkaviani on 7/16/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) User *user;
- (void)updateInformation;

@end

NS_ASSUME_NONNULL_END
