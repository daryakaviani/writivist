//
//  User.h
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : PFUser

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSMutableArray *templates;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) PFFileObject  *profilePicture;
@property (nonatomic, strong) NSNumber  *likeCount;
@property (nonatomic, strong) NSNumber  *templateCount;
@property (nonatomic, strong) NSNumber  *letterCount;
@property (nonatomic, strong) NSString *streetNumber;
@property (nonatomic, strong) NSString *streetName;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic) BOOL sendIndividually;

@end

NS_ASSUME_NONNULL_END
