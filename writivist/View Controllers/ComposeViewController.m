//
//  ComposeViewController.m
//  writivist
//
//  Created by dkaviani on 7/15/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "ComposeViewController.h"
#import "Template.h"
#import "MKDropdownMenu.h"
#import "User.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (weak, nonatomic) IBOutlet UITextView *letterField;
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *navTitle;

@end

@implementation ComposeViewController

//NSArray *categories;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.category = @"Category";
    self.navTitle = self.category;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1];
    self.categories = @[@"black lives matter", @"climate action", @"financial justice", @"islamophobia", @"topic", @"topic", @"topic", @"topic"];
    MKDropdownMenu *dropdownMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [dropdownMenu setComponentTextAlignment:NSTextAlignmentLeft];
    [dropdownMenu setDisclosureIndicatorImage:[UIImage imageNamed:@"download.png"]];
    [dropdownMenu setDropdownBackgroundColor:[[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1]];
    dropdownMenu.dataSource = self;
    dropdownMenu.delegate = self;
    self.letterField.layer.cornerRadius = 8;
    self.letterField.layer.borderWidth = 0.8;
    self.letterField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.categoryView addSubview:dropdownMenu];
}

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu{
    return 1;
}
- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component{
    return self.categories.count;
}
- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component{
    return self.category;
}
- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.categories[row];
}

-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.category = self.categories[row];
    [dropdownMenu reloadAllComponents];
    [dropdownMenu closeAllComponentsAnimated:YES];
    NSLog(@"%@", self.category);
}


- (IBAction)shareButton:(id)sender {
    if ([self.letterField.text isEqual: @""] || [self.subjectField.text isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Subject or Message"
               message:@"Please enter a message and subject before submitting your template."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        User *user = [User currentUser];
        int val = [user.likeCount intValue];
        user.likeCount = [NSNumber numberWithInt:(val + 1)];
        [user saveInBackground];
        [Template postUserTemplate:self.letterField.text withCategory:self.category withTitle:self.subjectField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            [self performSegueWithIdentifier:@"postedTemplate" sender:nil];
        }];
    }
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
