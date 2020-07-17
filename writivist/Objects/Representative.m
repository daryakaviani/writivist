//
//  Representative.m
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "Representative.h"

@implementation Representative

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.party = dictionary[@"party"];
        self.profileString = dictionary[@"photoUrl"];
        self.email = dictionary[@"emails"][0];
        self.phone = dictionary[@"phones"][0];
        self.website = dictionary[@"urls"][0];
        self.address = dictionary[@"address"];
        NSArray *channels = dictionary[@"channels"];
        for (NSDictionary *dictionary in channels) {
            if ([dictionary[@"type"]  isEqual: @"Facebook"]) {
                self.facebook = dictionary[@"id"];
            }
            if ([dictionary[@"type"]  isEqual: @"Twitter"]) {
                self.twitter = dictionary[@"id"];
            }
        }
    }
    return self;
}

+ (NSMutableArray *)representativesWithArray:(NSArray *)dictionaries{
    NSMutableArray *representatives = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Representative *representative = [[Representative alloc] initWithDictionary:dictionary];
        [representatives addObject:representative];
    }
    return representatives;
}

@end
