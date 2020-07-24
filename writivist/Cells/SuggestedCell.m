//
//  SuggestedCell.m
//  writivist
//
//  Created by dkaviani on 7/22/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "SuggestedCell.h"
#import <Parse/Parse.h>
#import "Template.h"
#import "TemplateCell.h"

@implementation SuggestedCell

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
    PFQuery *senderQuery = [Template query];
    [senderQuery orderByDescending:@"senderCount"];
    [senderQuery includeKey:@"author"];
    senderQuery.limit = 20;
    // fetch data asynchronously
    [senderQuery findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
        if (templates != nil) {
            self.senderTemplates = templates;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        // construct query
        PFQuery *likeQuery = [Template query];
        [likeQuery orderByDescending:@"likeCount"];
        [likeQuery includeKey:@"author"];
        likeQuery.limit = 20;

        // fetch data asynchronously
        [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
            if (templates != nil) {
                self.likeTemplates = templates;
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
            PFQuery *query = [Template query];
                [query orderByDescending:@"createdAt"];
                [query includeKey:@"author"];
                [query whereKey:@"author" equalTo:[User currentUser]];
                query.limit = 20;

                // fetch data asynchronously
                [query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
                    if (templates != nil) {
                        self.myTemplates = templates;
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                    [self rankTemplates];
                }];
        }];
    }];
}

- (void) rankTemplates {
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
    for (Template *template in self.myTemplates) {
        NSString *category = template.category;
        NSDecimalNumber *currentCount = [NSDecimalNumber numberWithFloat:([myDict[category] floatValue] + 1.0)];
        [myDict setObject:currentCount forKey:category];
    }
    for (NSObject *category in myDict.allKeys) {
        NSDecimalNumber *categoryCount = myDict[category];
        NSDecimalNumber *totalTemplates = [NSDecimalNumber numberWithInteger:self.myTemplates.count];
        myDict[category] = [categoryCount decimalNumberByDividingBy:totalTemplates];
        myDict[category] = [NSDecimalNumber numberWithFloat:([myDict[category] floatValue] + 1.0)];
    }
    
    self.dict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.senderTemplates.count; i += 1) {
        Template *template = self.senderTemplates[i];
        NSString *category = template.category;
        if (myDict[category] != nil && [myDict[category] intValue] != 0) {
            NSDecimalNumber *multiplier = myDict[category];
            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[template.senderCount decimalValue]];
            NSDecimalNumber *heuristic = [multiplier decimalNumberByMultiplyingBy:decNum];
            [self.dict setObject:heuristic forKey:template.objectId];
        } else {
            [self.dict setObject:template.senderCount forKey:template.objectId];
        }
    }
    for (int i = 0; i < self.likeTemplates.count; i += 1) {
        Template *template = self.likeTemplates[i];
        NSString *category = template.category;
        NSNumber *heuristic;
        if ([self.dict.allKeys containsObject:template.objectId]) {
            heuristic = [NSNumber numberWithInt:([template.likeCount intValue] + [template.senderCount intValue])];
        } else {
            heuristic = template.likeCount;
        }
        if (myDict[category] != nil && [myDict[category] intValue]) {
            NSDecimalNumber *multiplier = myDict[category];
            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[heuristic decimalValue]];
            NSDecimalNumber *newHeuristic = [multiplier decimalNumberByMultiplyingBy:decNum];
            [self.dict setObject:newHeuristic forKey:template.objectId];
        } else {
            [self.dict setObject:heuristic forKey:template.objectId];
        }
    }
    
    NSArray *keys = [self.dict allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [self.dict objectForKey:b];
        NSNumber *second = [self.dict objectForKey:a];
        return [first compare:second];
    }];
        
    NSMutableArray *sortedTemplates = [[NSMutableArray alloc] init];
    for (NSString *objectID in sortedKeys) {
        bool foundInFirst = false;
        for (int i = 0; i < self.senderTemplates.count; i += 1) {
            Template *template = self.senderTemplates[i];
            if ([template.objectId isEqual:objectID]) {
                [sortedTemplates addObject:template];
                foundInFirst = true;
            }
        }
        if (!foundInFirst) {
            for (int i = 0; i < self.likeTemplates.count; i += 1) {
                Template *template = self.likeTemplates[i];
                if ([template.objectId isEqual:objectID]) {
                    [sortedTemplates addObject:template];
                }
            }
        }
    }
    
    self.templates = sortedTemplates;
    [self.collectionView reloadData];
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
            UIColor *color = [UIColor clearColor];
            current.checkView.backgroundColor = color;
            UIView *subview = current.checkView.subviews[0];
            subview.hidden = YES;
        }
        UIColor *color = [[UIColor alloc]initWithRed:178/255.0 green:223/255.0 blue:219/255.0 alpha:0.4];
        templateCell.checkView.backgroundColor = color;
        temp.selected = true;
        TemplateCell *prevCell = self.templateLibrary.currentCell;
        UIView *prevSubview = prevCell.checkView.subviews[0];
        UIColor *prevColor = [UIColor clearColor];
        prevCell.checkView.backgroundColor = prevColor;
        prevCell.temp.selected = false;
        prevSubview.hidden = YES;
        self.templateLibrary.currentCell = templateCell;
        self.templateLibrary.currentTemplate = templateCell.temp;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = NO;
        self.templateLibrary.body = temp.body;
        self.templateLibrary.previewTitle = temp.title;
    } else if (temp.selected == true) {
        UIColor *color = [UIColor clearColor];
        templateCell.checkView.backgroundColor = color;
        temp.selected = false;
        self.templateLibrary.currentCell = nil;
        self.templateLibrary.currentTemplate = nil;
        UIView *subview = templateCell.checkView.subviews[0];
        subview.hidden = YES;
        self.templateLibrary.body = @"";
    }
    
}

@end
