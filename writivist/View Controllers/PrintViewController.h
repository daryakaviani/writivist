//
//  PrintViewController.h
//  writivist
//
//  Created by dkaviani on 7/28/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrintViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *printView;
@property (nonatomic, strong) NSArray *representatives;
@property (nonatomic, strong) Template *temp;
@property (nonatomic) BOOL *isTutorial;

@end

NS_ASSUME_NONNULL_END
