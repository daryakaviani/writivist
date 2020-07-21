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
#import "EditProfileViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *letterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *templatesPublishedLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) PFFileObject *pickerView;
@property (strong, nonatomic) NSArray *templates;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.user == nil) {
        self.user = [User currentUser];
    }
    self.templates = [[NSArray alloc] init];
    [self fetchTemplates];
    [self updateInformation];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchTemplates) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}
- (IBAction)refreshButton:(id)sender {
    [self updateInformation];
    [self fetchTemplates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInformation];
}

-(void)updateInformation{
    User *user = self.user;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@%@", @"@", user.username];
    self.letterCountLabel.text = [NSString stringWithFormat:@"%@",  user.letterCount];
    self.templatesPublishedLabel.text = [NSString stringWithFormat:@"%@",  user.templateCount];
    [self roundImage];
    self.profileView.file = self.user.profilePicture;
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
            int likes = 0;
            for (Template *template in templates) {
                likes += [template.likeCount intValue];
                NSLog(@"%@", template.likeCount);
            }
            self.templateLikeLabel.text = [NSString stringWithFormat:@"%d",  likes];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
    [self updateInformation];

}


 
 
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
      if ([segue.identifier isEqualToString:@"myTemplateSegue"]) {
          Template *template = self.templates[indexPath.row];
          PreviewViewController *previewViewController = [segue destinationViewController];
          previewViewController.body = template.body;
          previewViewController.temp = template;
          previewViewController.templateTitle = template.title;
      } else if ([segue.identifier isEqualToString:@"editSegue"]) {
          EditProfileViewController *editProfileViewController = [segue destinationViewController];
          editProfileViewController.profileViewController = self;
      }
}

@end
