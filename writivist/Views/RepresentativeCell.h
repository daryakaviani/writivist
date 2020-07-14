//
//  RepresentativeCell.h
//  writivist
//
//  Created by dkaviani on 7/13/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Representative.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RepresentativeCellDelegate;

@interface RepresentativeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *partyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) Representative *representative;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (nonatomic, weak) id<RepresentativeCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@end

@protocol RepresentativeCellDelegate
- (void)representativeCell:(RepresentativeCell *) representativeCell didTap: (Representative *)representative;
@end

NS_ASSUME_NONNULL_END
