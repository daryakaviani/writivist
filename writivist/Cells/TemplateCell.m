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
#import <DateTools.h>

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
    self.senderLabel.text = [NSString stringWithFormat:@"%@", template.senderCount];
    self.titleLabel.text = template.title;
    self.categoryLabel.text = template.category;
    [self fetchLikes:^(BOOL isComplete) {
        if (isComplete) {
            self.likeButton.selected = YES;
        } else {
            self.likeButton.selected = NO;
        }
    }];
    [self fetchSaves:^(BOOL isComplete) {
        if (isComplete) {
            self.saveButton.selected = YES;
        } else {
            self.saveButton.selected = NO;
        }
    }];
    [self roundImage];
    PFFileObject *data = self.temp.author.profilePicture;
    [data getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error) {
      if (error == nil) {
        UIImage *image = [UIImage imageWithData:data];
        [self.authorButton setImage:image forState:UIControlStateNormal];
      } else {
        NSLog(@"Error");
      }
    }];
    NSDate *tempTime = template.createdAt;
    NSDate *timeAgo = [NSDate dateWithTimeInterval:0 sinceDate:tempTime];
    self.timestampLabel.text = timeAgo.shortTimeAgoSinceNow;
}
- (IBAction)saveButton:(id)sender {
    __block bool containsUser = false;
    PFRelation *relation = [self.temp relationForKey:@"savedBy"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User *user in objects) {
            if ([user.username isEqual:[User currentUser].username]) {
                self.saveButton.selected = NO;
                containsUser = true;
                NSLog(@"Found user");
                [Template postUserUnsave:[User currentUser] withTemplate:self.temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                }];
            }
        }
        if (!containsUser) {
            NSLog(@"Did not find user");
            self.saveButton.selected = YES;
            [Template postUserSave:[User currentUser] withTemplate:self.temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            }];
        }
    }];
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
                }];
            }
        }
        if (!containsUser) {
            NSLog(@"Did not find user");
            self.likeButton.selected = YES;
            [Template postUserLike:[User currentUser] withTemplate:self.temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            }];
        }
        self.likeLabel.text = [NSString stringWithFormat:@"%@", self.temp.likeCount];
    }];
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.likeButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.likeButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.likeButton.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)fetchLikes:(void(^)(BOOL isComplete))isComplete {
    __block bool containsUser = false;
    PFRelation *relation = [self.temp relationForKey:@"likedBy"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (User *user in objects) {
            if ([user.username isEqual:[User currentUser].username]) {
               containsUser = true;
               isComplete(true);
            }
        }
        if (!containsUser) {
//            self.likeButton.selected = NO;
            isComplete(false);
        }
        self.likeLabel.text = [NSString stringWithFormat:@"%@", self.temp.likeCount];
    }];
}
     
 - (void)fetchSaves:(void(^)(BOOL isComplete))isComplete {
     __block bool containsUser = false;
     PFRelation *relation = [self.temp relationForKey:@"savedBy"];
     PFQuery *query = [relation query];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
         for (User *user in objects) {
             if ([user.username isEqual:[User currentUser].username]) {
                isComplete(true);
                containsUser = true;
             }
         }
         if (!containsUser) {
             isComplete(false);
         }
     }];
 }
     
- (IBAction)authorButton:(id)sender {
    [self.otherDelegate profileTemplateCell:self didTap:self.temp.author];
}

- (void) roundImage {
    CALayer *imageLayer = self.authorButton.imageView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    [self.authorButton.imageView.layer setCornerRadius:self.authorButton.imageView.frame.size.width/2];
    [self.authorButton.imageView.layer setMasksToBounds:YES];
}

- (void) didTapTemplate:(UITapGestureRecognizer *)sender{
    [self.delegate templateCell:self didTap:self.temp];
}

@end
