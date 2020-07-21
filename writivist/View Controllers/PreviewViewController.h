//
//  PreviewViewController.h
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *templateTitle;
@property (nonatomic, strong) Template *temp;
@property (nonatomic, strong) User *user;

@end

NS_ASSUME_NONNULL_END
