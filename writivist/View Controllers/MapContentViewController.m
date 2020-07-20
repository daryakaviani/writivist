//
//  MapContentViewController.m
//  writivist
//
//  Created by dkaviani on 7/20/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "MapContentViewController.h"
#import "Representative.h"
#import "MapContentCell.h"
#import "User.h"

@interface MapContentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (nonatomic, strong) NSArray *offices;

@end

@implementation MapContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchAddresses];
    self.barView.layer.cornerRadius = 5;
    self.barView.layer.masksToBounds = true;
    self.tableView.allowsSelection = false;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MapContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapContentCell"];
    Representative *representative = self.representatives[indexPath.row];
    cell.roleLabel.text = representative.role;
    cell.nameLabel.text = representative.name;
    NSString *address = representative.address[0][@"line1"];
    if (representative.address != nil) {
       address = [address stringByAppendingFormat:@"%@", @" "];
       address = [address stringByAppendingFormat:@"%@", representative.address[0][@"city"]];
       address = [address stringByAppendingFormat:@"%@", @", "];
       address = [address stringByAppendingFormat:@"%@", representative.address[0][@"state"]];
       address = [address stringByAppendingFormat:@"%@", @" "];
       address = [address stringByAppendingFormat:@"%@", representative.address[0][@"zip"]];
   }
    cell.addressLabel.text = address;
    return cell;
}

- (void)fetchAddresses {
    User *user = [User currentUser];
    NSString *location = user.streetNumber;
    location = [location stringByAppendingString:@"%20"];
    location = [location stringByAppendingString:user.streetName];
    location = [location stringByAppendingString:@".%20"];
    location = [location stringByAppendingString:user.city];
    location = [location stringByAppendingString:@"%20"];
    location = [location stringByAppendingString:user.state];
    location = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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
        NSMutableArray *representatives  = [Representative representativesWithArray:representativeArray];
        self.representatives = representatives;
        NSArray *officesArray = [JSON valueForKey:@"offices"];
        self.offices = officesArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < self.representatives.count; i += 1) {
                Representative *representative = self.representatives[i];
               for (NSDictionary *dictionary in self.offices) {
                   for (NSString *index in dictionary[@"officialIndices"]) {
                       NSString *repIndex = [NSString stringWithFormat: @"%d", i];
                       NSString *officialIndex = [NSString stringWithFormat: @"%@", index];
                       if (repIndex == officialIndex) {
                           representative.role = dictionary[@"name"];
                       }
                   }
               }
            }
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
            NSLog(@"%@", self.representatives);
    }] resume];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.representatives.count;
}

@end
