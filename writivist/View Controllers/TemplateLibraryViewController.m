//
//  TemplateLibraryViewController.m
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "TemplateLibraryViewController.h"
#import "CategoryRow.h"
#import "HomeViewController.h"
#import "PreviewViewController.h"
#import "ProfileViewController.h"
#import "SectionTapper.h"
#import "CategoryViewController.h"
#import "SuggestedCell.h"
#import <HWPopController/HWPop.h>
#import "PopupViewController.h"

@interface TemplateLibraryViewController ()<UITableViewDelegate, UITableViewDataSource, ProfileDelegate, ReportDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *category;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation TemplateLibraryViewController

NSString *CellIdentifier = @"CategoryRow";
NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    self.categories = @[@"for you", @"black lives matter", @"climate action", @"financial justice", @"islamophobia", @"topic", @"topic", @"topic", @"topic"];
    self.filteredData = self.categories;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    self.navigationItem.title = @"Template Library";
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};
    
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightLight];
    
    UIImage *previewImageName = [UIImage systemImageNamed:@"doc.text" withConfiguration:configuration];
    UIButton * previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewButton setImage:previewImageName forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(previewButton) forControlEvents:UIControlEventTouchUpInside];
    previewButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    previewButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *previewBarButton = [[UIBarButtonItem alloc] initWithCustomView:previewButton];
    
    UIImage *doneImageName = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    UIButton * doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:doneImageName forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchUpInside];
    doneButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    doneButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    UIImage *shareImageName = [UIImage systemImageNamed:@"square.and.arrow.up" withConfiguration:configuration];
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:shareImageName forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButton) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    shareButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithCustomView:shareButton];

    self.navigationItem.rightBarButtonItems  = @[doneBarButton, shareBarButton, previewBarButton];
}

- (void)reportTemplateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull Template *)temp {
    PopupViewController *pop1ViewController = [PopupViewController new];
    HWPopController *popController = [[HWPopController alloc] initWithViewController:pop1ViewController];
    // popView position
    popController.popPosition = HWPopPositionCenter;
    pop1ViewController.temp = temp;
    [popController setPopType:HWPopTypeSlideInFromTop];
    [popController presentInViewController:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filteredData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (void)shareButton {
    if (self.currentTemplate == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No template selected."
               message:@"Please select a template to share."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        NSString *shareString = @"Check out this letter hosted on the app Writivist! Share it with your representatives and download Writivist on the App Store to get in touch with your elected officials in seconds.";
        shareString = [NSString stringWithFormat:@"%@\n\n%@",shareString, self.currentTemplate.title];
        shareString = [NSString stringWithFormat:@"%@\n\n%@",shareString, self.currentTemplate.body];
        NSArray *activityItems = @[shareString];
        UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityViewControntroller.excludedActivityTypes = @[];
        if (UIUserInterfaceIdiomPad) {
            activityViewControntroller.popoverPresentationController.sourceView = self.view;
            activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
        }
        [self presentViewController:activityViewControntroller animated:true completion:nil];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category = self.categories[indexPath.section];
    switch (indexPath.section) {
        case 0:{
            SuggestedCell *staticCell = (SuggestedCell *) [tableView dequeueReusableCellWithIdentifier:@"SuggestedCell"];
            staticCell.templateLibrary = self;
            [staticCell.spinner startAnimating];
            [staticCell setCategory:category];
            return staticCell;
            break;
        }
        default:{
            CategoryRow *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.templateLibrary = self;
            [cell.spinner startAnimating];
            [cell setCategory:category];
            return cell;
        }
    }
}

- (void) refresh {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *string = self.filteredData[section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    
    if (![string isEqual:@"for you"]) {
        SectionTapper *singleTapRecognizer = [[SectionTapper alloc] initWithTarget:self action:@selector(handleGesture:)];
        [singleTapRecognizer setDelegate:self];
        singleTapRecognizer.numberOfTouchesRequired = 1;
        singleTapRecognizer.numberOfTapsRequired = 1;
        singleTapRecognizer.data = string;
        [view addGestureRecognizer:singleTapRecognizer];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 50)];
    [label setFont: [UIFont fontWithName:@"Helvetica" size:25]];
    [label setText:string];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];
    [view setBackgroundColor:[[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:0.75]];
    return view;
}

-(void) handleGesture:(SectionTapper *)gestureRecognizer {
    self.category = gestureRecognizer.data;
    [self performSegueWithIdentifier:@"toCategory" sender:nil];
}

- (void)previewButton {
    if (self.currentTemplate == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No template selected."
               message:@"Please select a template to preview."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        [self performSegueWithIdentifier:@"preview" sender:nil];
    }
}
- (void) doneButton {
    if (self.currentTemplate == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No template selected."
               message:@"Please select a template to use in your message. If you'd like to write a message from scratch, navigate home and select your representatives from there."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        [self performSegueWithIdentifier:@"selectedTemplate" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (void)profileTemplateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull User *)user {
    self.user = user;
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSString *categoryTitle = evaluatedObject;
            return [categoryTitle containsString:searchText];
        }];
        self.filteredData = [self.categories filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredData = self.categories;
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedTemplate"]) {
        HomeViewController *homeViewController = [segue destinationViewController];
        homeViewController.currentTemplate = self.currentTemplate;
        homeViewController.currentTemplate = self.currentTemplate;
        TemplateCell *current = self.currentCell;
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        current.checkView.backgroundColor = color;
        UIView *subview = current.checkView.subviews[0];
        subview.hidden = YES;
        self.currentCell = nil;
    }
    if ([segue.identifier isEqualToString:@"preview"]) {
        PreviewViewController *previewViewController = [segue destinationViewController];
        previewViewController.templateTitle = self.currentTemplate.title;
        previewViewController.body = self.currentTemplate.body;
    }
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = self.user;
    }
    if ([segue.identifier isEqualToString:@"toCategory"]) {
        CategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.category = self.category;
    }

}

@end
