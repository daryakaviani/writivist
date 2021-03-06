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
    UIColor *color = [[UIColor alloc]initWithRed:96/255.0 green:125/255.0 blue:139/255.0 alpha:1];
    [cell.layer setBorderColor:color.CGColor];
    [cell.layer setBorderWidth:1];
    Template *template = self.templates[indexPath.item];
    cell.temp = template;
    cell.delegate = self;
    cell.profileDelegate = self.templateLibrary;
    cell.reportDelegate = self.templateLibrary;
    cell.templateLibrary = self.templateLibrary;
    [cell setTemplate:template];
    if ([self.templateLibrary.currentTemplate.objectId isEqualToString:template.objectId]) {
        self.templateLibrary.currentCell = cell;
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

- (void) setCategory: (NSString *) category {
    _category = category;
    [self fetchTemplates];
}

- (void)fetchTemplates {
    // construct query
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
            self.templates = templates;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.spinner.hidden = YES;
        });
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
    if (![self.templateLibrary.currentTemplate.objectId isEqualToString:temp.objectId]) {
        if (self.templateLibrary.currentCell != nil) {
            TemplateCell *current = self.templateLibrary.currentCell;
            UIColor *color = [UIColor clearColor];
            current.checkView.backgroundColor = color;
            UIView *subview = current.checkView.subviews[0];
            subview.hidden = YES;
        }
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        templateCell.checkView.backgroundColor = color;
        TemplateCell *prevCell = self.templateLibrary.currentCell;
        UIView *prevSubview = prevCell.checkView.subviews[0];
        UIColor *prevColor = [UIColor clearColor];
        prevCell.checkView.backgroundColor = prevColor;
        prevSubview.hidden = YES;
        self.templateLibrary.currentCell = templateCell;
        self.templateLibrary.currentTemplate = templateCell.temp;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = NO;
        self.templateLibrary.currentTemplate = temp;
        [temp saveInBackground];
        [prevCell.temp saveInBackground];
    } else if ([self.templateLibrary.currentTemplate.objectId isEqualToString:temp.objectId]) {
        UIColor *color = [UIColor clearColor];
        templateCell.checkView.backgroundColor = color;
        self.templateLibrary.currentCell = nil;
        self.templateLibrary.currentTemplate = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
        [temp saveInBackground];
    }
    
}

@end


