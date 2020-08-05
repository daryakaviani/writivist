//
//  PreviewViewController.m
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "PreviewViewController.h"
#import <TNTutorialManager.h>

@interface PreviewViewController ()<TNTutorialManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.temp == nil || self.user == nil || ![[User currentUser].username isEqualToString:self.user.username]) {
        self.editButton.hidden = YES;
    }
    self.bodyLabel.editable = NO;
    self.bodyLabel.text = self.body;
    self.titleLabel.text = self.templateTitle;
//    if ([TNTutorialManager shouldDisplayTutorial:self]) {
//        self.tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
//    } else {
//        self.tutorialManager = nil;
//    }
}
- (IBAction)doneButton:(id)sender {
    if (self.temp == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        self.temp.body = self.bodyLabel.text;
        [self.temp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}
- (IBAction)editButton:(id)sender {
    self.bodyLabel.editable = YES;
    self.bodyLabel.layer.borderColor = [UIColor systemGray5Color].CGColor;
    self.bodyLabel.layer.borderWidth = 1.0;
    self.bodyLabel.layer.cornerRadius = 5.0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tutorialMaxIndex {
    return 1;
}

- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
}


@end
