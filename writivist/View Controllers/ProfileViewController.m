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
#import "CategoryViewController.h"
#import "SavedViewController.h"
#import "TNTutorialManager.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface ProfileViewController ()<UITableViewDelegate, UITableViewDataSource, TNTutorialManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *letterCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *templatesPublishedLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) PFFileObject *pickerView;
@property (strong, nonatomic) NSArray *templates;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *templateTitleLabel;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spinner startAnimating];
    if (self.user == nil || [[User currentUser].username isEqualToString:self.user.username]) {
        self.user = [User currentUser];
    } else {
        self.editButton.tintColor = [UIColor clearColor];
        self.editButton.enabled = NO;
        self.saveButton.tintColor = [UIColor clearColor];
        self.saveButton.enabled = NO;
    }
    self.templates = [[NSArray alloc] init];
    [self fetchTemplates];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.scrollView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchTemplates) forControlEvents:UIControlEventValueChanged];
        self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    
    self.navigationItem.title = self.user.username;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
    if ([[User currentUser].username isEqualToString:self.user.username]) {
        if ([TNTutorialManager shouldDisplayTutorial:self]) {
            self.tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
        } else {
            self.tutorialManager = nil;
        }
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchTemplates];
    [self updateInformation];
}

-(void)updateInformation{
    if (![self connected]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        User *user = self.user;
        if (self.templates.count == 0) {
            self.templateTitleLabel.hidden = YES;
        } else {
            self.templateTitleLabel.hidden = NO;
        }
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        self.usernameLabel.text = [NSString stringWithFormat:@"%@%@", @"@", user.username];
        self.letterCountLabel.text = [NSString stringWithFormat:@"%@",  user.letterCount];
        self.templatesPublishedLabel.text = [NSString stringWithFormat:@"%@",  user.templateCount];
        [self roundImage];
        self.profileView.file = self.user.profilePicture;
        [self.profileView loadInBackground];
    }
}

- (void) roundImage {
    CALayer *imageLayer = self.profileView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:3];
    [imageLayer setBorderColor:[[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:1].CGColor];
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
    cell.temp = template;
    cell.categoryLabel.text = template.category;
    cell.likeLabel.text = [NSString stringWithFormat:@"%@", template.likeCount];
    cell.senderLabel.text = [NSString stringWithFormat:@"%@", template.senderCount];
    cell.saveLabel.text = [NSString stringWithFormat:@"%@", template.saveCount];
    cell.titleLabel.text = template.title;
    if ([self.user.username isEqual:[User currentUser].username]) {
        if (template.isPrivate) {
            cell.privacySwitch.on = NO;
            cell.publicityText.text = @"Private";
        } else {
            cell.privacySwitch.on = YES;
            cell.publicityText.text = @"Public";
        }
    } else {
        cell.privacySwitch.hidden = YES;
        cell.publicityText.hidden = YES;
    }
    NSDate *tempTime = template.createdAt;
    NSDate *timeAgo = [NSDate dateWithTimeInterval:0 sinceDate:tempTime];
    cell.timestampLabel.text = timeAgo.shortTimeAgoSinceNow;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[User currentUser].username isEqualToString:self.user.username]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Template *template = self.templates[indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete this template?"
               message:@"This action cannot be undone."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            User *user = [User currentUser];
            int val = [user.templateCount intValue];
            user.templateCount = [NSNumber numberWithInt:(val - 1)];
            [user saveInBackground];
            [self updateInformation];            
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
    if (![self connected]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
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
            [self.spinner stopAnimating];
            [self updateInformation];
            self.spinner.hidden = YES;
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.tutorialManager) {
        [self.tutorialManager updateTutorial];
    }
}


- (NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index {
    if (index == 1) {
        return @[[self.navigationItem.rightBarButtonItems[1] valueForKey:@"view"]];
    }
    return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
    if (index == 0) {
        return @[@"Welcome to your profile, where you can manage your account settings, view your stats, and edit or delete your posted templates."];
    } else if (index == 1) {
        return @[@"Once you've saved templates, you view them here."];
    }
    return nil;
}

-(NSArray<TNTutorialEdgeInsets *> *)tutorialViewsEdgeInsets:(NSInteger)index {
    if (index == 1) {
        return @[TNTutorialEdgeInsetsMake(8, 8, 8, 8)];
    }

    return nil;
}

- (void)tutorialPreHighlightAction:(NSInteger)index {
}

-(void)tutorialPerformAction:(NSInteger)index {
}


- (NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index {
    return @[@(TNTutorialTextPositionBottom)];
}

- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
}

- (NSInteger)tutorialMaxIndex {
    return 2;
}

- (CGFloat)tutorialPreActionDelay:(NSUInteger)index {
    return 0;
}

- (BOOL)tutorialHasSkipButton:(NSInteger)index {
    return YES;
}

- (NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index {
    return @[[UIFont systemFontOfSize:17.f]];
}

 
 
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
      if ([segue.identifier isEqualToString:@"myTemplateSegue"]) {
          Template *template = self.templates[indexPath.row];
          PreviewViewController *previewViewController = [segue destinationViewController];
          previewViewController.user = self.user;
          previewViewController.body = template.body;
          previewViewController.temp = template;
          previewViewController.templateTitle = template.title;
      } else if ([segue.identifier isEqualToString:@"editSegue"]) {
          EditProfileViewController *editProfileViewController = [segue destinationViewController];
          editProfileViewController.profileViewController = self;
      }
}

@end
