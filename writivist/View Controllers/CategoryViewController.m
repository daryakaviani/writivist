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

@interface CategoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ProfileDelegate, UISearchBarDelegate, TemplateCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) TemplateCell *currentCell;
@property (nonatomic, strong) Template *currentTemplate;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *previewTitle;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredData;

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
    
    if (self.saved) {
        self.navigationItem.title = @"saved";
    } else {
        self.navigationItem.title = self.category;
    }
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:30], NSForegroundColorAttributeName : [UIColor labelColor]};
    
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
}

- (void) viewDidAppear:(BOOL)animated {
    skip = 20;
    newTempCount = 0;
}

- (IBAction)shareButton:(id)sender {
    NSString *shareString = @"Check out this letter hosted on the app Writivist! Share it with your representatives and download Writivist on the App Store to get in touch with your elected officials in seconds.";
    shareString = [NSString stringWithFormat:@"%@\n\n%@",shareString, self.previewTitle];
    shareString = [NSString stringWithFormat:@"%@\n\n%@",shareString, self.body];
    NSArray *activityItems = @[shareString];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    if (UIUserInterfaceIdiomPad) {
        activityViewControntroller.popoverPresentationController.sourceView = self.view;
        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
    }
    [self presentViewController:activityViewControntroller animated:true completion:nil];
}

- (void) queryMoreSaved {
    dispatch_group_t dispatchGroup = dispatch_group_create();

    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    query.skip = skip;
    query.limit = 20;

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
            newTempCount = (int) savedTemplates.count;
            self.templates = (NSMutableArray *) newArray;
            self.filteredData = (NSMutableArray *) newArray;
            skip += savedTemplates.count;
            isMoreDataLoading = false;
            [loadingMoreView stopAnimating];
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

- (void) loadMoreData {
    if (self.saved) {
        [self queryMoreSaved];
    } else {
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
//                [self.collectionView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
//                [self.collectionView reloadData];
            }
//            [self.collectionView reloadData];
        }];
    }
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


- (void) querySaved {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
        PFQuery *query = [Template query];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"author"];
        [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
        if (self.category != nil) {
            [query whereKey:@"category" equalTo:self.category];
        }
        query.limit = 20;

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
                 [self.refreshControl endRefreshing];
                 [self.spinner stopAnimating];
                self.spinner.hidden = YES;
                [self.collectionView reloadData];
            });
        }];
}

- (void)fetchTemplates {
    // construct query
    if (self.saved) {
        [self querySaved];
        } else {
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
        self.body = temp.body;
        self.previewTitle = temp.title;
    } else if ([self.currentTemplate.objectId isEqualToString:temp.objectId]) {
        UIColor *color = [UIColor clearColor];
        templateCell.checkView.backgroundColor = color;
        self.currentTemplate = nil;
        self.currentCell = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
        self.body = @"";
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    UIColor *color = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    [cell.layer setBorderColor:color.CGColor];
    [cell.layer setBorderWidth:1];
    Template *template = self.filteredData[indexPath.item];
    cell.temp = template;
    cell.otherDelegate = self;
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
        
        if (self.saved) {
            PFQuery *query = [Template query];
            [query orderByDescending:@"createdAt"];
            [query includeKey:@"author"];
            [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
            if (self.category != nil) {
                [query whereKey:@"category" equalTo:self.category];
            }
            query.limit = 20;

            // fetch data asynchronously
            [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
                if (templates != nil) {
                    NSMutableArray *savedTemplates = [[NSMutableArray alloc] init];
                    for (Template *template in templates) {
                        PFRelation *relation = [template relationForKey:@"savedBy"];
                        PFQuery *query = [relation query];
                        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                            for (User *user in objects) {
                                if ([user.username isEqualToString:[User currentUser].username]) {
                                    [savedTemplates addObject:template];
                                }
                            }
                            self.filteredData = [savedTemplates filteredArrayUsingPredicate:predicate];
                            [self.collectionView reloadData];
                        }];
                    }
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
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
        }
    } else {
        self.filteredData = self.templates;
    }
    [self.collectionView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedTemplate"]) {
        HomeViewController *homeViewController = [segue destinationViewController];
        homeViewController.body = self.body;
        self.body = @"";
        self.previewTitle = @"";
        TemplateCell *current = self.currentCell;
        UIColor *color = [UIColor clearColor];
        current.checkView.backgroundColor = color;
        UIView *subview = current.checkView.subviews[0];
        subview.hidden = YES;
        self.currentCell = nil;
    }
    if ([segue.identifier isEqualToString:@"preview"]) {
        PreviewViewController *previewViewController = [segue destinationViewController];
        previewViewController.templateTitle = self.previewTitle;
        previewViewController.body = self.body;
    }
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = self.user;
    }
}

@end
