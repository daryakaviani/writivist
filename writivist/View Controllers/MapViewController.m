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
#import "MapContentViewController.h"


@interface MapViewController ()
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic) CGPoint trayOriginalCenter;
@property (nonatomic) CGPoint trayUp;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startUserLocationSearch];
    self.navigationItem.title = @"find my reps.";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor labelColor]};
    
    [self.locationManager requestAlwaysAuthorization];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.locationManager.location.coordinate zoom:8];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    [self.view addSubview:self.mapView];
    [self.view insertSubview:self.trayView aboveSubview:self.mapView];
    [self constrainMap];
    
    [self fetchAddresses];
    
    self.trayUp = CGPointMake(self.view.frame.size.width/2, 0.6 * self.view.frame.size.height);
    self.trayDown = CGPointMake(self.view.frame.size.width/2, 1.2 * self.view.frame.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.trayView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(20.0, 20.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.trayView.layer.mask = maskLayer;
    self.trayView.center = self.trayDown;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTray:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.trayView addGestureRecognizer:panRecognizer];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    self.trayUp = CGPointMake(size.width/2, 0.6 * size.height);
    self.trayDown = CGPointMake(size.width/2, 1.2 * size.height);
    NSLog(@"%f", size.height);
    NSLog(@"%f", size.width);
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.trayView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(20.0, 20.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.view.bounds;
        maskLayer.path  = maskPath.CGPath;
        self.trayView.layer.mask = maskLayer;
        self.trayView.center = self.trayDown;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTray:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self.trayView addGestureRecognizer:panRecognizer];
        
    } completion:^(id  _Nonnull context) {
        
        // after rotation
        
    }];
}
- (IBAction)centerLocation:(id)sender {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.locationManager.location.coordinate zoom:8];
    [self.mapView setCamera:camera];
    self.trayView.center = self.trayDown;
}

- (void) constrainMap {
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
       [self.mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
       [self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
       [self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
//        [NSLayoutConstraint activateConstraints:@[
//            [self.trayView.leadingAnchor constraintEqualToAnchor:self.mapView.leadingAnchor],
//           [self.trayView.trailingAnchor constraintEqualToAnchor:self.mapView.trailingAnchor],
//            [self.trayView.bottomAnchor constraintEqualToAnchor:self.mapView.bottomAnchor],
//            [self.trayView.heightAnchor constraintEqualToConstant:self.mapView.layer.frame.size.height/2]
//        ]];
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
- (IBAction)didPanTray:(UIPanGestureRecognizer*)sender {
    CGPoint translation = [sender translationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.trayOriginalCenter = self.trayView.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.trayView.center = CGPointMake(self.trayOriginalCenter.x, self.trayOriginalCenter.y + translation.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if ([sender velocityInView:self.view].y > 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.trayView.center = self.trayDown;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.trayView.center = self.trayUp;
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
    self.latitude = self.locationManager.location.coordinate.latitude;
    self.longitude = self.locationManager.location.coordinate.longitude;
}

- (void) addMarker:(Representative *) representative {
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
                if (representative.address != nil) {
                    [self addMarker:representative];
                }
            }
        });
    }] resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contentSegue"]) {
        MapContentViewController *contentViewController = [segue destinationViewController];
        contentViewController.mapViewController = self;
    }
}


@end
