//
//  EditProfileViewController.m
//  writivist
//
//  Created by dkaviani on 7/20/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import "PFImageView.h"
#import "User.h"

@interface EditProfileViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *streetNumberField;
@property (weak, nonatomic) IBOutlet UITextField *streetNameField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    User *user = [User currentUser];
    self.firstNameField.text = user.firstName;
    self.lastNameField.text = user.lastName;
    self.usernameField.text = user.username;
    self.passwordField.text = user.password;
    self.streetNumberField.text = user.streetNumber;
    self.streetNameField.text = user.streetName;
    self.cityField.text = user.city;
    self.stateField.text = user.state;
    self.zipField.text = user.zipCode;
    [self roundImage];
    self.profileView.file = user.profilePicture;
    [self.profileView loadInBackground];
}

- (void) roundImage {
    CALayer *imageLayer = self.profileView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:5];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    [self.profileView.layer setCornerRadius:self.profileView.frame.size.width/2];
    [self.profileView.layer setMasksToBounds:YES];
}

- (IBAction)changeProfilePhoto:(id)sender {
}
- (IBAction)doneButton:(id)sender {
    User *user = [User currentUser];
    user.firstName = self.firstNameField.text;
    user.lastName = self.lastNameField.text;
    user.username = self.usernameField.text;
    user.password = self.passwordField.text;
    user.streetNumber = self.streetNumberField.text;
    user.streetName = self.streetNameField.text;
    user.city = self.cityField.text;
    user.state = self.stateField.text;
    user.zipCode = self.zipField.text;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.profileViewController viewWillAppear:YES];
        }];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


@end
