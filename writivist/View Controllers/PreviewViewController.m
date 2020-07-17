//
//  PreviewViewController.m
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet UITextView *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bodyLabel.text = self.body;
    self.titleLabel.text = self.templateTitle;
}
- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation




@end
