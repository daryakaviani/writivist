//
//  MapViewController.m
//  writivist
//
//  Created by dkaviani on 7/17/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Representative.h"
#import "User.h"


@interface MapViewController ()
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) GMSMapView *mapView;
@end

@implementation MapViewController
//
//double latdouble;
//double londouble;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"find my reps.";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(37.3382, -121.8863) zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    [self fetchAddresses];
}
CGFloat lat;
CGFloat lng;
- (void) addMarker:(Representative *) representative {
    
    NSString *baseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?address=";
    NSString *keyUrl = @"&key=AIzaSyBF0K61_yqnXdJvNBSzyq2uTHJsNktnCZ0";
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"line1"]];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", @","];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", @"+"];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"city"]];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", @","];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", @"+"];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"state"]];
    baseUrl = [baseUrl stringByAppendingFormat:@"%@", keyUrl];
    baseUrl = [baseUrl stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    NSLog(@"%@", baseUrl);
//    NSString *targetUrl = @"https://maps.googleapis.com/maps/api/geocode/json?address=1567+Via+Campo+Aureo,+San+Jose,+CA&key=AIzaSyBF0K61_yqnXdJvNBSzyq2uTHJsNktnCZ0";
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
        lat = [latitude floatValue];
        lng = [longitude floatValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat, lng);
            marker.title = representative.name;
            marker.snippet = [representative.address componentsJoinedByString:@" "];
            marker.map = self.mapView;
            self.mapView.myLocationEnabled = YES;
            [self.view addSubview:self.mapView];
        });
    }] resume];
    
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
        NSMutableArray *representatives  = [Representative representativesWithArray:representativeArray];
        self.representatives = representatives;
        dispatch_async(dispatch_get_main_queue(), ^{
           for (Representative *representative in self.representatives) {
                [self addMarker:representative];
            }
        });
        
        
    }] resume];
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
