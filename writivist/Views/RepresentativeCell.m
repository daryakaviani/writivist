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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)checkButton:(id)sender {
}
- (IBAction)facebookButton:(id)sender {
    NSString *baseURL = @"https://facebook.com/";
    if (self.representative.facebook.length == 0) {
    } else {
        NSString *stringURL = [baseURL stringByAppendingString:self.representative.facebook];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    }
}
- (IBAction)twitterButton:(id)sender {
    NSString *baseURL = @"https://twitter.com/";
    if (self.representative.twitter.length == 0) {
    } else {
        NSString *stringURL = [baseURL stringByAppendingString:self.representative.twitter];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    }
}

@end
