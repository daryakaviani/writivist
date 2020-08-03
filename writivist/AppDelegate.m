//
//  AppDelegate.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(  NSDictionary *)launchOptions {
    NSString *key = [[NSProcessInfo processInfo] environment][@"key"];
    [GMSPlacesClient provideAPIKey:key];
    [GMSServices provideAPIKey:key];
    [IQKeyboardManager sharedManager].enable = YES;
        ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"myWritivistId";
        configuration.server = @"https://writivist.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:config];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
