//
//  Report.h
//  writivist
//
//  Created by dkaviani on 8/3/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@interface Report : PFObject<PFSubclassing>

@property (nonatomic, strong) Template * _Nonnull temp;
@property (nonatomic, strong) User * _Nonnull author;
@property (nonatomic, strong) NSString  * _Nonnull reason;

+ (void) postUserReport: ( Template * _Nonnull)temp withReason: ( NSString * _Nullable )reason withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
