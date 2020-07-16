//
//  TemplateCell.m
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "TemplateCell.h"
#import "HomeViewController.h"
#import "PreviewViewController.h"

@implementation TemplateCell

- (void)awakeFromNib {
    [super awakeFromNib];
     UITapGestureRecognizer *templateTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapTemplate:)];
    [self.checkView addGestureRecognizer:templateTapGestureRecognizer];
    [self.checkView setUserInteractionEnabled:YES];
}

- (void)setTemplate:(Template *)template {
    _temp = template;
    self.authorLabel.text = template.author.username;
    self.likeLabel.text = [NSString stringWithFormat:@"%@", template.likeCount];
    self.titleLabel.text = template.title;
}

- (IBAction)previewButton:(id)sender {
    PreviewViewController *previewViewController = [self.inputViewController.storyboard instantiateViewControllerWithIdentifier:@"PreviewViewController"];
    previewViewController.bodyLabel.text = self.temp.body;
    [self.inputViewController presentViewController:previewViewController animated:NO completion:nil];
}

- (void) didTapTemplate:(UITapGestureRecognizer *)sender{
    [self.delegate templateCell:self didTap:self.temp];
}

@end
