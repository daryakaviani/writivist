//
//  TemplateLibraryViewController.m
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "TemplateLibraryViewController.h"
#import "CategoryRow.h"

@interface TemplateLibraryViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TemplateLibraryViewController

NSArray *categories;
NSString *CellIdentifier = @"CategoryRow";
NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    categories = @[@"black lives matter", @"climate action", @"financial justice", @"islamophobia"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
}
   
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    header.textLabel.text = categories[section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

@end
