//
//  HomeViewController.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "Representative.h"
#import "RepresentativeCell.h"
#import "UIImageView+AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "User.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, RepresentativeCellDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedReps;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.selectedReps = [[NSMutableArray alloc]init];
    [self fetchRepresentatives];
    
    // Customization for Nav Bar
    self.navigationItem.title = @"let's write.";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (IBAction)logoutButton:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    [User logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        PFUser *test = [User currentUser];
        
        NSLog(@" -- User is logged out -- %@", test.username);
    }];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

- (void)fetchRepresentatives {
    User *user = [User currentUser];
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
    NSString *targetUrl = [@"https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyBF0K61_yqnXdJvNBSzyq2uTHJsNktnCZ0&address=&address=" stringByAppendingString:location];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *representativeArray = [JSON valueForKey:@"officials"];
        NSArray *officesArray = [JSON valueForKey:@"offices"];
        NSMutableArray *representatives  = [Representative representativesWithArray:representativeArray];
        self.representatives = representatives;
        self.offices = officesArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }] resume];
}

// Tells us how many rows we need.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.representatives.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Creating and configured a cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepresentativeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepresentativeCell"];
    Representative *representative = self.representatives[indexPath.row];
    cell.delegate = self;
    cell.representative = representative;
    cell.nameLabel.text = representative.name;
    for (NSDictionary *dictionary in self.offices) {
        for (NSString *index in dictionary[@"officialIndices"]) {
            NSString *repIndex = [NSString stringWithFormat: @"%ld", indexPath.row];
            NSString *officialIndex = [NSString stringWithFormat: @"%@", index];
            if (repIndex == officialIndex) {
                representative.role = dictionary[@"name"];
            }
        }
    }
    cell.roleLabel.text = representative.role;
    if ([representative.party  isEqual: @"Republican Party"]) {
        cell.partyLabel.text = @"R";
        cell.partyLabel.textColor = [UIColor systemRedColor];
    } else if ([representative.party  isEqual: @"Democratic Party"]) {
            cell.partyLabel.text = @"D";
            cell.partyLabel.textColor = [UIColor systemIndigoColor];
    } else {
        cell.partyLabel.text = @"";
    }
    NSURL *profileURL = [NSURL URLWithString:representative.profileString];
    if (representative.profileString != nil) {
        [cell.profileView setImageWithURL:profileURL];
    } else {
        [cell.profileView setImage:[UIImage imageNamed:@"user.png"]];
    }
    [cell.websiteButton setTitle:representative.website forState:UIControlStateNormal];
    [cell.phoneButton setTitle:representative.phone forState:UIControlStateNormal];
    cell.emailLabel.text = representative.email;
    if (representative.twitter == nil) {
        cell.twitterButton.hidden = YES;
    } else {
        cell.twitterButton.hidden = NO;
    }
    if (representative.facebook == nil) {
        cell.facebookButton.hidden = YES;
    } else {
        cell.facebookButton.hidden = NO;
    }
    if (representative.selected == (BOOL * _Nonnull) YES) {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = NO;
    } else {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = YES;
    }
    return cell;
}

- (void)representativeCell:(RepresentativeCell *)representativeCell didTap:(Representative *)representative{
    if (representative.email != nil) {
        if (representative.selected == NO) {
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
            representativeCell.checkView.backgroundColor = color;
            representative.selected = (BOOL * _Nonnull) YES;
            UIView *subview = representativeCell.checkView.subviews[0];
            subview.hidden = NO;
            [self.selectedReps addObject:representative];
        } else {
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
            representativeCell.checkView.backgroundColor = color;
            representative.selected = (BOOL * _Nonnull) NO;
            UIView *subview = representativeCell.checkView.subviews[0];
            subview.hidden = YES;
            [self.selectedReps removeObject:representative];
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry, my email is unavailable to the public."
               message:@"Feel free to call my office or navigate to my website to contact me. Please take a look at my social media pages to see where I stand on political and social issues!"
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}

- (IBAction)composeButton:(id)sender {
    if (self.selectedReps.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No representatives selected."
               message:@"Please select at least one representative to send your message to."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (MFMailComposeViewController.canSendMail){
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        NSMutableArray *emails = [[NSMutableArray alloc] init];
        NSString *bodyHeader = @"Dear ";
        for (Representative *representative in self.selectedReps) {
            [emails addObject:representative.email];
            if (emails.count == self.selectedReps.count && emails.count != 1) {
                bodyHeader = [bodyHeader stringByAppendingString:@"and "];
            }
            bodyHeader = [bodyHeader stringByAppendingString:representative.role];
            bodyHeader = [bodyHeader stringByAppendingString:@" "];
            bodyHeader = [bodyHeader stringByAppendingString:representative.name];
            if (self.selectedReps.count != 2) {
                bodyHeader = [bodyHeader stringByAppendingString:@", "];
            }
        }
        [self.selectedReps removeAllObjects];
        [mailComposeViewController setToRecipients:emails];
        [mailComposeViewController setMessageBody:bodyHeader isHTML:false];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mail services are unavailable."
               message:@"Please ensure that you have Apple's mail app installed and are logged in."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
   // Check the result or perform other tasks.
 
   // Dismiss the mail compose view controller.
   [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
