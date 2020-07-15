//
//  TemplateCell.m
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "TemplateCell.h"

@implementation TemplateCell

- (void)setTemplate:(Template *)template {
    _temp = template;
    self.authorLabel.text = template.author.username;
    self.likeLabel.text = [NSString stringWithFormat:@"%@", template.likeCount];
    self.titleLabel.text = template.title;
}

@end
