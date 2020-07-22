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

@interface TemplateLibraryViewController ()<UITableViewDelegate, UITableViewDataSource, ProfileDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *category;

@end

@implementation TemplateLibraryViewController

NSArray *categories;
NSString *CellIdentifier = @"CategoryRow";
NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    categories = @[@"black lives matter", @"climate action", @"financial justice", @"islamophobia", @"topic", @"topic", @"topic", @"topic"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}
   
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category = categories[indexPath.section];
    CategoryRow *cell = (CategoryRow *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.templateLibrary = self;
    self.body = @"";
    cell.tag = indexPath.section;
    [cell.collectionView reloadData];
    [cell.collectionView.collectionViewLayout invalidateLayout];
    [cell setCategory:category];
    return cell;
}

- (void) refresh {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *string = categories[section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    
    SectionTapper *singleTapRecognizer = [[SectionTapper alloc] initWithTarget:self action:@selector(handleGesture:)];
    [singleTapRecognizer setDelegate:self];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.data = string;
    [view addGestureRecognizer:singleTapRecognizer];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 50)];
    [label setFont: [UIFont fontWithName:@"Snell Roundhand" size:30]];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5]];
    return view;
}

-(void) handleGesture:(SectionTapper *)gestureRecognizer {
    self.category = gestureRecognizer.data;
    [self performSegueWithIdentifier:@"toCategory" sender:nil];
}

- (IBAction)previewButton:(id)sender {
    [self performSegueWithIdentifier:@"preview" sender:nil];
}
- (IBAction)doneButton:(id)sender {
    [self performSegueWithIdentifier:@"selectedTemplate" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (void)profileTemplateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull User *)user {
    self.user = user;
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectedTemplate"]) {
        HomeViewController *homeViewController = [segue destinationViewController];
        homeViewController.body = self.body;
        self.body = @"";
        self.previewTitle = @"";
        TemplateCell *current = self.currentCell;
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
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
    if ([segue.identifier isEqualToString:@"toCategory"]) {
        CategoryViewController *categoryViewController = [segue destinationViewController];
        categoryViewController.category = self.category;
    }

}

@end
