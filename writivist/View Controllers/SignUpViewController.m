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
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

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
@property (nonatomic, strong) CLLocationManager *locationManager;

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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
}

- (void)startUserLocationSearch {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (IBAction)findMe:(id)sender {
    [self startUserLocationSearch];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    if (self.locationManager.location != nil) {
        NSString *baseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?latlng=";
        NSString *keyUrl = @"&key=AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls";
        baseUrl = [baseUrl stringByAppendingFormat:@"%f", self.locationManager.location.coordinate.latitude];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", @","];
        baseUrl = [baseUrl stringByAppendingFormat:@"%f", self.locationManager.location.coordinate.longitude];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", keyUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:baseUrl]];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *addressComponents = [JSON valueForKey:@"results"][0][@"address_components"];
            NSLog(@"%@", addressComponents);
            dispatch_async(dispatch_get_main_queue(), ^{
               for (NSDictionary *dict in addressComponents) {
                   if ([dict[@"types"] containsObject:@"street_number"]) {
                       NSString *str = dict[@"short_name"];
                       NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                       NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                       self.streetNumberField.text = newStr;
                   } else if ([dict[@"types"] containsObject:@"route"]) {
                       NSString *str = dict[@"short_name"];
                       NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                       NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                       self.streetNameField.text = newStr;
                   } else if ([dict[@"types"] containsObject:@"locality"]) {
                       NSString *str = dict[@"short_name"];
                       NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                       NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                       self.cityField.text = newStr;
                    } else if ([dict[@"types"] containsObject:@"administrative_area_level_1"]) {
                        NSString *str = dict[@"short_name"];
                        NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                        NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                       self.stateField.text = newStr;
                   } else if ([dict[@"types"] containsObject:@"postal_code"]) {
                       NSString *str = dict[@"short_name"];
                       NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                       NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                       self.zipCodeField.text = newStr;
                   }
               }
            });
        }] resume];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services unavailable."
               message:@"Please ensure you have granted writivist access to your location."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
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
