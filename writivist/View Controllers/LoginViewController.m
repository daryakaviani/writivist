//
//  LoginViewController.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "User.h"
#import "HyTransitions.h"
#import "HyLoglnButton.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) HyLoglnButton *loginButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton = [[HyLoglnButton alloc] initWithFrame:CGRectMake(self.view.center.x - self.passwordField.layer.frame.size.width/2, CGRectGetHeight(self.view.bounds) - self.view.frame.size.height/6.5, self.passwordField.layer.frame.size.width, 40)];
    [self.loginButton setBackgroundColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1]];
    [self.view addSubview:self.loginButton];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginUser) forControlEvents:UIControlEventTouchUpInside];
    self.passwordField.secureTextEntry = YES;
    NSLog(@"%@", @"Name");
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [User logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            [self.loginButton ErrorRevertAnimationCompletion:^{}];
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User login failed:"
                   message:error.localizedDescription
            preferredStyle:(UIAlertControllerStyleAlert)];
            // create an OK action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            // add the OK action to the alert controller
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{
            }];
        } else {
            NSLog(@"User logged in successfully");
            [self.loginButton ExitAnimationCompletion:^{
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }];
        }
    }];
}


#pragma mark Orientation
-(BOOL)shouldAutorotate
{
    [super shouldAutorotate];
    return NO;
}
- (NSUInteger) supportedInterfaceOrientations {
    [super supportedInterfaceOrientations];
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    [super preferredInterfaceOrientationForPresentation];
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}


- (IBAction)signupButton:(id)sender {
    [self performSegueWithIdentifier:@"signupsegue" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginSegue"]) {
        
    }
}

@end
