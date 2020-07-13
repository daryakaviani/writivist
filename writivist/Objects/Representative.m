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
        self.role = dictionary[@"role"];
        self.party = dictionary[@"party"];
        self.profileString = dictionary[@"photoUrl"];
        NSArray *phones = dictionary[@"phones"];
        self.phone = phones[0];
        NSArray *websites = dictionary[@"urls"];
        self.website = websites[0];
        //NSArray *socialMedia = dictionary[@"channels"];
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
