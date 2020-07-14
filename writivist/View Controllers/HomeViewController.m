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

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, RepresentativeCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchRepresentatives];
}

- (IBAction)logoutButton:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        PFUser *test = [PFUser currentUser];
        
        NSLog(@" -- User is logged out -- %@", test.username);
    }];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

- (void)fetchRepresentatives {
    NSString *targetUrl = @"https://www.googleapis.com/civicinfo/v2/representatives?key=AIzaSyBF0K61_yqnXdJvNBSzyq2uTHJsNktnCZ0&address=1500%20Via%20Campo%20Aureo.%20San%20Jose%20CA";
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
        NSLog(@"%@", self.offices);
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
    cell.phoneLabel.text = representative.phone;
    cell.websiteLabel.text = representative.website;
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
    if (representative.email == nil) {
        cell.checkButton.hidden = YES;
    } else {
        cell.checkButton.hidden = NO;
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
    if (representative.selected == NO) {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) YES;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = NO;
        [self.selectedReps addObject:representative];
        NSLog(@"%@", self.selectedReps);
    } else {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        representativeCell.checkView.backgroundColor = color;
        representative.selected = (BOOL * _Nonnull) NO;
        UIView *subview = representativeCell.checkView.subviews[0];
        subview.hidden = YES;
        [self.selectedReps removeObject:representative];
        NSLog(@"%@", self.selectedReps);
    }
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
