//
//  TemplateLibraryViewController.h
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateCell.h"
#import "User.h"
@class TemplateCell;

NS_ASSUME_NONNULL_BEGIN

@interface TemplateLibraryViewController : UIViewController
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *previousBody;
@property (strong, nonatomic) NSString *previewTitle;
@property (strong, nonatomic) TemplateCell * _Nullable currentCell;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Template * _Nullable currentTemplate;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;


@end

NS_ASSUME_NONNULL_END
