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
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) PFFileObject *pickerView;

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
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.profileViewController viewWillAppear:YES];
        }];
    }];
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
