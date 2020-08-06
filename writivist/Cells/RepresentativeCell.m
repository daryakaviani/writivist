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
    [self roundImage];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    // Clear contentView
    BOOL hasContentView = [self.subviews containsObject:self.contentView];
    if (hasContentView) {
        [self.contentView removeFromSuperview];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) roundImage {
    CALayer *imageLayer = self.profileView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:3];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    [self.profileView.layer setCornerRadius:self.profileView.frame.size.width/2];
    [self.profileView.layer setMasksToBounds:YES];
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
- (IBAction)phoneButton:(id)sender {
    NSString *number = [@"tel:" stringByAppendingString:self.representative.phone];
    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number] options:@{} completionHandler:nil];
}
- (IBAction)websiteButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.representative.website] options:@{} completionHandler:nil];
}
@end
