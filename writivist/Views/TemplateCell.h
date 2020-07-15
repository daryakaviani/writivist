//
//  TemplateCell.h
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TemplateCellDelegate;

@interface TemplateCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (strong, nonatomic) Template *temp;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (nonatomic, weak) id<TemplateCellDelegate> delegate;


- (void)setTemplate:(Template *)template;

@end

@protocol TemplateCellDelegate
- (void)templateCell:(TemplateCell *) templateCell didTap: (Template *)temp;
@end


NS_ASSUME_NONNULL_END
