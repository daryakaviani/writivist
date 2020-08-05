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
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface MapContentViewController ()<UITableViewDelegate, UITableViewDataSource, MapContentCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) NSMutableArray *representatives;


@end

@implementation MapContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.representatives = [[NSMutableArray alloc] init];
    [self fetchAddresses];
    self.barView.layer.cornerRadius = 5;
    self.barView.layer.masksToBounds = true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MapContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapContentCell"];
    Representative *representative = self.representatives[indexPath.row];
    cell.representative = representative;
    cell.delegate = self;
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
        NSMutableArray *representatives  = [Representative representativesWithArray:representativeArray];
        for (Representative *representative in representatives) {
            if (representative.address != nil) {
                [self.representatives addObject:representative];
            }
        }
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

- (void)mapContentCell:(nonnull MapContentCell *)mapContentCell didTap:(nonnull Representative *)representative {
    NSString *baseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?address=";
        NSString *keyUrl = @"&key=";
        NSString *key = [[NSProcessInfo processInfo] environment][@"key"];
        keyUrl = [keyUrl stringByAppendingString:key];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"line1"]];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", @","];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", @"+"];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"city"]];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", @","];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", @"+"];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"state"]];
        baseUrl = [baseUrl stringByAppendingFormat:@"%@", keyUrl];
        baseUrl = [baseUrl stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:baseUrl]];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
          ^(NSData * _Nullable data,
            NSURLResponse * _Nullable response,
            NSError * _Nullable error) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *results = [JSON valueForKey:@"results"];
            NSDictionary *geocodingDictionary = [results valueForKey:@"geometry"];
            NSDictionary *location = [geocodingDictionary valueForKey:@"location"][0];
            NSString *latitude = [location valueForKey:@"lat"];
            NSString *longitude = [location valueForKey:@"lng"];
            NSLog(@"%@", latitude);
            NSLog(@"%@", longitude);
            CGFloat lat;
            CGFloat lng;
            lat = [latitude floatValue];
            lng = [longitude floatValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(lat, lng) zoom:18];
                [self.mapViewController.mapView setCamera:camera];
                self.mapViewController.trayView.center = self.mapViewController.trayDown;
            });
        }] resume];
}


@end
