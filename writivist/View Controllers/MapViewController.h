//
//  MapViewController.h
//  writivist
//
//  Created by dkaviani on 7/17/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic) CGPoint trayDown;
@property (weak, nonatomic) IBOutlet UIView *trayView;

@end

NS_ASSUME_NONNULL_END
