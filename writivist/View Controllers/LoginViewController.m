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
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

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

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)loginUser {
    if (![self connected]) {
        [self.loginButton ErrorRevertAnimationCompletion:^{}];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{}];
    } else {
        [self performLogin];
    }
}

- (void) performLogin {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [User logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (user == nil) {
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.loginButton ExitAnimationCompletion:^{
                    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                }];
            });
        }
    }];
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
