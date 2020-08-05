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
#import "TNTutorialManager.h"

@interface TemplateLibraryViewController ()<UITableViewDelegate, UITableViewDataSource, ProfileDelegate, ReportDelegate, UISearchBarDelegate, TNTutorialManagerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *category;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;
@property (nonatomic, strong) NSMutableArray *sectionViews;

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
    self.sectionViews = [[NSMutableArray alloc] init];
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
    
    if ([TNTutorialManager shouldDisplayTutorial:self]) {
        self.tutorialManager = [[TNTutorialManager alloc] initWithDelegate:self blurFactor:0.1];
    } else {
        self.tutorialManager = nil;
    }
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
    [self.sectionViews addObject:view];
    
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


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.tutorialManager) {
        [self.tutorialManager updateTutorial];
    }
}


- (NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index {
    if (index == 0) {
        return @[self.tableView];
    } else if (index == 1) {
        CategoryRow *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        return @[cell];
    } else if (index == 2) {
        CategoryRow *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        return @[[cell.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    } else if (index == 3) {
        SuggestedCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        return @[cell];
    } else if (index == 4) {
        return @[self.searchBar];
    } else if (index == 5) {
        return @[self.sectionViews[2]];
    }

    return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
    if (index == 0) {
        return @[@"Welcome to the Template Library, a collection of prewritten templates regarding an array of social issues."];
    } else if (index == 1) {
        return @[@"Access the 20 most recent templates in each category."];
    } else if (index == 2) {
        return @[@"Favorite and bookmark templates and view the number of times a template has been saved or liked."];
    } else if (index == 3) {
        return @[@"Up here, check out trending templates tailored to your favorite categories."];
    } else if (index == 4) {
        return @[@"Here, you can search for particular categories."];
    } else if (index == 5) {
        return @[@"Tap any section header to view all templates in that category."];
    }
    return nil;
}

-(NSArray<TNTutorialEdgeInsets *> *)tutorialViewsEdgeInsets:(NSInteger)index {
    if (index == 1) {
        return @[TNTutorialEdgeInsetsMake(8, 8, 8, 8)];
    }

    return nil;
}

- (void)tutorialPreHighlightAction:(NSInteger)index {
//    if (index == 0) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    }
}

-(void)tutorialPerformAction:(NSInteger)index {
    if (index == 4) {
        self.searchBar.text = @"black lives matter";
        [self searchBar:self.searchBar textDidChange: @"black lives matter"];
    } else if (index == 5) {
        self.category = self.searchBar.text;
        [self performSegueWithIdentifier:@"toCategory" sender:nil];
    }
}


- (NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index {
    if (index == 5 || index == 6 || index == 7) {
        return @[@(TNTutorialTextPositionBottom)];
    }
    return @[@(TNTutorialTextPositionTop)];
}
//
//-(BOOL)tutorialWaitAfterAction:(NSInteger)index {
//    if (index == 5) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

-(CGFloat)tutorialPreActionDelay:(NSUInteger)index {
    if (index == 6) {
        return 1;
    } else {
        return 0;
    }
}


- (BOOL)tutorialShouldCoverStatusBar {
    return YES;
}

- (void)tutorialWrapUp {
    self.tutorialManager = nil;
}

- (NSInteger)tutorialMaxIndex {
    return 6;
}

- (BOOL)tutorialHasSkipButton:(NSInteger)index {
    return NO;
}

- (NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index {
    return @[[UIFont systemFontOfSize:17.f]];
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
