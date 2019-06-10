//
//  CustomTableViewCell.h
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTableViewCell;

@protocol CustomTableViewCellListener <NSObject>
- (void) didTapOnCustomViewCell:(CustomTableViewCell*) header;
@end

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) id<CustomTableViewCellListener> listener;

@property (weak, nonatomic) IBOutlet UILabel *infLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBut;

@end
