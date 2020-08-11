//
//  SavedViewController.m
//  writivist
//
//  Created by dkaviani on 8/3/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "SavedViewController.h"
#import "Template.h"
#import "TemplateCell.h"
#import <Parse/Parse.h>
#import "PreviewViewController.h"
#import "HomeViewController.h"
#import "User.h"
#import "ProfileViewController.h"
#import "InfiniteScrollActivityView.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface SavedViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ProfileDelegate, UISearchBarDelegate, TemplateCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) TemplateCell *currentCell;
@property (nonatomic, strong) Template *currentTemplate;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredData;

@end

@implementation SavedViewController
bool isMoreSavedDataLoading = false;
InfiniteScrollActivityView* loadingMoreSavedView;
int savedSkip = 20;
int newSavedTempCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spinner startAnimating];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    self.navigationItem.title = @"Saved";
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
    loadingMoreSavedView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreSavedView.hidden = true;
    [self.collectionView addSubview:loadingMoreSavedView];
    
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
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void) viewDidAppear:(BOOL)animated {
    if (![self connected]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        savedSkip = 20;
        newSavedTempCount = 0;
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
    }
}

- (void) loadMoreData {
    dispatch_group_t dispatchGroup = dispatch_group_create();

    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    query.skip = savedSkip;
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            NSMutableArray *savedTemplates = [[NSMutableArray alloc] init];
            for (Template *template in templates) {
                dispatch_group_enter(dispatchGroup);
                PFRelation *relation = [template relationForKey:@"savedBy"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    for (User *user in objects) {
                        if ([user.username isEqualToString:[User currentUser].username]) {
                            [savedTemplates addObject:template];
                        }
                    }
                }];
            }
            NSArray *newArray = [self.filteredData arrayByAddingObjectsFromArray:savedTemplates];
            newSavedTempCount = (int) savedTemplates.count;
            self.templates = (NSMutableArray *) newArray;
            self.filteredData = (NSMutableArray *) newArray;
            savedSkip += savedTemplates.count;
            isMoreSavedDataLoading = false;
            [loadingMoreSavedView stopAnimating];
            dispatch_group_leave(dispatchGroup);
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
             [self.refreshControl endRefreshing];
             [self.spinner stopAnimating];
            self.spinner.hidden = YES;
            [self.collectionView reloadData];
        });
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
     if(!isMoreSavedDataLoading){
         // Calculate the position of one screen length before the bottom of the results
         int scrollViewContentHeight = self.collectionView.contentSize.height;
         int scrollOffsetThreshold = scrollViewContentHeight - self.collectionView.bounds.size.height;
         
         // When the user has scrolled past the threshold, start requesting
         if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging) {
             isMoreSavedDataLoading = true;
             
             // Update position of loadingMoreView, and start loading indicator
             CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
             loadingMoreSavedView.frame = frame;
             
             // Code to load more results
             [loadingMoreSavedView startAnimating];
             [self loadMoreData];
             if (newSavedTempCount > 0) {
                 [self.collectionView reloadData];
             }
         }
     }
}


- (void) fetchTemplates {
    if (![self connected]) {
        [self.refreshControl endRefreshing];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was a network error."
               message:@"Check your internet connection and try again."
        preferredStyle:(UIAlertControllerStyleAlert)];
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        PFQuery *query = [Template query];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"author"];
        [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
        NSMutableArray *savedTemplates = [NSMutableArray array];
        // fetch data asynchronously
        [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
            if (templates != nil) {
                for (Template *template in templates) {
                    dispatch_group_enter(dispatchGroup);
                    PFRelation *relation = [template relationForKey:@"savedBy"];
                    PFQuery *query = [relation query];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        if (objects) {
                            for (User *user in objects) {
                                if ([user.username isEqualToString:[User currentUser].username]) {
                                    [savedTemplates addObject:template];
                                }
                            }
                            self.templates = savedTemplates;
                            self.filteredData = self.templates;
                        } else {
                            NSLog(@"not working");
                        }
                        dispatch_group_leave(dispatchGroup);
                    }];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
                 [self.refreshControl endRefreshing];
                 [self.spinner stopAnimating];
                 self.spinner.hidden = YES;
                 [self.collectionView reloadData];
            });
        }];
    }
}

- (void)profileTemplateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull User *)user {
    self.user = user;
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
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
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        PFQuery *query = [Template query];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"author"];
        [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
        NSMutableArray *savedTemplates = [NSMutableArray array];
        // fetch data asynchronously
        [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
            if (templates != nil) {
                for (Template *template in templates) {
                    dispatch_group_enter(dispatchGroup);
                    PFRelation *relation = [template relationForKey:@"savedBy"];
                    PFQuery *query = [relation query];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        for (User *user in objects) {
                            if ([user.username isEqualToString:[User currentUser].username]) {
                                [savedTemplates addObject:template];
                            }
                        }
                        self.templates = savedTemplates;
                        self.filteredData = self.templates;
                        dispatch_group_leave(dispatchGroup);
                    }];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(void){
                [self.collectionView reloadData];
                self.filteredData = [savedTemplates filteredArrayUsingPredicate:predicate];
            });
        }];
    } else {
        self.filteredData = self.templates;
        [self.collectionView reloadData];
    }
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
    }
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = self.user;
    }
}

@end
