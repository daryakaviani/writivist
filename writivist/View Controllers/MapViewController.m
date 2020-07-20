//
//  MapViewController.m
//  writivist
//
//  Created by dkaviani on 7/17/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "Representative.h"
#import "User.h"


@interface MapViewController ()
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation MapViewController
//
//double latdouble;
//double londouble;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startUserLocationSearch];

    self.navigationItem.title = @"find my reps.";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
    
    [self.locationManager requestAlwaysAuthorization];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.locationManager.location.coordinate zoom:8];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    [self fetchAddresses];
}

- (void)startUserLocationSearch {
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{\
    [self.locationManager stopUpdatingLocation];
    self.latitude = self.locationManager.location.coordinate.latitude;
    self.longitude = self.locationManager.location.coordinate.longitude;
}

- (void) addMarker:(Representative *) representative {
    
    NSString *baseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?address=";
    NSString *keyUrl = @"&key=AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls";
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
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat, lng);
            marker.title = representative.name;
            NSString *baseUrl = representative.role;
            if (representative.address != nil) {
                baseUrl = [baseUrl stringByAppendingFormat:@"\n%@", representative.address[0][@"line1"]];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", @" "];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"city"]];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", @", "];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"state"]];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", @" "];
                baseUrl = [baseUrl stringByAppendingFormat:@"%@", representative.address[0][@"zip"]];
            }
            marker.snippet = baseUrl;
            if ([representative.party isEqualToString:@"Republican Party"]) {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
            } else if ([representative.party isEqualToString:@"Democratic Party"]) {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor systemBlueColor]];
            } else {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor whiteColor]];
            }
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
