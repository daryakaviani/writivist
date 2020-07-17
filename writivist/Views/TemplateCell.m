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
#import "PFImageView.h"

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
    [self roundImage];
    self.authorImage.file = self.temp.author.profilePicture;
    [self.authorImage loadInBackground];
}
- (IBAction)likeButton:(id)sender {
    __block bool containsUser = false;
    PFRelation *relation = [self.temp relationForKey:@"likedBy"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User *user in objects) {
            if ([user.username isEqual:[User currentUser].username]) {
                self.likeButton.selected = NO;
                containsUser = true;
                NSLog(@"Found user");
                [Template postUserUnlike:[User currentUser] withTemplate:self.temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
//                    [self.contentView reloadData];
                }];
            }
            break;
        }
        if (!containsUser) {
            NSLog(@"Did not find user");
            self.likeButton.selected = YES;
            [Template postUserLike:[User currentUser] withTemplate:self.temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            //                    [self.contentView reloadData];
            }];
        }
        self.likeLabel.text = [NSString stringWithFormat:@"%@", self.temp.likeCount];
    }];
}

- (void)fetchLikes {
    __block bool containsUser = false;
    PFRelation *relation = [self.temp relationForKey:@"likedBy"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User *user in objects) {
            if ([user.username isEqual:[User currentUser].username]) {
               self.likeButton.selected = YES;
               containsUser = true;
            }
            break;
        }
        if (!containsUser) {
            self.likeButton.selected = NO;
        }
        self.likeLabel.text = [NSString stringWithFormat:@"%@", self.temp.likeCount];
    }];
}

- (void) roundImage {
    CALayer *imageLayer = self.authorImage.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:3];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    [self.authorImage.layer setCornerRadius:self.authorImage.frame.size.width/2];
    [self.authorImage.layer setMasksToBounds:YES];
}

- (void) didTapTemplate:(UITapGestureRecognizer *)sender{
    [self.delegate templateCell:self didTap:self.temp];
}

@end
