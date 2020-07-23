//
//  SignUpViewController.m
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"
#import "User.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *streetNumberField;
@property (weak, nonatomic) IBOutlet UITextField *streetNameField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordField.secureTextEntry = YES;
    self.confirmPasswordField.secureTextEntry = YES;
}

- (IBAction)signupButton:(id)sender {
    [self registerUser];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        NSLog(@"Image is nil");
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        NSLog(@"Image data is nil");
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

- (void)registerUser {
    // initialize a user object
    User *newUser = [User user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.firstName = self.firstNameField.text;
    newUser.lastName = self.lastNameField.text;
    newUser.streetNumber = self.streetNumberField.text;
    newUser.streetName = self.streetNameField.text;
    newUser.city = self.cityField.text;
    newUser.state = self.stateField.text;
    newUser.zipCode = self.zipCodeField.text;
    newUser.likeCount = @(0);
    newUser.templateCount = @(0);
    newUser.letterCount = @(0);
    newUser.profilePicture = [self getPFFileFromImage:[UIImage imageNamed:@"user.png"]];
    newUser.sendIndividually = YES;
    
    if (self.passwordField.text.length == 0 || self.usernameField.text.length == 0
        || self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0
        || self.streetNumberField.text.length == 0 || self.streetNameField.text.length == 0
        || self.cityField.text.length == 0 || self.stateField.text.length == 0
        || self.zipCodeField.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"At least one field is empty."
               message:@"Please ensure all fields are completed and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (![self.passwordField.text isEqual:self.confirmPasswordField.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Passwords must match."
               message:@"Please try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSString *location = newUser.streetNumber;
        location = [location stringByAppendingString:@"%20"];
        location = [location stringByAppendingString:newUser.streetName];
        location = [location stringByAppendingString:@".%20"];
        location = [location stringByAppendingString:newUser.city];
        location = [location stringByAppendingString:@"%20"];
        location = [location stringByAppendingString:newUser.state];
        location = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"%@", location);
        NSString *targetUrl = [@"https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls&address=&address=" stringByAppendingString:location];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:targetUrl]];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your address is unsupported."
                       message:@"Please ensure your submission is valid and that there are no accents in your address."
                preferredStyle:(UIAlertControllerStyleAlert)];
                // create an OK action
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                // add the OK action to the alert controller
                [alert addAction:okAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
            } else {
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (error != nil) {
                        NSLog(@"Error: %@", error.localizedDescription);
                        NSLog(@"User sign in failed: %@", error.localizedDescription);
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User sign in failed:"
                           message:error.localizedDescription preferredStyle:(UIAlertControllerStyleAlert)];
                        // create an OK action
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault          handler:^(UIAlertAction * _Nonnull action) { }];
                        // add the OK action to the alert controller
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    } else {
                        NSLog(@"User registered successfully");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
            }] resume];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


@end
