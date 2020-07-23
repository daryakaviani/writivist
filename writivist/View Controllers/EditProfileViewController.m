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
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *sendSwitch;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) PFFileObject *pickerView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.shouldIgnoreScrollingAdjustment = YES;
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
    
    if (user.sendIndividually) {
        self.sendSwitch.on = YES;
    } else {
        self.sendSwitch.on = NO;
    }
    
    [self roundImage];
    self.profileView.file = user.profilePicture;
    [self.profileView loadInBackground];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
    self.latitude = self.locationManager.location.coordinate.latitude;
    self.longitude = self.locationManager.location.coordinate.longitude;
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
                       self.zipField.text = newStr;
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
    [self openImagePicker];
}

-(void)openImagePicker {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    User *user = [User currentUser];
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = [self resizeImage:originalImage withSize:CGSizeMake(414, 414)];
    self.pickerView = [self getPFFileFromImage:editedImage];
    [self roundImage];
    [user setObject:self.pickerView forKey:@"profilePicture"];
    [user saveInBackground];
    [self.profileView setImage:editedImage];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
    if (self.sendSwitch.on) {
        user.sendIndividually = YES;
    } else {
        user.sendIndividually = NO;
    }
    
    NSString *location = user.streetNumber;
    location = [location stringByAppendingString:@"%20"];
    location = [location stringByAppendingString:user.streetName];
    location = [location stringByAppendingString:@".%20"];
    location = [location stringByAppendingString:user.city];
    location = [location stringByAppendingString:@"%20"];
    location = [location stringByAppendingString:user.state];
    location = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"%@", user);
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
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                   [self dismissViewControllerAnimated:YES completion:^{
                       [self.profileViewController viewWillAppear:YES];
                   }];
               }];
        }
        }] resume];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


@end
