//  Template.h
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "User.h"
@interface Template : PFObject<PFSubclassing>

@property (nonatomic, strong) User * _Nonnull author;
@property (nonatomic, strong) NSNumber  * _Nonnull likeCount;
@property (nonatomic, strong) NSNumber  * _Nonnull senderCount;
@property (nonatomic, strong) NSString  * _Nonnull category;
@property (nonatomic, strong) NSString  * _Nonnull body;
@property (nonatomic, strong) NSString  * _Nonnull title;
@property (nonatomic) bool selected;
@property (nonatomic) BOOL isPrivate;

+ (void) postUserTemplate: ( NSString * _Nullable )body withCategory: ( NSString * _Nullable )category withTitle: ( NSString * _Nullable )title withPrivacy: (BOOL *_Nonnull)isPrivate withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) postUserLike: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) postUserUnlike: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end
