//
//  HomeViewController.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "Representative.h"
#import "RepresentativeCell.h"
#import "UIImageView+AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "User.h"
#import "PrintViewController.h"
#import "TNTutorialManager.h"
#import "AppDelegate.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, RepresentativeCellDelegate, MFMailComposeViewControllerDelegate, TNTutorialManagerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *printButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSMutableArray *selectedReps;
@property (weak, nonatomic) IBOutlet UIView *counterView;
@property (weak, nonatomic) IBOutlet UIView *internalView;
@property (nonatomic) NSMutableArray *federalReps;
@property (nonatomic) NSMutableArray *stateReps;
@property (nonatomic) NSMutableArray *countyReps;
@property (nonatomic) NSMutableArray *cityReps;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;

@end

@implementation HomeViewController

NSArray *levels;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    levels = @[@"Federal", @"State", @"County", @"City"];
    
    self.spinner.hidden = NO;
    [self.spinner startAnimating];

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
    if (self.currentTemplate != nil) {
        self.navigationItem.title = @"Select Officials";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
        self.logoutButton.tintColor = [UIColor clearColor];
        self.logoutButton.enabled = NO;
    } else {
        self.navigationItem.title = @"writivist";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:45], NSForegroundColorAttributeName : [UIColor labelColor]};
        self.logoutButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
        self.logoutButton.enabled = YES;
    }
    if ([TNTutorialManager shouldDisplayTutorial:self]) {
        self.tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
    } else {
        self.tutorialManager = nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cityReps.count == 0) {
        return 3;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.federalReps.count;
        case 1:
            return self.stateReps.count;
        case 2:
            return self.countyReps.count;
        default:
            return self.cityReps.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 50)];
    [label setFont: [UIFont fontWithName:@"Helvetica" size:25]];
    [label setTextColor:[UIColor whiteColor]];
    NSString *string = levels[section];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:0.75]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchRepresentatives];
    self.counterView.hidden = YES;
}
- (IBAction)printButton:(id)sender {
    if (self.selectedReps.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No representatives selected."
               message:@"Please select at least one representative to print a letter for."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        Boolean properSelections = true;
        for (Representative *representative in self.selectedReps) {
            if (representative.address == nil) {
                properSelections = false;
            }
        }
        if (properSelections) {
            [self performSegueWithIdentifier:@"toPrint" sender:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"At least one of your selected officials does not have an address available."
                           message:@"Please ensure each of your selected officials displays address verification and try again."
            preferredStyle:(UIAlertControllerStyleAlert)];
            // create an OK action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
            // add the OK action to the alert controller
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (IBAction)logoutButton:(id)sender {
    AppDelegate *myDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [User logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        PFUser *test = [User currentUser];
        
        NSLog(@" -- User is logged out -- %@", test.username);
    }];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

- (void)viewDidDisappear:(BOOL)animated {
    for (Representative *representative in self.selectedReps) {
        UIColor *color = [UIColor clearColor];
//        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
//        UIView *subview = representativeCell.checkView.subviews[0];
//        subview.hidden = YES;
    }
    [self.selectedReps removeAllObjects];
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
    NSString *targetUrl = @"https://www.googleapis.com/civicinfo/v2/representatives?key=";
    targetUrl = [targetUrl stringByAppendingString:@"AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls"];
    targetUrl = [targetUrl stringByAppendingString:@"&address="];
    targetUrl = [targetUrl stringByAppendingString:location];
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
            self.federalReps = [[NSMutableArray alloc] init];
            self.stateReps = [[NSMutableArray alloc] init];
            self.countyReps = [[NSMutableArray alloc] init];
            self.cityReps = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.representatives.count; i += 1) {
                Representative *representative = self.representatives[i];
               for (NSDictionary *dictionary in self.offices) {
                   for (NSString *index in dictionary[@"officialIndices"]) {
                       NSString *repIndex = [NSString stringWithFormat: @"%d", i];
                       NSString *officialIndex = [NSString stringWithFormat: @"%@", index];
                       if (repIndex == officialIndex) {
                           representative.level = dictionary[@"levels"][0];
                           if ([representative.level isEqual:@"country"]) {
                               [self.federalReps addObject:representative];
                           }
                           if ([representative.level isEqual:@"administrativeArea1"]) {
                               [self.stateReps addObject:representative];
                           }
                           if ([representative.level isEqual:@"administrativeArea2"]) {
                               [self.countyReps addObject:representative];
                           }
                           if ([representative.level isEqual:@"locality"]) {
                               [self.cityReps addObject:representative];
                           }
                       }
                   }
               }

            }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.spinner stopAnimating];
            self.spinner.hidden = YES;
        });
        }] resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Creating and configured a cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepresentativeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepresentativeCell"];
    // Restore contentView
    BOOL hasContentView = [cell.subviews containsObject:cell.contentView];
    if (!hasContentView) {
        [cell addSubview:cell.contentView];
    }
    Representative *representative;
    NSString *repIndex = [NSString stringWithFormat: @"%ld", indexPath.row];
    if (indexPath.section == 0) {
        representative = self.representatives[indexPath.row];
        repIndex = [NSString stringWithFormat: @"%ld", indexPath.row];
    } else if (indexPath.section == 1) {
        representative = self.representatives[indexPath.row + self.federalReps.count];
        repIndex = [NSString stringWithFormat: @"%ld", indexPath.row + self.federalReps.count];
    } else if (indexPath.section == 2) {
        representative = self.representatives[indexPath.row + self.federalReps.count + self.stateReps.count];
        repIndex = [NSString stringWithFormat: @"%ld", indexPath.row + self.federalReps.count + self.stateReps.count];
    } else {
        representative = self.representatives[indexPath.row + self.federalReps.count + self.stateReps.count + self.countyReps.count];
        repIndex = [NSString stringWithFormat: @"%ld", indexPath.row + self.federalReps.count + self.stateReps.count  + self.countyReps.count];
    }
    cell.delegate = self;
    cell.representative = representative;
    cell.nameLabel.text = representative.name;
    for (NSDictionary *dictionary in self.offices) {
        for (NSString *index in dictionary[@"officialIndices"]) {
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
    if (representative.email && representative.address) {
        cell.emailToCell.active = YES;
        if ([cell.partyLabel.text  isEqual: @""] ) {
            cell.printConstraint.constant = 50;
        } else {
            cell.printConstraint.constant = 70;
        }
    }
    if (representative.email == nil) {
        cell.emailToCell.active = NO;
        cell.emailView.hidden = YES;
        if ([cell.partyLabel.text isEqual: @""] ) {
            cell.printConstraint.constant = 20;
        } else {
            cell.printConstraint.constant = 40;
            cell.emailToCell.constant = 0;
        }
    } else {
        cell.emailView.hidden = NO;
    }
    if (representative.address == nil) {
        cell.printView.hidden = YES;
        cell.emailConstraint.constant = 5;
    } else {
        cell.printView.hidden = NO;
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
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = NO;
    } else {
        UIColor *color = [UIColor clearColor];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = YES;
    }
    return cell;
}

- (void)representativeCell:(RepresentativeCell *)representativeCell didTap:(Representative *)representative{
    if (representative.selected == NO) {
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) YES;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = NO;
        [self.selectedReps addObject:representative];
    } else {
        UIColor *color = [UIColor clearColor];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = YES;
        [self.selectedReps removeObject:representative];
    }
    if (self.selectedReps.count == 0) {
        self.counterView.hidden = YES;
    } else {
        self.counterView.hidden = NO;
        self.counterLabel.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.selectedReps.count];
    }
}

- (void) showSingleEmail {
    self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
    self.mailComposeViewController.mailComposeDelegate = self;
    Representative *representative = self.selectedReps[0];
//    Representative *representative = representativeCell.representative;
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    if (representative.email != nil) {
        [emails addObject:representative.email];
    }
    NSString *bodyHeader = @"Dear ";
    bodyHeader = [bodyHeader stringByAppendingString:representative.role];
    bodyHeader = [bodyHeader stringByAppendingString:@" "];
    bodyHeader = [bodyHeader stringByAppendingString:representative.name];
    bodyHeader = [bodyHeader stringByAppendingString:@", "];
    UIColor *color = [UIColor clearColor];
//    representativeCell.checkView.backgroundColor = color;
    representative.selected = (BOOL * _Nonnull) NO;
//    UIView *subview = representativeCell.checkView.subviews[0];
//    subview.hidden = YES;
    bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, @"My name is "];
    bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].firstName];
    bodyHeader = [bodyHeader stringByAppendingString:@" "];
    bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].lastName];
    bodyHeader = [bodyHeader stringByAppendingString:@" and I am from "];
    bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].city];
    bodyHeader = [bodyHeader stringByAppendingString:@", "];
    bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].state];
    bodyHeader = [bodyHeader stringByAppendingString:@". "];
    if (self.currentTemplate != nil) {
        bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, self.currentTemplate.body];
    }
    bodyHeader = [NSString stringWithFormat:@"%@\n\n%@\n\n%@ %@",bodyHeader, @"Sincerely but not silently,", [User currentUser].firstName, [User currentUser].lastName];
    [self.selectedReps removeObjectAtIndex:0];
    [self.mailComposeViewController setToRecipients:emails];
    [self.mailComposeViewController setMessageBody:bodyHeader isHTML:false];
    [self presentViewController:self.mailComposeViewController animated:YES completion:nil];
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
    } else if (MFMailComposeViewController.canSendMail) {
        Boolean properSelections = true;
        for (Representative *representative in self.selectedReps) {
            if (representative.email == nil) {
                properSelections = false;
            }
        }
        if (properSelections) {
            if ([User currentUser].sendIndividually) {
                [self showSingleEmail];
            } else {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                mailComposeViewController.mailComposeDelegate = self;
                NSMutableArray *emails = [[NSMutableArray alloc] init];
                NSString *bodyHeader = @"Dear ";
                for (Representative *representative in self.selectedReps) {
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
                    UIColor *color = [UIColor clearColor];
//                    representativeCell.checkView.backgroundColor = color;
                    representative.selected = (BOOL * _Nonnull) NO;
//                    UIView *subview = representativeCell.checkView.subviews[0];
//                    subview.hidden = YES;
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

                if (self.currentTemplate != nil) {
                    bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, self.currentTemplate.body];
                }
                bodyHeader = [NSString stringWithFormat:@"%@\n\n%@\n\n%@ %@",bodyHeader, @"Sincerely but not silently,", [User currentUser].firstName, [User currentUser].lastName];
                [self.selectedReps removeAllObjects];
                [mailComposeViewController setToRecipients:emails];
                [mailComposeViewController setMessageBody:bodyHeader isHTML:false];
                [self presentViewController:mailComposeViewController animated:YES completion:nil];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"At least one of your selected officials does not have an email available."
                          message:@"Please ensure each of your selected officials displays email verification and try again."
           preferredStyle:(UIAlertControllerStyleAlert)];
           // create an OK action
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
           // add the OK action to the alert controller
           [alert addAction:okAction];
           [self presentViewController:alert animated:YES completion:nil];
        }
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
    [self.tableView reloadData];
    if (result == MFMailComposeResultSent) {
        User *user = [User currentUser];
        int val = [user.letterCount intValue];
        user.letterCount = [NSNumber numberWithInt:(val + 1)];
        
        int senderInt = [self.currentTemplate.senderCount intValue];
        self.currentTemplate.senderCount = [NSNumber numberWithInt:(senderInt + 1)];
        [user saveInBackground];
    }
    self.counterView.hidden = YES;
   [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.selectedReps.count > 0 && [User currentUser].sendIndividually) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        Representative *representative = self.selectedReps[0];
        NSArray *emails = @[representative.email];
        NSString *bodyHeader = @"Dear ";
        bodyHeader = [bodyHeader stringByAppendingString:representative.role];
        bodyHeader = [bodyHeader stringByAppendingString:@" "];
        bodyHeader = [bodyHeader stringByAppendingString:representative.name];
        bodyHeader = [bodyHeader stringByAppendingString:@", "];
        UIColor *color = [UIColor clearColor];
//        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
//        UIView *subview = representativeCell.checkView.subviews[0];
//        subview.hidden = YES;
        bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, @"My name is "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].firstName];
        bodyHeader = [bodyHeader stringByAppendingString:@" "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].lastName];
        bodyHeader = [bodyHeader stringByAppendingString:@" and I am from "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].city];
        bodyHeader = [bodyHeader stringByAppendingString:@", "];
        bodyHeader = [bodyHeader stringByAppendingString:[User currentUser].state];
        bodyHeader = [bodyHeader stringByAppendingString:@". "];
        if (self.currentTemplate != nil) {
            bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, self.currentTemplate.body];
        }
        bodyHeader = [NSString stringWithFormat:@"%@\n\n%@\n\n%@ %@",bodyHeader, @"Sincerely but not silently,", [User currentUser].firstName, [User currentUser].lastName];
        [self.selectedReps removeObjectAtIndex:0];
        [mailComposeViewController setToRecipients:emails];
        [mailComposeViewController setMessageBody:bodyHeader isHTML:false];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.currentTemplate != nil) {
        self.navigationItem.title = @"Select Officials";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
        self.logoutButton.tintColor = [UIColor clearColor];
        self.logoutButton.enabled = NO;
    } else {
        self.navigationItem.title = @"writivist";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:45], NSForegroundColorAttributeName : [UIColor labelColor]};
        self.logoutButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
        self.logoutButton.enabled = YES;
    }

    if (self.tutorialManager) {
        [self.tutorialManager updateTutorial];
    }
}


-(NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index {
    if (index == 1) {
        RepresentativeCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        return @[cell.stackView];
    } else if (index == 2) {
        return @[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]];
    } else if (index == 3) {
        return @[[self.navigationItem.rightBarButtonItems[0] valueForKey:@"view"]];
    } else if (index == 4) {
        return @[[self.navigationItem.rightBarButtonItems[1] valueForKey:@"view"]];
    }

    return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
    if (index == 0) {
        return @[@"Welcome to the Writivist Tutorial!"];
    } else if (index == 1) {
        return @[@"Call your representatives and visit their website to demand change or navigate to their social media to evaluate their stance on social and political issues."];
    } else if (index == 2) {
        return @[@"Tap on this cell!"];
    } else if (index == 3) {
        return @[@"Use this button to compose emails to selected reps."];
    } else if (index == 4) {
        return @[@"Use this button to print letters to mail selected reps."];
    } else if (index == 5) {
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
    if (index == 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

-(void)tutorialPerformAction:(NSInteger)index {
    if (index == 2) {
        RepresentativeCell *repCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self representativeCell:repCell didTap:self.representatives[3]];
        repCell.representative.selected = (BOOL * _Nonnull) YES;
    } else if (index == 3) {
        if (MFMailComposeViewController.canSendMail) {
            [self showSingleEmail];
            [self performSelector:@selector(dismissEmail:) withObject:self.mailComposeViewController afterDelay:3];
        }
    } else if (index == 4) {
        [self performSegueWithIdentifier:@"toPrint" sender:nil];
    }
}

- (void) dismissEmail: (MFMailComposeViewController *) mailComposeViewController {
    [mailComposeViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index {
    if (index == 3 || index == 4) {
        return @[@(TNTutorialTextPositionBottom)];
    } else {
        return @[@(TNTutorialTextPositionTop)];
    }
}

-(CGFloat)tutorialPreActionDelay:(NSUInteger)index {
    if (index == 4 && MFMailComposeViewController.canSendMail) {
        return 3;
    } else {
        return 0;
    }
}

- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
}

- (NSInteger)tutorialMaxIndex {
    return 5;
}

- (BOOL)tutorialHasSkipButton:(NSInteger)index {
    return YES;
}

- (NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index {
    if (index == 0) {
        return @[[UIFont systemFontOfSize:35.f weight:UIFontWeightBold]];
    }

    return @[[UIFont systemFontOfSize:17.f]];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toPrint"]) {
        PrintViewController *printViewController = [segue destinationViewController];
        NSMutableArray *printReps = [[NSMutableArray alloc] init];
        for (Representative *representative in self.selectedReps) {
            [printReps addObject:representative];
        }
        printViewController.representatives = printReps;
        printViewController.temp = self.currentTemplate;
        if (self.tutorialManager) {
            printViewController.isTutorial = (BOOL * _Nonnull) YES;
        }
    }
}


@end
