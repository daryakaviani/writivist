//
//  MyTemplateCell.h
//  writivist
//
//  Created by dkaviani on 7/16/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyTemplateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (strong, nonatomic) Template *temp;
@property (weak, nonatomic) IBOutlet UILabel *publicityText;
@end

NS_ASSUME_NONNULL_END
