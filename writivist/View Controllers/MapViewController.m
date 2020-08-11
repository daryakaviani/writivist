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
#import "TNTutorialManager.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface MapViewController ()<TNTutorialManagerDelegate>
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) NSArray *offices;
@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic) CGPoint trayOriginalCenter;
@property (nonatomic) CGPoint trayUp;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;
@property (nonatomic, strong) MapContentViewController *contentViewController;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Find My Reps";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
    [self.trayView setFrame:CGRectMake(0, self.view.frame.size.height/3, self.view.frame.size.width, 2*self.view.frame.size.height/3)];
    self.trayUp = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - self.trayView.frame.size.height/2);
    self.trayDown = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height + self.trayView.frame.size.height/2 - 115);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.trayView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(20.0, 20.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.trayView.layer.mask = maskLayer;
    self.trayView.center = self.trayDown;
    [self startUserLocationSearch];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanTray:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.trayView addGestureRecognizer:panRecognizer];
    
    if ([TNTutorialManager shouldDisplayTutorial:self]) {
        self.tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
    } else {
        self.tutorialManager = nil;
    }
    [self.locationManager requestWhenInUseAuthorization];
    
    if (![self connected]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        [self startUserLocationSearch];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.locationManager.location.coordinate zoom:8];
        self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
        [self.view addSubview:self.mapView];
        [self.view insertSubview:self.trayView aboveSubview:self.mapView];
        [self constrainMap];
        
        [self fetchAddresses];
    }
}
- (IBAction)refreshButton:(id)sender {
    [self viewDidLoad];
    if ([self connected]) {
        [self.contentViewController fetchAddresses];
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
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
    keyUrl = [keyUrl stringByAppendingString:@"AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls"];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.tutorialManager) {
        [self.tutorialManager updateTutorial];
    }
}


- (NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index {
    if (index == 1) {
        return @[self.trayView];
    } else if (index == 2) {
        return @[[self.contentViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    } else if (index == 3) {
        return @[[self.navigationItem.rightBarButtonItem valueForKey:@"view"]];
    }

    return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
    if (index == 0) {
        return @[@"Welcome to Find My Reps, where you can visualize the geographic vicinity of your elected officials and pinpoint their addresses for letter-mailing purposes."];
    } else if (index == 1) {
        return @[@"Swipe up to view your representatives."];
    } else if (index == 2) {
        return @[@"Tap this cell to view the corresponding elected official's location."];
    } else if (index == 3) {
        return @[@"Tap here to recenter your map to your current location."];
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
}

-(void)tutorialPerformAction:(NSInteger)index {
    if (index == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.trayView.center = self.trayUp;
        }];
    } else if (index == 2) {
        MapContentCell *cell = [self.contentViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.contentViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.contentViewController mapContentCell:cell didTap:cell.representative];
        [UIView animateWithDuration:0.3 animations:^{
            self.trayView.center = self.trayDown;
            [self centerLocation:self];
        }];
    } else if (index == 3) {
        [self.contentViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.trayView.center = self.trayDown;
            [self centerLocation:self];
        }];
    }
}


- (NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index {
    if (index == 3) {
        return @[@(TNTutorialTextPositionBottom)];
    }
    return @[@(TNTutorialTextPositionTop)];
}

- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
}

- (NSInteger)tutorialMaxIndex {
    return 4;
}

- (CGFloat)tutorialPreActionDelay:(NSUInteger)index {
    if (index == 3) {
        return 1.5;
    } else {
        return 0;
    }
}

- (BOOL)tutorialHasSkipButton:(NSInteger)index {
    return YES;
}

- (NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index {
    return @[[UIFont systemFontOfSize:17.f]];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"contentSegue"]) {
        MapContentViewController *contentViewController = [segue destinationViewController];
        contentViewController.mapViewController = self;
        self.contentViewController = contentViewController;
    }
}


@end
