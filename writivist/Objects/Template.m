//  Post.m
#import "Template.h"
#import <Parse/Parse.h>
#import "User.h"

@implementation Template

@dynamic author;
@dynamic likeCount;
@dynamic senderCount;
@dynamic body;
@dynamic category;
@dynamic title;
@dynamic isPrivate;
@dynamic saveCount;
@dynamic selected;

+ (nonnull NSString *)parseClassName {
    return @"Template";
}

+ (void) postUserTemplate: ( NSString * _Nullable )body withCategory: ( NSString * _Nullable )category withTitle: ( NSString * _Nullable )title withPrivacy: (BOOL *_Nonnull)isPrivate withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Template *newTemplate = [Template new];
    newTemplate.author = [User currentUser];
    newTemplate.likeCount = @(0);
    newTemplate.senderCount = @(0);
    newTemplate.saveCount = @(0);
    newTemplate.body = body;
    newTemplate.category = category;
    newTemplate.title = title;
    newTemplate.isPrivate = isPrivate;
    [newTemplate saveInBackgroundWithBlock: completion];
}

+ (void) postUserLike: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFRelation *relation = [temp relationForKey:@"likedBy"];
    [relation addObject:user];
    int val = [temp.likeCount intValue];
    temp.likeCount = [NSNumber numberWithInt:(val + 1)];
    [temp saveInBackground];
}

+ (void) postUserUnlike: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFRelation *relation = [temp relationForKey:@"likedBy"];
    [relation removeObject:user];
    int val = [temp.likeCount intValue];
    temp.likeCount = [NSNumber numberWithInt:(val - 1)];
    [temp saveInBackground];
}

+ (void) postUserSave: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFRelation *relation = [temp relationForKey:@"savedBy"];
    [relation addObject:user];
    int val = [temp.saveCount intValue];
    temp.saveCount = [NSNumber numberWithInt:(val + 1)];
    [temp saveInBackground];
}

+ (void) postUserUnsave: ( User * _Nullable)user withTemplate: ( Template * _Nullable ) temp withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PFRelation *relation = [temp relationForKey:@"savedBy"];
    [relation removeObject:user];
    int val = [temp.saveCount intValue];
    temp.saveCount = [NSNumber numberWithInt:(val - 1)];
    [temp saveInBackground];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        NSLog(@"Image is nil");
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    // get image data and check if that is not nil
    if (!imageData) {
        NSLog(@"Image data is nil");
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.jpeg" data:imageData];
}

@end
