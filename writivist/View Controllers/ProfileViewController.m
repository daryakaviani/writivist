//
//  ProfileViewController.m
//  writivist
//
//  Created by dkaviani on 7/16/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import <Parse/Parse.h>
#import "PFImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTemplateCell.h"
#import "Template.h"
#import <DateTools.h>
#import "PreviewViewController.h"

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *letterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *templatesPublishedLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) PFFileObject *pickerView;
@property (strong, nonatomic) NSArray *templates;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.user == nil) {
        self.user = [User currentUser];
    }
    [self updateInformation];
    self.templates = [[NSArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self fetchTemplates];
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.scrollView addSubview:self.refreshControl];
//    [self.refreshControl addTarget:self action:@selector(updateInformation) forControlEvents:UIControlEventValueChanged];

    // Do any additional setup after loading the view.
}
- (IBAction)cameraButton:(id)sender {
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
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = [self resizeImage:originalImage withSize:CGSizeMake(414, 414)];
    self.pickerView = [self getPFFileFromImage:editedImage];
    [self roundImage];
    [self.user setObject:self.pickerView forKey:@"profilePicture"];
    [self.user saveInBackground];
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

- (IBAction)editButton:(id)sender {
}
-(void)updateInformation{
    User *user = self.user;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@%@", @"@", user.username];
    self.letterCountLabel.text = [NSString stringWithFormat:@"%@",  user.letterCount];
    self.templateLikeLabel.text = [NSString stringWithFormat:@"%@",  user.likeCount];
    self.templatesPublishedLabel.text = [NSString stringWithFormat:@"%@",  user.templateCount];
    [self roundImage];
    self.profileView.file = self.user.profilePicture;
    [self.profileView loadInBackground];
//    [self.refreshControl endRefreshing];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.templates.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Creating and configured a cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTemplateCell"];
    Template *template = self.templates[indexPath.row];
    cell.categoryLabel.text = template.category;
    cell.likeLabel.text = [NSString stringWithFormat:@"%@", template.likeCount];
    cell.titleLabel.text = template.title;
    NSDate *tempTime = template.createdAt;
    NSDate *timeAgo = [NSDate dateWithTimeInterval:0 sinceDate:tempTime];
    cell.timestampLabel.text = timeAgo.timeAgoSinceNow;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Template *template = self.templates[indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this template?"
               message:@"This action cannot be undone."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [template deleteInBackground];
            [self fetchTemplates];
        }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        [tableView reloadData]; // tell table to refresh now
    }
}

- (void)fetchTemplates {
    // construct query
    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:self.user];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            self.templates = templates;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


 
 
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
      if ([segue.identifier isEqualToString:@"myTemplateSegue"]) {
          Template *template = self.templates[indexPath.row];
          PreviewViewController *previewViewController = [segue destinationViewController];
          previewViewController.body = template.body;
          previewViewController.templateTitle = template.title;
      }
}

@end
