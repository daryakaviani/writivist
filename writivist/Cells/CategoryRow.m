//
//  CategoryRow.m
//  writivist
//
//  Created by dkaviani on 7/14/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "CategoryRow.h"
#import <Parse/Parse.h>
#import "Template.h"
#import "TemplateCell.h"

@implementation CategoryRow

- (void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TemplateCell" forIndexPath:indexPath];
    UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:1];
    [cell.layer setBorderColor:color.CGColor];
    [cell.layer setBorderWidth:1];
    Template *template = self.templates[indexPath.item];
    cell.temp = template;
    cell.delegate = self;
    cell.otherDelegate = self.templateLibrary;
    cell.templateLibrary = self.templateLibrary;
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

- (void) setCategory: (NSString *) category {
    _category = category;
    [self fetchTemplates];
}

- (void)fetchTemplates {
    // construct query
    PFQuery *query = [Template query];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    if (self.category != nil) {
        [query whereKey:@"category" equalTo:self.category];
    }
//
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

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.templates.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemWidth = 200;
    CGFloat itemHeight = 200;
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)templateCell:(nonnull TemplateCell *)templateCell didTap:(nonnull Template *)temp {
    if (temp.selected == false) {
        if (self.templateLibrary.currentCell != nil) {
            TemplateCell *current = self.templateLibrary.currentCell;
            UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
            current.checkView.backgroundColor = color;
            UIView *subview = current.checkView.subviews[0];
            subview.hidden = YES;
        }
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0.5];
        templateCell.checkView.backgroundColor = color;
        temp.selected = true;
        TemplateCell *prevCell = self.templateLibrary.currentCell;
        UIView *prevSubview = prevCell.checkView.subviews[0];
        UIColor *prevColor = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        prevCell.checkView.backgroundColor = prevColor;
        prevCell.temp.selected = false;
        prevSubview.hidden = YES;
        self.templateLibrary.currentCell = templateCell;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = NO;
        self.templateLibrary.body = temp.body;
        self.templateLibrary.previewTitle = temp.title;
    } else if (temp.selected == true) {
        UIColor *color = [[UIColor alloc]initWithRed:248/255.0 green:193/255.0 blue:176/255.0 alpha:0];
        templateCell.checkView.backgroundColor = color;
        temp.selected = false;
        self.templateLibrary.currentCell = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
        self.templateLibrary.body = @"";
    }
    
}

@end


