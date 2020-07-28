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
@property (strong, nonatomic) MKDropdownMenu *dropdownMenu;

@end

@implementation ComposeViewController

//NSArray *categories;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.category = @"Select a category...";
    self.navTitle = self.category;
    self.navigationItem.title = @"compose";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor labelColor]};
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    self.categories = @[@"black lives matter", @"climate action", @"financial justice", @"islamophobia", @"topic", @"topic", @"topic", @"topic"];
    MKDropdownMenu *dropdownMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.dropdownMenu = dropdownMenu;
    [dropdownMenu setComponentTextAlignment:NSTextAlignmentLeft];
    [dropdownMenu setDropdownBackgroundColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1]];
    [dropdownMenu setDropdownCornerRadius:8];
    dropdownMenu.dataSource = self;
    dropdownMenu.delegate = self;
    self.letterField.layer.cornerRadius = 5;
    self.letterField.layer.borderWidth = 0.7;
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
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [self.dropdownMenu closeAllComponentsAnimated:YES];
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
    } else if ([self.category isEqualToString:@"Select a category..."]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Category"
                      message:@"Please select a category before submitting your template."
               preferredStyle:(UIAlertControllerStyleAlert)];
       // create an OK action
       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
       // add the OK action to the alert controller
       [alert addAction:okAction];
       [self presentViewController:alert animated:YES completion:^{
       }];
    } else {
        User *user = [User currentUser];
        int val = [user.templateCount intValue];
        user.templateCount = [NSNumber numberWithInt:(val + 1)];
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
