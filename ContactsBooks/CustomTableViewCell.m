//
//  CustomTableViewCell.m
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.infoBut addTarget:self action:@selector(pushToInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.infoBut];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void) pushToInfoButton:(id)sender {
    if ([self.listener respondsToSelector:@selector(didTapOnCustomViewCell:)]) {
        [self.listener didTapOnCustomViewCell:self];
    }
}

@end
