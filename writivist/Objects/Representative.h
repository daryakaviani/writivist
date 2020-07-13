//
//  Representative.h
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Representative : NSObject

// MARK: Properties
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *party;
@property (nonatomic, strong) NSString *profileString;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSURL *website;
@property (nonatomic, strong) NSURL *email;
@property (nonatomic, strong) NSString *facebook;
@property (nonatomic, strong) NSString *twitter;

// Dictionary representing a representative
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)representativesWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
