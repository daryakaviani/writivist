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

@interface CategoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *templates;
@property (nonatomic, strong) TemplateCell *currentCell;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *previewTitle;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.category);
    self.navigationController.navigationBar.tintColor = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.navigationItem.title = self.category;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Snell Roundhand" size:40], NSForegroundColorAttributeName : [UIColor blackColor]};
    
    [self fetchTemplates];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing - layout.sectionInset.left - layout.sectionInset.right) / 2;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    // Do any additional setup after loading the view.
}

- (void)fetchTemplates {
    // construct query
    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    if (self.category != nil) {
        [query whereKey:@"category" equalTo:self.category];
    }
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            self.templates = templates;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


- (void)templateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull Template *)temp {
    if (temp.selected == false) {
        if (self.currentCell != nil) {
            TemplateCell *current = self.currentCell;
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
            current.checkView.backgroundColor = color;
            UIView *subview = current.checkView.subviews[0];
            subview.hidden = YES;
        }
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
        templateCell.checkView.backgroundColor = color;
        temp.selected = true;
        TemplateCell *prevCell = self.currentCell;
        UIView *prevSubview = prevCell.checkView.subviews[0];
        UIColor *prevColor = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        prevCell.checkView.backgroundColor = prevColor;
        prevCell.temp.selected = false;
        prevSubview.hidden = YES;
        self.currentCell = templateCell;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = NO;
        self.body = temp.body;
        self.previewTitle = temp.title;
    } else if (temp.selected == true) {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        templateCell.checkView.backgroundColor = color;
        temp.selected = false;
        self.currentCell = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
        self.body = @"";
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1];
    [cell.layer setBorderColor:color.CGColor];
    [cell.layer setBorderWidth:1];
    Template *template = self.templates[indexPath.item];
    cell.temp = template;
    cell.delegate = self;
    [cell setTemplate:template];
    if (cell.temp.selected == true) {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = NO;
    } else {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        cell.checkView.backgroundColor = color;
        UIView *subview = cell.checkView.subviews[0];
        subview.hidden = YES;
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.templates.count;
}
@end
