//
//  ProfileViewController.m
//  writivist
//
//  Created by dkaviani on 7/16/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *letterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *templatesPublishedLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    User *user = [User currentUser];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@%@", @"@", user.username];
    [self.profileView setImage:[UIImage imageNamed:@"user.png"]];
    self.letterCountLabel.text = [NSString stringWithFormat:@"%@",  user.letterCount];
    self.templateLikeLabel.text = [NSString stringWithFormat:@"%@",  user.likeCount];
    self.templatesPublishedLabel.text = [NSString stringWithFormat:@"%@",  user.templateCount];
    // Do any additional setup after loading the view.
}
- (IBAction)cameraButton:(id)sender {
}
- (IBAction)editButton:(id)sender {
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
