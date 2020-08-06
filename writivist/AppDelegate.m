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
#import "User.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(  NSDictionary *)launchOptions {
    [GMSPlacesClient provideAPIKey:@"AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls"];
    [GMSServices provideAPIKey:@"AIzaSyAEUwl_p-yu4m8pIgaoLu7axLJX71Oofls"];
    [IQKeyboardManager sharedManager].enable = YES;
        ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"myWritivistId";
        configuration.server = @"https://writivist.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:config];
    
    User *user = [User currentUser];
    if (user) {
        NSLog(@"Welcome back, %@", user.username);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        _window.rootViewController = tabBarController;
        [_window makeKeyAndVisible];
    }
    
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle

//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of
  // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and
  // it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and
  // invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state
  // information to restore your application to its current state in case it is terminated later. If your application
  // supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the active state; here you can undo many of the changes
  // made on entering the background.
}


@end
