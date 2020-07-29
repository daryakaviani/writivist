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
}

- (IBAction)printButton:(id)sender {
    Representative *representative = self.representatives[0];
    NSDate *date = [[NSDate alloc] init];
    NSString *introString = representative.address[0][@"city"];
    introString = [introString stringByAppendingFormat:@"%@", @", "];
    introString = [introString stringByAppendingFormat:@"%@", @" "];
    introString = [introString stringByAppendingFormat:@"%@", representative.address[0][@"state"]];
    introString = [introString stringByAppendingFormat:@"%@", @", "];
    introString = [introString stringByAppendingFormat:@"%@", representative.address[0][@"zip"]];
    
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;

    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printInfo = printInfo;
    
    NSString *enterFix = [self.printView.text stringByReplacingOccurrencesOfString:@"\n"withString:@"<br>"];
    User *user = [User currentUser];
    NSString *markupText = [NSString stringWithFormat:@"%@<br><br>%@ %@<br>%@ %@<br>%@, %@, %@<br><br>%@<br>%@<br>%@<br>%@<br><br>Dear %@ %@,<br><br>My name is %@ %@ and I am from %@, %@.<br><br>%@<br><br>Sincerely but not silently,<br><br>______________________________<br><br>%@ %@<p style='page-break-before: always;'>&nbsp;</p>", date, user.firstName, user.lastName, user.streetNumber, user.streetName, user.city, user.state, user.zipCode, representative.name, representative.role, representative.address[0][@"line1"], introString, representative.role, representative.name, user.firstName, user.lastName, user.city, user.state, enterFix, user.firstName, user.lastName];
    
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
