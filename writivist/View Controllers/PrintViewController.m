//
//  PrintViewController.m
//  writivist
//
//  Created by dkaviani on 7/28/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "PrintViewController.h"
#import "Representative.h"
#import "User.h"

@interface PrintViewController ()

@end

@implementation PrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.printView.text = self.temp.body;
    self.printView.layer.cornerRadius = 5;
    self.printView.layer.borderWidth = 0.7;
    self.printView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (IBAction)printButton:(id)sender {
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printInfo = printInfo;
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, y"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *enterFix = [self.printView.text stringByReplacingOccurrencesOfString:@"\n"withString:@"<br>"];
    User *user = [User currentUser];
    NSString *markupText = @"";
    for (int i = 0; i < self.representatives.count; i += 1) {
        Representative *representative = self.representatives[i];
        NSString *repLetter = [NSString stringWithFormat:@"%@<br><br>%@ %@<br>%@ %@<br>%@, %@, %@<br><br>%@<br>%@<br>%@<br>%@, %@, %@<br><br>Dear %@ %@,<br><br>My name is %@ %@ and I am from %@, %@.<br><br>%@<br><br>Sincerely but not silently,<br>______________________________<br>%@ %@", dateStr, user.firstName, user.lastName, user.streetNumber, user.streetName, user.city, user.state, user.zipCode, representative.name, representative.role, representative.address[0][@"line1"], representative.address[0][@"city"], representative.address[0][@"state"], representative.address[0][@"zip"],  representative.role, representative.name, user.firstName, user.lastName, user.city, user.state, enterFix, user.firstName, user.lastName];
        if (i < self.representatives.count - 1) {
            repLetter = [repLetter stringByAppendingString:@"<p style='page-break-before: always;'>&nbsp;</p>"];
        }
        markupText = [markupText stringByAppendingString:repLetter];
    }
    
    UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:markupText];
    formatter.perPageContentInsets = UIEdgeInsetsMake(72, 72, 72, 72);
    printController.printFormatter = formatter;
    [printController presentAnimated:true completionHandler: nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
