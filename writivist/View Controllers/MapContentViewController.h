//
//  MapContentViewController.h
//  writivist
//
//  Created by dkaviani on 7/20/20.
//  Copyright © 2020 dkaviani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "MapContentCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapContentViewController : UIViewController
@property (nonatomic, strong) MapViewController *mapViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)mapContentCell:(nonnull MapContentCell *)mapContentCell didTap:(nonnull Representative *)representative;
- (void)fetchAddresses;

@end

NS_ASSUME_NONNULL_END
