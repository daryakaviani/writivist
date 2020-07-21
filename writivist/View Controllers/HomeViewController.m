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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSMutableArray *selectedReps;
@property (weak, nonatomic) IBOutlet UIView *counterView;
@property (weak, nonatomic) IBOutlet UIView *internalView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.counterView.hidden = YES;
    self.internalView.layer.cornerRadius = self.internalView.bounds.size.width/2;
    self.internalView.layer.masksToBounds = YES;

    self.self.counterView.backgroundColor = [UIColor clearColor];
    self.self.counterView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.self.counterView.layer.shadowOffset = CGSizeMake(2,2);
    self.self.counterView.layer.shadowOpacity = 0.4;
    self.self.counterView.layer.shadowRadius = 0.5;
    self.self.self.counterView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.counterView.bounds cornerRadius:100.0].CGPath;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.selectedReps = [[NSMutableArray alloc]init];
    [self fetchRepresentatives];
    if (self.body != nil) {
        self.navigationItem.title = @"select reps.";
        self.logoutButton.tintColor = [UIColor clearColor];
        self.logoutButton.enabled = NO;
    } else {
        self.navigationItem.title = @"let's write.";
        self.logoutButton.tintColor = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1];
        self.logoutButton.enabled = YES;
    }
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchRepresentatives];
    self.counterView.hidden = YES;
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
    NSString *targetUrl = [@"https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls&address=&address=" stringByAppendingString:location];
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
        NSLog(@"%@", representativeArray);
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
//    [cell.websiteButton setTitle:representative.website forState:UIControlStateNormal];
//    [cell.phoneButton setTitle:representative.phone forState:UIControlStateNormal];
    if (representative.email == nil) {
        cell.emailView.hidden = YES;
    } else {
        cell.emailView.hidden = NO;
    }
    if (representative.twitter == nil) {
        cell.twitterButton.enabled = NO;
    } else {
        cell.twitterButton.enabled = YES;
    }
    if (representative.facebook == nil) {
        cell.facebookButton.enabled = NO;
    } else {
        cell.facebookButton.enabled = YES;
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
            [self.selectedReps addObject:representativeCell];
        } else {
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
            representativeCell.checkView.backgroundColor = color;
            representative.selected = (BOOL * _Nonnull) NO;
            UIView *subview = representativeCell.checkView.subviews[0];
            subview.hidden = YES;
            [self.selectedReps removeObject:representativeCell];
        }
        if (self.selectedReps.count == 0) {
            self.counterView.hidden = YES;
        } else {
            self.counterView.hidden = NO;
            self.counterLabel.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.selectedReps.count];
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
        for (RepresentativeCell *representativeCell in self.selectedReps) {
            Representative *representative = representativeCell.representative;
            [emails addObject:representative.email];
            if (emails.count == self.selectedReps.count && emails.count != 1) {
                bodyHeader = [bodyHeader stringByAppendingString:@" and "];
            }
            bodyHeader = [bodyHeader stringByAppendingString:representative.role];
            bodyHeader = [bodyHeader stringByAppendingString:@" "];
            bodyHeader = [bodyHeader stringByAppendingString:representative.name];
            if (self.selectedReps.count != 2) {
                bodyHeader = [bodyHeader stringByAppendingString:@", "];
            }
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
            representativeCell.checkView.backgroundColor = color;
            representative.selected = (BOOL * _Nonnull) NO;
            UIView *subview = representativeCell.checkView.subviews[0];
            subview.hidden = YES;
        }
        if (self.selectedReps.count == 2) {
            bodyHeader = [bodyHeader stringByAppendingString:@", "];
        }
        bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, @"My name is "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].firstName];
        bodyHeader = [bodyHeader stringByAppendingString:@" "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].lastName];
        bodyHeader = [bodyHeader stringByAppendingString:@" and I am from "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].city];
        bodyHeader = [bodyHeader stringByAppendingString:@", "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].state];
        bodyHeader = [bodyHeader stringByAppendingString:@". "];

        if (self.body.length > 0) {
            bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, self.body];
            self.body = @"";
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
    if (result == MFMailComposeResultSent) {
        User *user = [User currentUser];
        int val = [user.letterCount intValue];
        user.letterCount = [NSNumber numberWithInt:(val + 1)];
        [user saveInBackground];
    }
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
