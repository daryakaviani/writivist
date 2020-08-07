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
#import <TNTutorialManager.h>

@interface PrintViewController ()

@property (nonatomic, strong) TNTutorialManager *tutorialManager;

@end

@implementation PrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Print";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
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
        NSString *honorable = @"";
        if ([representative.role containsString:@"Senator"] || [representative.role containsString:@"Representative"] || [representative.role containsString:@"Mayor"] || [representative.role containsString:@"Supreme Court"] || [representative.role containsString:@"Governor"]) {
            honorable = @"The Honorable ";
        } else {
            honorable = @"";
        }
        NSString *repLetter = [NSString stringWithFormat:@"%@<br><br>%@ %@<br>%@ %@<br>%@, %@, %@<br><br>%@ %@<br>%@<br>%@<br>%@, %@, %@<br><br>Dear %@ %@,<br><br>My name is %@ %@ and I am from %@, %@.<br><br>%@<br><br>Sincerely but not silently,<br><br>______________________________<br><br>%@ %@", dateStr, user.firstName, user.lastName, user.streetNumber, user.streetName, user.city, user.state, user.zipCode, honorable, representative.name, representative.role, representative.address[0][@"line1"], representative.address[0][@"city"], representative.address[0][@"state"], representative.address[0][@"zip"],  representative.role, representative.name, user.firstName, user.lastName, user.city, user.state, enterFix, user.firstName, user.lastName];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isTutorial) {
        [self performSelector:@selector(dismissPrint) withObject:self afterDelay:2];
    }
}

- (void) dismissPrint {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tutorialMaxIndex {
    return 1;
}

- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
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
