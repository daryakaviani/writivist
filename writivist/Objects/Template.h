//  Template.h
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
@interface Template : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser * _Nonnull author;
@property (nonatomic, strong) NSNumber  * _Nonnull likeCount;
@property (nonatomic, strong) NSString  * _Nonnull category;
@property (nonatomic, strong) NSString  * _Nonnull body;
@property (nonatomic, strong) NSString  * _Nonnull title;
@property (nonatomic) bool selected;

+ (void) postUserTemplate: ( NSString * _Nullable )body withCategory: ( NSString * _Nullable )category withTitle: ( NSString * _Nullable )title withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
