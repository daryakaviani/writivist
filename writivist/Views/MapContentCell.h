//
//  MapContentCell.h
//  writivist
//
//  Created by dkaviani on 7/20/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Representative.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MapContentCellDelegate;

@interface MapContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) Representative *representative;
@property (nonatomic, weak) id<MapContentCellDelegate> delegate;

@end

@protocol MapContentCellDelegate
- (void)mapContentCell:(MapContentCell *) mapContentCell didTap: (Representative *)representative;
@end

NS_ASSUME_NONNULL_END
