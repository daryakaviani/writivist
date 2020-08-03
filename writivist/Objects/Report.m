//
//  Report.m
//  writivist
//
//  Created by dkaviani on 8/3/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "Report.h"

@implementation Report

@dynamic reason;
@dynamic temp;
@dynamic author;

+ (void) postUserReport: ( Template * _Nonnull)temp withReason: ( NSString * _Nullable )reason withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Report *newReport = [Report new];
    newReport.author = [User currentUser];
    newReport.reason = reason;
    newReport.temp = temp;
    [newReport saveInBackgroundWithBlock: completion];
}

+ (nonnull NSString *)parseClassName {
    return @"Report";
}

@end
