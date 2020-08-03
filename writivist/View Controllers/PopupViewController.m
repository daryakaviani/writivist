//
//  PopupViewController.m
//  writivist
//
//  Created by dkaviani on 8/3/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "PopupViewController.h"
#import <HWPopController/HWPop.h>
#import "Report.h"

@interface PopupViewController ()
@property UITextView * reasonView;
@end

@implementation PopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentSizeInPop = CGSizeMake(300, 300);
    
    UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 200, 20)];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentLeft];
    label.textColor= [UIColor labelColor];
    label.font = [UIFont fontWithName:@"Helvetica Bold" size:20];
    label.text = @"Report Template";
    [self.view addSubview:label];
    
    UILabel  * instructions = [[UILabel alloc] initWithFrame:CGRectMake(25, 45, 250, 40)];
    instructions.backgroundColor = [UIColor clearColor];
    [instructions setTextAlignment:NSTextAlignmentLeft];
    instructions.textColor = [UIColor labelColor];
    instructions.font = [UIFont fontWithName:@"Helvetica" size:12];
    instructions.text = @"Please provide us with a thorough explanation of why you are reporting this template.";
    instructions.numberOfLines = 0;
    [self.view addSubview:instructions];
    
    self.reasonView = [[UITextView alloc] initWithFrame:CGRectMake(30, 85, self.contentSizeInPop.width - 60, self.contentSizeInPop.height - 140) textContainer:nil];
    self.reasonView.backgroundColor = [UIColor clearColor];
    self.reasonView.layer.cornerRadius = 5;
    self.reasonView.layer.borderWidth = 0.7;
    self.reasonView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.view addSubview:self.reasonView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setBackgroundColor:({
        UIColor* color = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
        color;
    })];
    button.layer.cornerRadius = 5;
    button.tintColor = [UIColor whiteColor];
    [button addTarget:self
               action:@selector(submitReport)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Submit Report" forState:UIControlStateNormal];
    button.frame = CGRectMake(30, self.reasonView.frame.origin.y + self.reasonView.frame.size.height + 10, self.contentSizeInPop.width - 60, 30);
    [self.view addSubview:button];
}

- (void) submitReport {
    [Report postUserReport:self.temp withReason:self.reasonView.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.popController dismiss];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
