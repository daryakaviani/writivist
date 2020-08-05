//
//  CategoryViewController.m
//  writivist
//
//  Created by dkaviani on 7/21/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "CategoryViewController.h"
#import "Template.h"
#import "TemplateCell.h"
#import <Parse/Parse.h>
#import "PreviewViewController.h"
#import "HomeViewController.h"
#import "User.h"
#import "ProfileViewController.h"
#import "InfiniteScrollActivityView.h"
#import "PopupViewController.h"
#import <HWPopController/HWPopController.h>
#import "TNTutorialManager.h"

@interface CategoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ProfileDelegate, ReportDelegate, UISearchBarDelegate, TemplateCellDelegate, TNTutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) TemplateCell *currentCell;
@property (nonatomic, strong) Template *currentTemplate;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) TNTutorialManager *tutorialManager;

@end

@implementation CategoryViewController
bool isMoreDataLoading = false;
InfiniteScrollActivityView* loadingMoreView;
int skip = 20;
int newTempCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spinner startAnimating];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    self.navigationItem.title = self.category;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor labelColor]};

    [self fetchTemplates];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing - layout.sectionInset.left - layout.sectionInset.right) / 2;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchTemplates) forControlEvents:UIControlEventValueChanged];
    
    // Set up Infinite Scroll loading indicator
    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreView.hidden = true;
    [self.collectionView addSubview:loadingMoreView];
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.collectionView.contentInset = insets;
    
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

- (void)doneButton {
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
        if (self.tutorialManager){
            [self performSelector:@selector(dismissShare:) withObject:activityViewControntroller afterDelay:1];
        }
    }
}

- (void) dismissShare: (UIActivityViewController *) activityViewController {
    [activityViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadMoreData {
    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"category" equalTo:self.category];
    query.limit = 20;
    query.skip = skip;
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            NSMutableArray *newTemplates = (NSMutableArray *) templates;
            newTempCount = (int) newTemplates.count;
            NSArray *newArray = [self.filteredData arrayByAddingObjectsFromArray:newTemplates];
            self.templates = (NSMutableArray *) newArray;
            self.filteredData = (NSMutableArray *) newArray;
            skip += templates.count;
            isMoreDataLoading = false;
            [loadingMoreView stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
     if(!isMoreDataLoading){
         // Calculate the position of one screen length before the bottom of the results
         int scrollViewContentHeight = self.collectionView.contentSize.height;
         int scrollOffsetThreshold = scrollViewContentHeight - self.collectionView.bounds.size.height;
         
         // When the user has scrolled past the threshold, start requesting
         if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging) {
             isMoreDataLoading = true;
             
             // Update position of loadingMoreView, and start loading indicator
             CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
             loadingMoreView.frame = frame;
             
             // Code to load more results
             [loadingMoreView startAnimating];
             [self loadMoreData];
             if (newTempCount > 0) {
                 [self.collectionView reloadData];
             }
         }
     }
}

- (void)fetchTemplates {
    // construct query
   PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query  includeKey:@"author"];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    if (self.category != nil) {
        [query whereKey:@"category" equalTo:self.category];
    }
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            self.templates = templates;
            self.filteredData = self.templates;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
    }];
}

- (void)profileTemplateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull User *)user {
    self.user = user;
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
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

- (void)templateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull Template *)temp {
    if (![self.currentTemplate.objectId isEqualToString:temp.objectId]) {
        if (self.currentCell != nil) {
            TemplateCell *current = self.currentCell;
            UIColor *color = [UIColor clearColor];
            current.checkView.backgroundColor = color;
            UIView *subview = current.checkView.subviews[0];
            subview.hidden = YES;
        }
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        templateCell.checkView.backgroundColor = color;
        self.currentTemplate = temp;
        TemplateCell *prevCell = self.currentCell;
        UIView *prevSubview = prevCell.checkView.subviews[0];
        UIColor *prevColor = [UIColor clearColor];
        prevCell.checkView.backgroundColor = prevColor;
        prevSubview.hidden = YES;
        self.currentCell = templateCell;
        self.currentTemplate = temp;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = NO;
    } else if ([self.currentTemplate.objectId isEqualToString:temp.objectId]) {
        UIColor *color = [UIColor clearColor];
        templateCell.checkView.backgroundColor = color;
        self.currentTemplate = nil;
        self.currentCell = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    UIColor *color = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    [cell.layer setBorderColor:color.CGColor];
    [cell.layer setBorderWidth:1];
    Template *template = self.filteredData[indexPath.item];
    cell.temp = template;
    cell.profileDelegate = self;
    cell.reportDelegate = self;
    cell.delegate = self;
    [cell setTemplate:template];
    if ([self.currentTemplate.objectId isEqualToString:template.objectId]) {
        self.currentCell = cell;
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = NO;
    } else {
        UIColor *color = [UIColor clearColor];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = YES;
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            Template *template = evaluatedObject;
            NSString *templateTitle = template.title;
            return [templateTitle containsString:searchText];
        }];
            PFQuery *query = [Template query];
           [query orderByDescending:@"createdAt"];
           [query  includeKey:@"author"];
           [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
           [query whereKey:@"category" equalTo:self.category];
           // fetch data asynchronously
           [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
               if (templates != nil) {
                   self.filteredData = [templates filteredArrayUsingPredicate:predicate];
                   [self.collectionView reloadData];
               } else {
                   NSLog(@"%@", error.localizedDescription);
               }
           }];
    } else {
        self.filteredData = self.templates;
        [self.collectionView reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    skip = 20;
    newTempCount = 0;
    [super viewDidAppear:animated];

    if (self.tutorialManager) {
        [self.tutorialManager updateTutorial];
    }
}


- (NSArray<UIView *> *)tutorialViewsToHighlight:(NSInteger)index {
    if (index == 0) {
        return @[self.collectionView, self.searchBar];
    } else if (index == 1) {
        return @[self.searchBar];
    } else if (index == 2) {
        TemplateCell *tempCell = (TemplateCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        return @[tempCell];
    } else if (index == 3) {
        return @[[self.navigationItem.rightBarButtonItems[2] valueForKey:@"view"]];
    } else if (index == 4) {
        return @[[self.navigationItem.rightBarButtonItems[1] valueForKey:@"view"]];
    } else if (index == 5) {
        return @[[self.navigationItem.rightBarButtonItems[0] valueForKey:@"view"]];
    }

    return nil;
}

-(NSArray<NSString *> *)tutorialTexts:(NSInteger)index
{
    if (index == 1) {
        return @[@"Here, you can search for particular templates."];
    } else if (index == 2) {
        return @[@"Time for the primary power of Writivist. Tap this template."];
    } else if (index == 3) {
        return @[@"Tap here to preview this template."];
    } else if (index == 4) {
        return @[@"Tap here to share this template via social media and beyond."];
    } else if (index == 5) {
        return @[@"Tap here to funnel this template's contents into your email or printable letter."];
    }
    return nil;
}

-(NSArray<TNTutorialEdgeInsets *> *)tutorialViewsEdgeInsets:(NSInteger)index {
    if (index == 1) {
        return @[TNTutorialEdgeInsetsMake(8, 8, 8, 8)];
    }

    return nil;
}

-(CGFloat)tutorialPreActionDelay:(NSUInteger)index {
    if (index == 4 || index == 5) {
        return 1.5;
    } else if (index == 3) {
        return 1;
    } else {
        return 0;
    }
}

- (void)tutorialPreHighlightAction:(NSInteger)index {
}

-(void)tutorialPerformAction:(NSInteger)index {
    if (index == 1) {
        self.searchBar.text = @"CA For BLM";
        [self searchBar:self.searchBar textDidChange: @"CA For BLM"];
    } else if (index == 2) {
        TemplateCell *tempCell = (TemplateCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [self templateCell:tempCell didTap:tempCell.temp];
    } else if (index == 3) {
        [self previewButton];
    } else if (index == 4) {
        [self shareButton];
    } else if (index == 5) {
        [self doneButton];
    }
}


- (NSArray<NSNumber *> *)tutorialTextPositions:(NSInteger)index {
    if (index == 3 || index == 4 || index == 5) {
        return @[@(TNTutorialTextPositionBottom)];
    }
    return @[@(TNTutorialTextPositionTop)];
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
    return YES;
}

- (NSArray<UIFont *> *)tutorialTextFonts:(NSInteger)index {
    return @[[UIFont systemFontOfSize:17.f]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedTemplate"]) {
        HomeViewController *homeViewController = [segue destinationViewController];
        homeViewController.currentTemplate = self.currentTemplate;
        TemplateCell *current = self.currentCell;
        UIColor *color = [UIColor clearColor];
        current.checkView.backgroundColor = color;
        UIView *subview = current.checkView.subviews[0];
        subview.hidden = YES;
        self.currentCell = nil;
        self.currentTemplate = nil;
    }
    if ([segue.identifier isEqualToString:@"preview"]) {
        PreviewViewController *previewViewController = [segue destinationViewController];
        previewViewController.templateTitle = self.currentTemplate.title;
        previewViewController.body = self.currentTemplate.body;
        if (self.tutorialManager) {
            previewViewController.isTutorial = true;
        }
    }
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = self.user;
    }
}

@end
