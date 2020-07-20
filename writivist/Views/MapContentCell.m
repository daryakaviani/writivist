//
//  MapContentCell.m
//  writivist
//
//  Created by dkaviani on 7/20/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import "MapContentCell.h"

@implementation MapContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
     UITapGestureRecognizer *cellTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCell:)];
    [self addGestureRecognizer:cellTapGestureRecognizer];
    [self setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) didTapCell:(UITapGestureRecognizer *)sender{
    [self.delegate mapContentCell:self didTap:self.representative];
}

@end
