//
//  MyTemplateCell.m
//  writivist
//
//  Created by dkaviani on 7/16/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "MyTemplateCell.h"

@implementation MyTemplateCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)privacySwitch:(id)sender {
    self.temp.isPrivate = !self.temp.isPrivate;
    [self.temp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (self.temp.isPrivate) {
            self.privacySwitch.on = NO;
            self.publicityText.text = @"Private";
        } else {
            self.privacySwitch.on = YES;
            self.publicityText.text = @"Public";
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
