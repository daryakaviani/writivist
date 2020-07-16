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

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (weak, nonatomic) IBOutlet UITextField *letterField;
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
    self.letterField.borderStyle = UITextBorderStyleRoundedRect;
    MKDropdownMenu *dropdownMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [dropdownMenu setComponentTextAlignment:NSTextAlignmentLeft];
    [dropdownMenu setDisclosureIndicatorImage:[UIImage imageNamed:@"download.png"]];
    dropdownMenu.dataSource = self;
    dropdownMenu.delegate = self;
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
    [Template postUserTemplate:self.letterField.text withCategory:self.category withTitle:self.subjectField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self performSegueWithIdentifier:@"postedTemplate" sender:nil];
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
