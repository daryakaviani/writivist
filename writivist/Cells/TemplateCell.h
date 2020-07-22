//
//  TemplateCell.h
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"
#import "CategoryRow.h"
#import "PFImageView.h"
#import "TemplateLibraryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TemplateCellDelegate;
@protocol ProfileDelegate;

@interface TemplateCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) Template   *temp;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (nonatomic, weak) id<TemplateCellDelegate> delegate;
@property (nonatomic, weak) id<ProfileDelegate> otherDelegate;
@property (weak, nonatomic) IBOutlet UIButton *authorButton;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) TemplateLibraryViewController *templateLibrary;

- (void)setTemplate:(Template *)template;

@end

@protocol TemplateCellDelegate
- (void)templateCell:(TemplateCell *) templateCell didTap: (Template *)temp;
@end

@protocol ProfileDelegate
- (void)profileTemplateCell:(TemplateCell *) templateCell didTap: (User *)user;
@end


NS_ASSUME_NONNULL_END
