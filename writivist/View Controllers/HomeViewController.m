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
#import "PrintViewController.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, RepresentativeCellDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSMutableArray *selectedReps;
@property (weak, nonatomic) IBOutlet UIView *counterView;
@property (weak, nonatomic) IBOutlet UIView *internalView;
@property (nonatomic) NSMutableArray *federalReps;
@property (nonatomic) NSMutableArray *stateReps;
@property (nonatomic) NSMutableArray *countyReps;
@property (nonatomic) NSMutableArray *cityReps;
//@property (nonatomic, strong) JGProgressHUD *spinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation HomeViewController

NSArray *levels;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    levels = @[@"Federal", @"State", @"County", @"City"];
    
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
        self.navigationItem.title = @"select reps.";
        self.logoutButton.tintColor = [UIColor clearColor];
        self.logoutButton.enabled = NO;
    } else {
        self.navigationItem.title = @"let's write.";
        self.logoutButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
        self.logoutButton.enabled = YES;
    }
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor labelColor]};
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
        for (RepresentativeCell *repCell in self.selectedReps) {
            if (repCell.representative.address == nil) {
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

- (void)viewDidDisappear:(BOOL)animated {
    for (RepresentativeCell *representativeCell in self.selectedReps) {
        Representative *representative = representativeCell.representative;
        UIColor *color = [UIColor clearColor];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = YES;
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
    NSString *key = [[NSProcessInfo processInfo] environment][@"key"];
    NSString *targetUrl = @"https://www.googleapis.com/civicinfo/v2/representatives?key=";
    targetUrl = [targetUrl stringByAppendingString:key];
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
    if (representative.email == nil) {
        cell.emailView.hidden = YES;
    } else {
        cell.emailView.hidden = NO;
    }
    if (representative.address == nil) {
        cell.printView.hidden = YES;
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
        [self.selectedReps addObject:representativeCell];
    } else {
        UIColor *color = [UIColor clearColor];
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
        for (RepresentativeCell *repCell in self.selectedReps) {
            if (repCell.representative.email == nil) {
                properSelections = false;
            }
        }
        if (properSelections) {
            if ([User currentUser].sendIndividually) {
                MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                mailComposeViewController.mailComposeDelegate = self;
                RepresentativeCell *representativeCell = self.selectedReps[0];
                Representative *representative = representativeCell.representative;
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
                representativeCell.checkView.backgroundColor = color;
                representative.selected = (BOOL * _Nonnull) NO;
                UIView *subview = representativeCell.checkView.subviews[0];
                subview.hidden = YES;
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
                [self.selectedReps removeObjectAtIndex:0];
                [mailComposeViewController setToRecipients:emails];
                [mailComposeViewController setMessageBody:bodyHeader isHTML:false];
                [self presentViewController:mailComposeViewController animated:YES completion:nil];
            } else {
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
                    UIColor *color = [UIColor clearColor];
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

                if (self.currentTemplate != nil) {
                    bodyHeader = [NSString stringWithFormat:@"%@\n\n%@",bodyHeader, self.currentTemplate.body];
                }
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
        RepresentativeCell *representativeCell = self.selectedReps[0];
        Representative *representative = representativeCell.representative;
        NSArray *emails = @[representative.email];
        NSString *bodyHeader = @"Dear ";
        bodyHeader = [bodyHeader stringByAppendingString:representative.role];
        bodyHeader = [bodyHeader stringByAppendingString:@" "];
        bodyHeader = [bodyHeader stringByAppendingString:representative.name];
        bodyHeader = [bodyHeader stringByAppendingString:@", "];
        UIColor *color = [UIColor clearColor];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = YES;
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
        [self.selectedReps removeObjectAtIndex:0];
        [mailComposeViewController setToRecipients:emails];
        [mailComposeViewController setMessageBody:bodyHeader isHTML:false];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    } else if ([User currentUser].sendIndividually) {
        self.currentTemplate = nil;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toPrint"]) {
        PrintViewController *printViewController = [segue destinationViewController];
        NSMutableArray *printReps = [[NSMutableArray alloc] init];
        for (RepresentativeCell *cell in self.selectedReps) {
            [printReps addObject:cell.representative];
        }
        printViewController.representatives = printReps;
        printViewController.temp = self.currentTemplate;
    }
}


@end
