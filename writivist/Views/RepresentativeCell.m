//
//  RepresentativeCell.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "RepresentativeCell.h"

@implementation RepresentativeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *cellTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCell:)];
    [self.checkView addGestureRecognizer:cellTapGestureRecognizer];
    [self.checkView setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkButton:(id)sender {
    if (self.checkButton.selected == YES) {
        self.checkButton.selected = NO;
    } else {
        self.checkButton.selected = YES;
    }
}
- (IBAction)facebookButton:(id)sender {
    NSString *baseURL = @"https://facebook.com/";
    NSString *stringURL = [baseURL stringByAppendingString:self.representative.facebook];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL] options:@{} completionHandler:nil];
}
- (IBAction)twitterButton:(id)sender {
    NSString *baseURL = @"https://twitter.com/";
    NSString *stringURL = [baseURL stringByAppendingString:self.representative.twitter];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL] options:@{} completionHandler:nil];
}

- (void) didTapCell:(UITapGestureRecognizer *)sender{
    [self.delegate representativeCell:self didTap:self.representative];
}

@end
